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

contract Register is Ownable{

    address[] addressList;

    uint256 public VIPfee;

    struct User{
        string username;
        string info;
        bool isVIP;
    }

    mapping(address => User) public addrToUser;
    mapping(string => address) public userToAddr;

    event SignIn(address indexed userAddress, string username);
    event SetInfo(address indexed userAddress, string info);


///////////// Administration /////////////

    // set sign in fee for VIP users
    function setVIPfee(uint256 _fee) public onlyOwner {
        VIPfee = _fee;
    }

    // withdraw supply by owner of the contract
    function withdraw() public onlyOwner {
        address payable reciever = payable(_msgSender());
        reciever.transfer(address(this).balance);
    }


///////////// Login /////////////

    function userInfo(address userAddr) public view returns(
        string memory username,
        string memory info,
        bool isVIP
    ) {
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    function checkVIP(address userAddr) public view returns(bool){
        return addrToUser[userAddr].isVIP;
    }

    function signInVIP(
        address presenter,
        string memory username,
        string memory info
    ) public payable {
        require(msg.value >= VIPfee, "this function is Payable");
        signIn(presenter, username, info);
        addrToUser[_msgSender()].isVIP = true;
    }

    function signIn(
        address _presenter,
        string memory _username,
        string memory _info
    ) public {
        address _user = _msgSender();
        require(bytes(addrToUser[_user].username).length == 0, "user has signed in before");
        require(_presenter != address(0) && _presenter != _user, "wrong presenter address entered");
        addressList.push(_user);
        setUserName(_user, _username);
        if(bytes(_info).length != 0) {setInfo(_info);}
    }

    function setUserName(address _user, string memory _username) internal {
        require(userToAddr[_username] == address(0), "this username has been used before");
        require(bytes(_username).length > 0, "set a username");
        addrToUser[_user].username = _username;
        userToAddr[_username] = _user;
        emit SignIn(_user, _username);
    }

    function setInfo(string memory info) public {
        address _user = _msgSender();
        require(bytes(addrToUser[_user].username).length != 0, "you have to sign in first");
        require(bytes(info).length != 0, "empty info");
        addrToUser[_user].info = info;
        emit SetInfo(_user, info);
    }
}