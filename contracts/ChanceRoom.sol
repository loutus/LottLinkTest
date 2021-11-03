// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.4 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink ===============

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./RNC/IRNC.sol";
import "./ERC721/INFT.sol";

contract ChanceRoom is Initializable{

    IRNC RNC;
    INFT NFT;

///////////// constants /////////////
    string public info;             //summary information about purpose of the room
    string public baseURI;          //source of visual side of room
    uint256 public gateFee;         //price of every single card in wei
    uint256 public commission;      //the wage of contract owner in wei
    uint256 public userLimit;       //maximum number of users can sign in
    uint256 public deadLine;        //when getRandomNumber function unlocks (assuming not reach the quorum of users) 
    address public owner;           //owner of contract
    address public RNCAddress;      //random number consumer address
    address public NFTAddress;      //ERC721 contract mints NFT for the winner

///////////// variables /////////////
    bool gateIsOpen;                //the contract is open and active now
    string public status;           //status of the room
    uint256 public RNCwithhold;     //withhold cash to activate RNC
    uint256 public userCount;       //number of users signed in till this moment
    uint256 public prize;           //the prize winner wins
    address public winner;          //winner of the room
    
/////////////  mappings  /////////////
    mapping (uint256 => address) public indexToAddr;
    mapping (address => bool) public userEntered;
    
/////////////   events   /////////////
    event BuySeat(address indexed user);
    event RollDice(bytes32 requestId);
    event Win(uint256 index, address user, uint256 amount);


///////////// initializer /////////////
    function initialize(
        string memory _info,
        string memory _baseURI,
        uint256 _gateFee,
        uint256 _percentCommission,
        uint256 _userLimit,
        uint256 _timeLimit,
        address _owner,
        address _RNCAddress,
        address _NFTAddress
        ) public initializer {
        info = _info;
        baseURI = _baseURI;
        gateFee = _gateFee;
        commission = gateFee * _percentCommission / 100;
        userLimit = _userLimit;
        if (_timeLimit > 0) {
            deadLine = block.timestamp + _timeLimit;
        }
        owner = _owner;
        RNCAddress = _RNCAddress;
        RNC = IRNC(_RNCAddress);
        NFTAddress = _NFTAddress;
        NFT = INFT(_NFTAddress);
        gateIsOpen = true;
        status = "open and active";
    }


/////////////    modifiers    /////////////
    modifier enterance() {
        require(gateIsOpen, "room expired");
        require(userLimit == 0 || userCount < userLimit, "sold out.");
        require(!userEntered[msg.sender], "signed in before.");
        _;
    }

    modifier canRoll() {
        require(RNCwithhold == RNC.generateFee(), "not enough RNC withhold");
        if(userLimit > 0 && deadLine > 0) {
            require(userCount == userLimit || block.timestamp >= deadLine, "reach time limit or user limit to activate dice");
        } else if (userLimit > 0) {
            require(userCount == userLimit, "reach user limit to activate dice");
        } else if (deadLine > 0) {
            require(block.timestamp >= deadLine, "you have to wait untill deadline pass");
        } else {
            require(msg.sender == owner, "only owner can call this function");
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    modifier onlyRNC() {
        require(msg.sender == RNCAddress, "caller is not the valid RNC");
        _;
    }


///////////// Sub Functions /////////////

    function secondsLeftToRollDice() public view returns(uint256 _secondsLeft) {
        uint256 timeNow = block.timestamp;
        if(deadLine > timeNow) {
            return deadLine - timeNow;
        } else {return 0;}
    }

    function usersNumberToRollDice() public view returns(uint256 _usersNeeded) {
        if(userLimit > userCount) {
            return userLimit - userCount;
        } else {return 0;}
    }

    function withdrawableSupply() public view returns(uint256){
        uint256 unavailable = RNCwithhold + prize;
        return address(this).balance - unavailable;
    }

    function deductRNCwithhold(uint256 value) private returns(uint256){
        uint256 requiredAmount = RNC.generateFee() - RNCwithhold;
        if(requiredAmount > 0){
            if(requiredAmount >= value){
                RNCwithhold += value;
                value = 0;
            }else{
                RNCwithhold += requiredAmount;
                value -= requiredAmount;
            }
        }
        return value;
    }

    function collectPrize(uint256 value) private {
        if(value > commission) {
            value -= commission;
            prize += value;
        }
    }

    function transferPrize() private {
        address payable reciever = payable(winner);
        reciever.transfer(prize);
        prize = 0;
    }


///////////// Main Functions /////////////

    // every person can enter ChanceRoom by paying gate fee
    // RNC withhold and commission will be deducted from incoming value
    // the rest of payment directly deposits to prize variable
    function buySeat() public enterance payable{
        address userAddress = msg.sender;
        uint256 userPayment = msg.value;

        require(userPayment == gateFee, "Wrong card fee entered");

        indexToAddr[userCount] = userAddress;
        userEntered[userAddress] = true;
        emit BuySeat(userAddress);

        userCount++;

        uint256 available = deductRNCwithhold(userPayment);
        collectPrize(available);

        if(userCount == userLimit){
            gateIsOpen = false;
            status = "Number of users has reach the quorum.";
        }
    }

    // rollDice can be called whenever deadline passed or number of users reached the qourum
    // if deadline and user limit have been set to zero, only owner of the contract can roll the dice
    // rollDice function will request RandomNumberConsumer for a 30 digits random number
    function rollDice() public canRoll {
        gateIsOpen = false;
        bytes4 selector = bytes4(keccak256(bytes("select(uint256)")));
        bytes32 requestId = RNC.getRandomNumber{value:RNCwithhold}(selector);
        RNCwithhold = 0;
        emit RollDice(requestId);
        status = "waiting for random number...";
    }

    // only RandomNumberConsumer can call this function
    // select function uses the 30 digits randomness sent by RNC to select winner address among users
    function select(uint256 randomness) public onlyRNC {
        uint256 randIndex = randomness % userCount;
        winner = indexToAddr[randIndex];
        emit Win(randIndex, winner, prize);
        transferPrize();
        NFT.safeMint(winner);
        status = "Finished.";
    }

    // withdraw commission by owner of the contract
    function withdrawCommission() public onlyOwner {
        address payable reciever = payable(owner);
        reciever.transfer(withdrawableSupply());
    }


///////////// Assurance Functions /////////////

    // owner can upgrade RNC in special cases (maybe not safe...)
    function upgradeRNC(address _RNCAddress) public onlyOwner{
        RNCAddress = _RNCAddress;
        RNC = IRNC(RNCAddress);
    }
    
    // charge contract in special cases  
    function charge() public payable{}

    // cancel the room and transfer user payments back
    function cancel() public onlyOwner {
        require(address(this).balance >= userCount * gateFee, "not enough cash to pay users");
        for(uint256 index = 0; index < userCount; index++) {
            address payable reciever = payable(indexToAddr[index]);
            reciever.transfer(gateFee);
        }
        prize = 0;
        gateIsOpen = false;
        status = "Canceled.";
    }
}