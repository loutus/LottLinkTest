// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.6 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   ============== Verify Random Function by ChainLink ===============

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/StringUtil.sol";
import "./Iregister.sol";
import "../ERC20/ILOTT.sol";

contract Register is Iregister, Ownable{

    using StringUtil for string;

    ILOTT LOTT;
    address public DAOContract;
    uint256 public pureNameFee;
    uint256 public bonus;

    struct User{
        string username;
        string info;
        string DAOInfo;
        bool isVIP;
    }

    mapping(address => User) public addrToUser;
    mapping(string => address) public userToAddr;


    constructor(address _DAOAddress, address _LOTTAddress, uint256 _pureNameFee, uint256 _bonus){
        newDAOContract(_DAOAddress);
        newLOTT(_LOTTAddress);
        setPureNameFee(_pureNameFee);
        setBonus(_bonus);
    }

    /**
     * @dev See {Iregister-registered}.
     */
    function registered(address userAddr) public view returns(bool) {
        return bytes(addrToUser[userAddr].username).length != 0;
    }

    /**
     * @dev See {Iregister-registered}.
     */
    function registered(string memory username) public view returns(bool) {
        return userToAddr[username.lower()] != address(0);
    }

    /**
     * @dev See {Iregister-isPure}.
     */
    function isPure(address userAddr) external view returns(bool){
        return registered(userAddr) 
        && bytes(addrToUser[userAddr].username)[0] != bytes1("_");
    }

    /**
     * @dev See {Iregister-isVIP}.
     */
    function isVIP(address userAddr) external view returns(bool){
        return registered(userAddr)  
        && addrToUser[userAddr].isVIP;
    }

    /**
     * @dev See {Iregister-usernameToAddress}.
     */
    function usernameToAddress(string memory username) public view returns(address userAddr) {
        require(registered(username), "no user by this username");
        return userToAddr[username.lower()];
    }

    /**
     * @dev See {Iregister-addressToUsername}.
     */
    function addressToUsername(address userAddr) external view returns(string memory username) {
        require(registered(userAddr), "no user by this address");
        return addrToUser[userAddr].username;
    }

    /**
     * @dev See {Iregister-addressToProfile}.
     */
    function addressToProfile(address userAddr) external view returns(
        string memory username,
        string memory info,
        bool VIPStatus
    ){
        require(registered(userAddr), "no user by this address");
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {Iregister-usernameToProfile}.
     */
    function usernameToProfile(string memory username) external view returns(
        address userAddr,
        string memory info,
        bool VIPStatus
    ){
        userAddr = usernameToAddress(username);
        return(
            userAddr,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {Iregister-signIn}.
     */
    function signIn(string memory username, string memory info, string memory presenter) external payable {
        address userAddr = _msgSender();
        require(!registered(username), "this username has been used before");
        if(bytes(username)[0] != bytes1("_")) {
            require(msg.value >= pureNameFee, "this username is Payable");
            _donateBonus(userAddr);
        }

        _setUsername(userAddr, username);

        emit TransferUsername(address(0), userAddr, username);

        if(bytes(info).length > 0) {setInfo(info);}

        address presenterAddr = userToAddr[presenter.lower()];
        if(presenterAddr != address(0)){
            (bool success, bytes memory data) = DAOContract.call
                (abi.encodeWithSignature("registerSign(address)", presenterAddr
            ));
            if(success){
                addrToUser[userAddr].DAOInfo = abi.decode(data, (string));
            }
        }
    }

    /**
     * @dev See {Iregister-setInfo}.
     */
    function setInfo(string memory info) public {
        address userAddr = _msgSender();
        require(registered(userAddr) , "you have to sign in first");
        addrToUser[userAddr].info = info;
        emit SetInfo(userAddr, info);
    }

    /**
     * @dev See {Iregister-transferUsername}.
     */
    function transferUsername(address _to) external {
        address _from = _msgSender();
        string memory username = addrToUser[_from].username;

        _deleteUser(_from, username);

        if(_to != address(0)){
            _setUsername(_to, username);
        }

        emit TransferUsername(_from, _to, username);
    }

    /**
     * @dev delete a user by specific `userAddr` and `username`.
     * 
     * Requirements:
     *
     * - user should be registered before.
     */
    function _deleteUser(address userAddr, string memory username) private {
        require(registered(userAddr) , "you are not registered");
        delete addrToUser[userAddr];
        delete userToAddr[username.lower()];
    }

    /**
     * @dev set a `username` to a `userAddr`.
     * 
     * Requirements:
     *
     * - Not allowed empty usernames.
     * - user should not be registered before.
     */
    function _setUsername(address userAddr, string memory username) private {
        require(bytes(username).length > 0, "empty username input");
        require(!registered(userAddr) , "this address has signed a username before");
        addrToUser[userAddr].username = username;
        userToAddr[username.lower()] = userAddr;
    }

    /**
     * @dev donate the `bonus` to the user.
     */
    function _donateBonus(address userAddr) private {
        LOTT.mint(userAddr, bonus);
    }

    /**
     * @dev Set sign in fee for pure usernames.
     */
    function setPureNameFee(uint256 _fee) public onlyOwner {
        pureNameFee = _fee;
    }

    /**
     * @dev Set bonus for pure usernames.
     */
    function setBonus(uint256 _bonus) public onlyOwner {
        bonus = _bonus;
    }

    /**
     * @dev Owner of the contract can upgrade a user to VIP status.
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
     * @dev Chenge LOTT Token address by owner of the contract.
     */
    function newLOTT(address LOTTAddr) public onlyOwner {
        LOTT = ILOTT(LOTTAddr);
    }

    /**
     * @dev Chenge DAOContract by owner of the contract.
     */
    function newDAOContract(address contractAddr) public onlyOwner {
        DAOContract = contractAddr;
    }
}