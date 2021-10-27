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
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChanceRoom.sol";

contract Factory is Ownable{
    using Clones for address;

    address public chanceRoomLibrary;           //Source code clonable for chance rooms
    address public randomNumberConsumer;        //Random number consumer which new chance room will use
    ChanceRoom[] chanceRooms;                //List of chance rooms has been cloned

    event NewChanceRoom(address chanceRoom, address owner);

    constructor(
        address _randomNumberConsumer,
        address _chanceRoomLibrary
    ) {
        newRandomNumberConsumer(_randomNumberConsumer);
        newChanceRoomLibrary(_chanceRoomLibrary);
    }

    function chanceroomsList() public view returns(ChanceRoom[] memory) {
        return chanceRooms;
    }

    function newChanceRoomLibrary(address _chanceRoomLibrary) public onlyOwner {
        chanceRoomLibrary = _chanceRoomLibrary;
    }

    function newRandomNumberConsumer(address _randomNumberConsumer) public onlyOwner {
        randomNumberConsumer = _randomNumberConsumer;
    }

    function newChanceRoom(
        string memory info,
        string memory baseURI,
        uint256 gateFee,
        uint256 percentCommission,
        uint256 userLimit,
        uint256 timeLimit
    ) public {
        address chanceRoomAddress = chanceRoomLibrary.clone();
        ChanceRoom chanceRoom = ChanceRoom(chanceRoomAddress);
        chanceRoom.initialize(
            info,
            baseURI,
            gateFee,
            percentCommission,
            userLimit,
            timeLimit,
            msg.sender,
            randomNumberConsumer
        );
        chanceRooms.push(chanceRoom);
        emit NewChanceRoom(chanceRoomAddress, msg.sender);
    }
}