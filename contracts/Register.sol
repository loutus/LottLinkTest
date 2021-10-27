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

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Register is AccessControlEnumerable{

    address[] addressList;


    uint256 VIPfee;

    bytes32 public constant CLONER_ROLE = keccak256("CLONER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct User{
        string username;
        string info;
        bool isVIP;
    }

    mapping(address => User) public addrToUser;
    mapping(string => address) public userToAddr;

    event SignIn(address indexed userAddress, string username);
    event SetInfo(address indexed userAddress, string info);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(CLONER_ROLE, _msgSender());
    }


///////////// Administration /////////////

    // set sign in fee for VIP users
    function setVIPfee(uint256 _fee) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "must have Admin role to call this function");
        VIPfee = _fee;
    }

    // withdraw supply by owner of the contract
    function withdraw() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have Admin role to call this function");
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

    function signInVIP(
        string memory username,
        string memory info
    ) public payable {
        require(msg.value >= VIPfee, "this function is Payable");
        signIn(username, info);
        _setupRole(CLONER_ROLE, _msgSender());
        addrToUser[_msgSender()].isVIP = true;
    }

    function signIn(
        string memory _username,
        string memory _info
    ) public {
        require(bytes(addrToUser[_msgSender()].username).length == 0, "user has signed in before");
        addressList.push(_msgSender());
        setUserName(_username);
        if(bytes(_info).length != 0) {setInfo(_info);}
    }

    function setUserName(string memory _username) internal {
        require(userToAddr[_username] == address(0), "this username has been used before");
        require(bytes(_username).length > 0, "set a username");
        addrToUser[_msgSender()].username = _username;
        userToAddr[_username] = _msgSender();
        emit SignIn(_msgSender(), _username);
    }

    function setInfo(string memory info) public {
        require(bytes(addrToUser[_msgSender()].username).length != 0, "you have to sign in first");
        require(bytes(info).length != 0, "empty info");
        addrToUser[_msgSender()].info = info;
        emit SetInfo(_msgSender(), info);
    }
}