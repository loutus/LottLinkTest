// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ======================================================================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink ===============

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRegister {

    /**
     * @dev Emitted when a new user signs in.
     */
    event SignIn(address indexed userAddress, string username);

    /**
     * @dev Emitted when user info sets or changes.
     */
    event SetInfo(address indexed userAddress, string info);

    /**
     * @dev Returns the address of the `username`.
     *
     * Requirements:
     *
     * - `username` must exist.
     */
    function userAddress(string memory username) external view returns(address userAddr);

    /**
     * @dev Returns the username and info of the `userAddr`.
     *
     * Requirements:
     *
     * - `userAddr` must be registered before.
     */
    function userProfile(address userAddr) external view returns(string memory username, string memory info);

    /**
     * @dev Sign in the Register contract by adopting a `username`.
     *
     * Pure usernames are payable but new user can sign in free by using `_` in first character of username.
     *
     * Requirements:
     *
     * - Every address can only sign in once and can't change its username.
     * - Not allowed empty usernames.
     * - Usernames are unique so new user has to adopt a username not used before.
     * - new user must introduce a `presenter`.
     *
     * Emits a {SignIn} event.
     */
    function signIn(string memory username) external payable;

    /**
     * @dev in addition to the username, every user can set additional personal info .
     *
     * To remove previously info, can be called by empty string input.
     *
     * Requirements:
     *
     * - The user has to register first.
     *
     * Emits a {SetInfo} event.
     */
    function setInfo(string memory info) external;
}

abstract contract Register is IRegister, Ownable{

    address[] addressList;

    uint256 public puerNameFee;
    address public DAOContract;

    struct User{
        string username;
        string info;
        bool isVIP;
    }

    mapping(address => User) addrToUser;
    mapping(string => address) userToAddr;


    /**
     * @dev See {IRegister-userAddress}.
     */
    function userAddress(string memory username) external view returns(address userAddr) {
        require(userToAddr[username] != address(0), "no user by this address");
        return userToAddr[username];
    }

    /**
     * @dev See {IRegister-userProfile}.
     */
    function userProfile(address userAddr) external view returns(
        string memory username,
        string memory info
    ){
        require(registered(userAddr), "no user by this address");
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info
        );
    }

    /**
     * @dev See {IRegister-signIn}.
     */
    function signIn(string memory username, address presenter) external payable {
        address userAddr = _msgSender();
        require(!registered(userAddr) , "this address has signed a username before");
        require(bytes(username).length > 0, "empty username input");
        require(userToAddr[username] == address(0), "this username has been used before");
        require(presenter != address(0) && presenter != userAddr, "wrong presenter address entered");

        if(bytes(username)[0] != bytes1("_")) {
            require(msg.value >= puerNameFee, "this username is Payable");
        }

        addrToUser[userAddr].username = username;
        userToAddr[username] = userAddr;
        addressList.push(userAddr);

        emit SignIn(userAddr, username);

        (bool success, bytes memory data) = DAOContract.call
            (abi.encodeWithSignature("registerSign(address)", presenter));
    }

    /**
     * @dev See {IRegister-setInfo}.
     */
    function setInfo(string memory info) external {
        address userAddr = _msgSender();
        require(registered(userAddr) , "you have to sign in first");
        addrToUser[userAddr].info = info;
        emit SetInfo(userAddr, info);
    }

    /**
     * @dev Check if the user has been registered.
     */
    function registered(address userAddr) public view returns(bool) {
        return bytes(addrToUser[userAddr].username).length != 0;
    }

    /**
     * @dev Check if username is pure.
     */
    function isPure(address userAddr) external view returns(bool){
        return registered(userAddr) 
        && bytes(addrToUser[userAddr].username)[0] != bytes1("_");
    }

    /**
     * @dev Check if the user is VIP.
     */
    function isVIP(address userAddr) external view returns(bool){
        return registered(userAddr)  
        && addrToUser[userAddr].isVIP;
    }

    /**
     * @dev Set sign in fee for pure usernames.
     */
    function setPureNameFee(uint256 _fee) external onlyOwner {
        puerNameFee = _fee;
    }

    /**
     * @dev Owner of the contract can upgrade a user to VIP.
     */
    function upgradeToVIP(address userAddr) external onlyOwner {
        require(registered(userAddr), "no user by this address");
        addrToUser[userAddr].isVIP = true;
    }

    /**
     * @dev Withdraw supply by owner of the contract.
     */
    function withdraw(address receiverAddress) external onlyOwner {
        address payable receiver = payable(receiverAddress);
        receiver.transfer(address(this).balance);
    }

    /**
     * @dev Chenge DAOContract by owner of the contract.
     */
    function newDAOContract(address contractAddr) external onlyOwner {
        DAOContract = contractAddr;
    }
}