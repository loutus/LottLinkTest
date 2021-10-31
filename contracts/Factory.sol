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

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Register.sol";
import "./ChanceRoom.sol";

contract Factory is Ownable {
    using Clones for address;

    address public registerContract;            //Register contract of all users
    address public chanceRoomLibrary;           //Source code clonable for chance rooms
    address public randomNumberConsumer;        //Random number consumer which new chance room will use

    Register register;
    ChanceRoom[] chanceRooms;                

    event NewChanceRoom(address chanceRoom, address owner);
    event RandomNumberConsumerUpdated(address newConsumer, address updater);
    event ChanceRoomLibraryUpdated(address newLibrary, address updater);

    constructor(
        address _registerContract,
        address _randomNumberConsumer,
        address _chanceRoomLibrary
    ) {
        registerContract = _registerContract;
        register = Register(registerContract);
        newRandomNumberConsumer(_randomNumberConsumer);
        newChanceRoomLibrary(_chanceRoomLibrary);
    }


    //Returns list of chance rooms has been cloned
    function chanceroomsList() public view returns(ChanceRoom[] memory) {
        return chanceRooms;
    }


    //Upgrade chance room library by owner
    function newChanceRoomLibrary(address _chanceRoomLibrary) public onlyOwner {
        chanceRoomLibrary = _chanceRoomLibrary;
        emit ChanceRoomLibraryUpdated(chanceRoomLibrary, _msgSender());
    }


    //Upgrade random number consumer by owner
    function newRandomNumberConsumer(address _randomNumberConsumer) public onlyOwner {
        randomNumberConsumer = _randomNumberConsumer;
        emit RandomNumberConsumerUpdated(randomNumberConsumer, _msgSender());
    }


    //Clone a new chance room by VIP user
    function newChanceRoom(
        string memory info,
        string memory baseURI,
        uint256 gateFee,
        uint256 percentCommission,
        uint256 userLimit,
        uint256 timeLimit
    ) public {
        address cloner = _msgSender();
        require(register.isVIP(cloner), "Only VIP users can clone the contract.");
        address chanceRoomAddress = chanceRoomLibrary.clone();
        ChanceRoom chanceRoom = ChanceRoom(chanceRoomAddress);
        chanceRoom.initialize(
            info,
            baseURI,
            gateFee,
            percentCommission,
            userLimit,
            timeLimit,
            cloner,
            randomNumberConsumer
        );
        chanceRooms.push(chanceRoom);
        emit NewChanceRoom(chanceRoomAddress, cloner);
    }
}