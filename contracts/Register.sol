// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.2 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink ===============

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRegister.sol";

contract Register is IRegister, Ownable{

    uint256 public puerNameFee;
    address public DAOContract;

    struct User{
        string username;
        string info;
        bool isVIP;
    }

    mapping(address => User) public addrToUser;
    mapping(string => address) public userToAddr;


    constructor(address _DAOAddress, uint256 _puerNameFee){
        newDAOContract(_DAOAddress);
        setPureNameFee(_puerNameFee);
    }

    /**
     * @dev See {IRegister-registered}.
     */
    function registered(address userAddr) public view returns(bool) {
        return bytes(addrToUser[userAddr].username).length != 0;
    }

    /**
     * @dev See {IRegister-registered}.
     */
    function registered(string memory username) public view returns(bool) {
        return userToAddr[username] != address(0);
    }

    /**
     * @dev See {IRegister-isPure}.
     */
    function isPure(address userAddr) external view returns(bool){
        return registered(userAddr) 
        && bytes(addrToUser[userAddr].username)[0] != bytes1("_");
    }

    /**
     * @dev See {IRegister-isVIP}.
     */
    function isVIP(address userAddr) external view returns(bool){
        return registered(userAddr)  
        && addrToUser[userAddr].isVIP;
    }

    /**
     * @dev See {IRegister-usernameToAddress}.
     */
    function usernameToAddress(string memory username) external view returns(address userAddr) {
        require(registered(username), "no user by this username");
        return userToAddr[username];
    }

    /**
     * @dev See {IRegister-addressToUsername}.
     */
    function addressToUsername(address userAddr) external view returns(string memory username) {
        require(registered(userAddr), "no user by this address");
        return addrToUser[userAddr].username;
    }

    /**
     * @dev See {IRegister-addressToProfile}.
     */
    function addressToProfile(address userAddr) external view returns(
        string memory username,
        string memory info,
        bool VIPstatus
    ){
        require(registered(userAddr), "no user by this address");
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {IRegister-usernameToProfile}.
     */
    function usernameToProfile(string memory username) external view returns(
        address userAddr,
        string memory info,
        bool VIPstatus
    ){
        require(registered(username), "no user by this address");
        userAddr = userToAddr[username];
        return(
            userAddr,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {IRegister-signIn}.
     */
    function signIn(string memory username, string memory info, address presenter) external payable {
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

        emit SignIn(userAddr, username);

        if(bytes(info).length > 0) {setInfo(info);}

        (bool success, bytes memory data) = DAOContract.call
            (abi.encodeWithSignature("registerSign(address)", presenter));
    }

    /**
     * @dev See {IRegister-setInfo}.
     */
    function setInfo(string memory info) public {
        address userAddr = _msgSender();
        require(registered(userAddr) , "you have to sign in first");
        addrToUser[userAddr].info = info;
        emit SetInfo(userAddr, info);
    }


    /**
     * @dev Set sign in fee for pure usernames.
     */
    function setPureNameFee(uint256 _fee) public onlyOwner {
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
    function newDAOContract(address contractAddr) public onlyOwner {
        DAOContract = contractAddr;
    }
}