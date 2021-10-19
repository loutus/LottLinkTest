// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract LotteryProxy{
    address Lottery;

//// variables
    bool activeness;                //the contract is open and active now
    uint256 public userCount;       //number of users signed in till this moment
    uint256 public prize;           //the prize winner wins
    address public winner;          //winner of the game

//// constants
    string public info;             //summary information about purpose of the game
    string public baseURI;          //source of visual side of game
    uint256 public cardFee;         //price of every single card
    uint256 public commission;      //the wage of contract owner
    uint256 public userLimit;       //maximum number of users can sign in
    uint256 public deadLine;        //when getRandomNumber function unlocks (assuming not reach the quorum of users) 
    address public owner;           //owner of contract

    event Initialize(bool success, bytes data);
    event SignIn(bool success, bytes data);

    constructor(
        string memory _info,
        string memory _baseURI,
        uint256 _cardFee,
        uint256 _commission,
        uint256 _userLimit,
        uint256 _timeLimit,
        address _owner,
        address _Lottery
        ){
        Lottery = _Lottery;
        (bool success, bytes memory result) = Lottery.delegatecall(
            abi.encodeWithSignature(
                "initialize",
                _info,
                _baseURI,
                _cardFee,
                _commission,
                _userLimit,
                _timeLimit,
                _owner
            )
        );
        emit Initialize(success, result);
    }


    function signIn() public payable{
        (bool success, bytes memory data) = Lottery.delegatecall(abi.encodeWithSignature("signIn()"));
        emit SignIn(success, data);
    }

    function getRandomNumber() public {}

    function transferCommission() public {}

    function cancel() public {}
}
