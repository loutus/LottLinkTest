// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.5 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChainLink ===============

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../register/Iregister.sol";
import "./ChanceRoom.sol";
import "../ERC20/ILOTT.sol";

contract Factory is Ownable {
    using Clones for address;

    address public registerContract;            //Register contract of all users
    address public chanceRoomLibrary;           //Source code clonable for chance rooms
    address public randomNumberConsumer;        //Random number consumer which new chance room will use
    address public NFTContract;                 //ERC721 contract mints NFT for the winner

    ILOTT LOTT;
    Iregister register;
    uint256 cloneFee;
    address[] public chanceRooms;

    mapping (address => address[]) public creatorToRooms;                

    event NewChanceRoom(address chanceRoom, address owner, uint256 gateFee, uint256 percentCommission, uint256 userLimit, uint256 deadline);
    event RandomNumberConsumerUpdated(address newConsumer, uint256 updateTime);
    event NFTContractUpdated(address newNFTContract, uint256 updateTime);
    event ChanceRoomLibraryUpdated(address newLibrary, uint256 updateTime);

    constructor(
        address _registerContract,
        address _randomNumberConsumer,
        address _NFTContractAddress,
        address _chanceRoomLibrary,
        address _LOTTAddress,
        uint256 _cloneFee
    ) {
        registerContract = _registerContract;
        register = Iregister(registerContract);
        newRandomNumberConsumer(_randomNumberConsumer);
        newNFTContract(_NFTContractAddress);
        newChanceRoomLibrary(_chanceRoomLibrary);
        newLOTT(_LOTTAddress);
        setCloneFee(_cloneFee);
    }


    //Returns number af all chancerooms cloned
    function numberOfClonedChanceRooms() external view returns(uint256){
        return (chanceRooms.length);
    }

    //Returns list of chance rooms has been cloned
    function chanceRoomsCloned(int256 _length, int256 _offset) external view returns(address[] memory) {
        assert(uint(_offset + _length) <= chanceRooms.length);

        address[] memory _tmp = new address[](uint(_length));

        uint j = 0;
        for (uint i = uint(_offset); i < uint(_offset + _length); i++) {
            _tmp[j++] = chanceRooms[i];
        }
        return _tmp;
    }

    /**
     * @dev Set clone fee to clone a new chance room.
     */
    function setCloneFee(uint256 _cloneFee) public onlyOwner {
        cloneFee = _cloneFee;
    }

    //Upgrade random number consumer by owner
    function newRandomNumberConsumer(address _randomNumberConsumer) public onlyOwner {
        randomNumberConsumer = _randomNumberConsumer;
        emit RandomNumberConsumerUpdated(randomNumberConsumer, block.timestamp);
    }

    //Upgrade NFT contract by owner
    function newNFTContract(address _NFTContractAddress) public onlyOwner {
        NFTContract = _NFTContractAddress;
        emit NFTContractUpdated(NFTContract, block.timestamp);
    }

    //Upgrade chance room library by owner
    function newChanceRoomLibrary(address _chanceRoomLibrary) public onlyOwner {
        chanceRoomLibrary = _chanceRoomLibrary;
        emit ChanceRoomLibraryUpdated(chanceRoomLibrary, block.timestamp);
    }
    
    /**
     * @dev Chenge LOTT Token address by owner of the contract.
     */
    function newLOTT(address LOTTAddr) public onlyOwner {
        LOTT = ILOTT(LOTTAddr);
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
        require(register.registered(cloner), "Only VIP users can clone the contract.");
        LOTT.burnFrom(cloner, cloneFee);
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
            randomNumberConsumer,
            NFTContract
        );
        creatorToRooms[cloner].push(chanceRoomAddress);
        chanceRooms.push(chanceRoomAddress);
        emit NewChanceRoom(chanceRoomAddress, cloner, gateFee, percentCommission, userLimit, timeLimit + block.timestamp);
    }
}