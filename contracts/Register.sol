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

    event SignIn(address indexed userAddress, string username);
    event SetInfo(address indexed userAddress, string info);

    function userAddress(string memory username) external view returns(address userAddr);
    function userProfile(address userAddr) external view returns(string memory username, string memory info);
    function signIn(string memory username) external payable;
    function setInfo(string memory info) external;
}

abstract contract Register is IRegister, Ownable{

    address[] addressList;

    uint256 public usernameFee;
    address public callableContract;

    struct User{
        string username;
        string info;
    }

    mapping(address => User) addrToUser;
    mapping(string => address) userToAddr;

    event CallContract(bool success, bytes data);

    function userAddress(string memory username) external view returns(address userAddr) {
        require(userToAddr[username] != address(0), "no user by this address");
        return userToAddr[username];
    }

    function userProfile(address userAddr) external view returns(
        string memory username,
        string memory info
    ){
        require(bytes(addrToUser[userAddr].username).length != 0, "no user by this address");
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info
        );
    }

    function signIn(string memory username, address presenter) external payable {
        address userAddr = _msgSender();
        require(bytes(addrToUser[userAddr].username).length == 0, "this address has signed a username before");
        require(bytes(username).length > 0, "empty username input");
        require(userToAddr[username] == address(0), "this username has been used before");
        if(bytes(username)[0] != bytes1("_")) {
            require(msg.value >= usernameFee, "this username is Payable");
        }
        require(presenter != address(0) && presenter != userAddr, "wrong presenter address entered");

        addrToUser[userAddr].username = username;
        userToAddr[username] = userAddr;
        addressList.push(userAddr);

        emit SignIn(userAddr, username);

        (bool success, bytes memory data) = callableContract.call
            (abi.encodeWithSignature("doSomthing(address)", presenter));

        emit CallContract(success, data);
    }

    function setInfo(string memory info) external {
        address userAddr = _msgSender();
        require(bytes(addrToUser[userAddr].username).length != 0, "you have to sign in first");
        require(bytes(info).length != 0, "empty info");
        addrToUser[userAddr].info = info;
        emit SetInfo(userAddr, info);
    }

    function isVIP(address userAddr) external view returns(bool){
        return bytes(addrToUser[userAddr].username).length != 0 
        && bytes(addrToUser[userAddr].username)[0] != bytes1("_");
    }

    // set sign in fee for VIP usernames
    function setUsernameFee(uint256 _fee) external onlyOwner {
        usernameFee = _fee;
    }

    // withdraw supply by owner of the contract
    function withdraw(address receiverAddress) external onlyOwner {
        address payable receiver = payable(receiverAddress);
        receiver.transfer(address(this).balance);
    }

    function newCallableContract(address contractAddr) external onlyOwner {
        callableContract = contractAddr;
    }
}