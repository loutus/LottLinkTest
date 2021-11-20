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
//   ============== Verify Random Function by ChainLink ===============

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../RNC/IRNC.sol";
import "../ERC721/INFT.sol";

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
    event StatusChanged(string newStatus);
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
<<<<<<< HEAD:contracts/ChanceRoom/ChanceRoom.sol
        status = "active";
=======
        status = "open";
        emit StatusChanged(status);
>>>>>>> TEST_1.0.5:contracts/ChanceRoom.sol
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

    /**
     * @dev Returns `_secondsLeft` to the deadline.
     */
    function secondsLeftToRollDice() public view returns(uint256 _secondsLeft) {
        uint256 timeNow = block.timestamp;
        if(deadLine > timeNow) {
            return deadLine - timeNow;
        } else {return 0;}
    }

    /**
     * @dev Returns the number of `_usersNeeded` to reach userLimit.
     */
    function usersNumberToRollDice() public view returns(uint256 _usersNeeded) {
        if(userLimit > userCount) {
            return userLimit - userCount;
        } else {return 0;}
    }

    /**
     * @dev Returns withdrawable supply stock in the contract(not including `prize` and `RNCWithhold`).
     */
    function withdrawableSupply() public view returns(uint256){
        uint256 unavailable = RNCwithhold + prize;
        return address(this).balance - unavailable;
    }

    /**
     * @dev Deduct the `RNCWithhold` from incomming value and return rest of it.
     */
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

    /**
     * @dev Deduct the `commission` and deposite the rest to the `prize`.
     */
    function collectPrize(uint256 value) private {
        if(value > commission) {
            value -= commission;
            prize += value;
        }
    }

    /**
     * @dev Transfer the `prize` to `winner` address.
     */
    function transferPrize() private {
        address payable reciever = payable(winner);
        reciever.transfer(prize);
        prize = 0;
    }


///////////// Main Functions /////////////

    /**
     * @dev every person can take some seats by paying `gateFee`.
     *
     * `RNCWthhold` and `commission` will be deducted from `userPayment`.
     * the rest of payment directly deposits to the `prize` variable.
     *
     * Requirements:
     *
     * - `userPayment` should be equal to the `gateFee`.
     * - The room should be `active` at the moment.
     * - `userLimit` should not be completed.
     *
     * Emits a {BuySeat} event.
     */
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
<<<<<<< HEAD:contracts/ChanceRoom/ChanceRoom.sol
            status = "user quorum reached.";
=======
            status = "user qourum reached";
            emit StatusChanged(status);
>>>>>>> TEST_1.0.5:contracts/ChanceRoom.sol
        }
    }

    /**
     * @dev Request for a random number to select the `winner` of the room.
     *
     * Requirements:
     *
     * - there should be enough cash in `RNCWithhold` to generate a random number.
     * - At least one of `timeLimit` and `userLimit` should be reached.
     * - If both `timeLimit` and `userLimit` are zero, only `owner` of the room can call this function.
     *
     * Emits a {RollDice} event.
     */
    function rollDice() public canRoll {
        gateIsOpen = false;
        bytes4 selector = bytes4(keccak256(bytes("select(uint256)")));
        bytes32 requestId = RNC.getRandomNumber{value:RNCwithhold}(selector);
        RNCwithhold = 0;
        emit RollDice(requestId);
        status = "waiting for RNC";
        emit StatusChanged(status);
    }

    /**
     * @dev select the `winner` by the random seat number.
     *
     * Requirements:
     *
     * - Only `RNC` can call this function.
     *
     * Emits a {Win} event.
     * Transfers the `prize` to the `winner`.
     * Mints an `NFT` to the `winner` address.
     */
    function select(uint256 randomness) public onlyRNC {
        uint256 randIndex = randomness % userCount;
        winner = indexToAddr[randIndex];
        emit Win(randIndex, winner, prize);
        transferPrize();
        NFT.safeMint(winner);
        status = "closed";
        emit StatusChanged(status);
    }

    /**
     * @dev Withdraw `commission` by `owner` of the contract.
     */
    function withdrawCommission() public onlyOwner {
        address payable reciever = payable(owner);
        reciever.transfer(withdrawableSupply());
    }


///////////// Assurance Functions /////////////

    /**
     * @dev Upgrade `RNC` in special cases (maybe not safe...).
     * 
     * Requirements:
     *
     * - Only `RNC` can call this function.
     */
    function upgradeRNC(address _RNCAddress) public onlyOwner{
        RNCAddress = _RNCAddress;
        RNC = IRNC(RNCAddress);
    }

    /**
     * @dev Charge the contract in special cases.
     */  
    function charge() public payable{}

    /**
     * @dev Cancel the chance room and transfer user payments back.
     *
     * Requirements:
     *
     * - Only `RNC` can call this function.
     */
    function cancel() public onlyOwner {
        require(address(this).balance >= userCount * gateFee, "not enough cash to pay users");
        for(uint256 index = 0; index < userCount; index++) {
            address payable reciever = payable(indexToAddr[index]);
            reciever.transfer(gateFee);
        }
        prize = 0;
        gateIsOpen = false;
        status = "canceled";
        emit StatusChanged(status);
    }
}