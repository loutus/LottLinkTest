// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.3 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink ===============

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRNC.sol";


contract RandomNumberConsumer is IRNC, VRFConsumerBase, Ownable {
    
    bytes32 internal keyHash;
    uint256 internal linkFee;
    uint256 internal appFee;

    mapping (bytes32 => Applicant) public applicants;

    struct Applicant{
        address contractAddress;
        bytes4 callBackSelector;
        uint256 randomResult;
    }

    /**
     * @dev Emitted when an applicant requests for randomness.
     */
    event Request(bytes32 requestId);


    /**
     * @dev Emitted when RNC responses to the applicant.
     */
    event Response(bytes data);

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: MATIC MUMBAI
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     */
    constructor() 
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        linkFee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
        appFee = 0.01 * 10 ** 18;
    }


    /**
     * @dev See {IRNC-generateFee}.
     */
    function generateFee() external view returns(uint256 fee) {
        return appFee;
    }


    /**
     * @dev See {IRNC-getRandomNumber}.
     */
    function getRandomNumber(bytes4 _callBackSelector) public payable returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= linkFee, "Not enough LINK");
        require(msg.value >= appFee, "Not enough MATIC");
        requestId = requestRandomness(keyHash, linkFee);
        applicants[requestId] = Applicant(msg.sender, _callBackSelector, 0);
        emit Request(requestId);
        return requestId;
    }

    /**
     * Callback function used by VRF Coordinator
     1. fulfill applicant last info (randomness)
     2. response to the applicant request
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        applicants[requestId].randomResult = randomness;
        Applicant memory app = applicants[requestId];
        response(
            app.contractAddress,
            app.callBackSelector,
            app.randomResult
        );
    }

    /**
     * Response function to the applicant contract
     1. call back the selector provided by the applicant
     2. emit Response
     */
    function response(address contractAddress, bytes4 selector, uint256 randomResult) private {
        (bool success, bytes memory data) = contractAddress.call(abi.encodeWithSelector(selector, randomResult));
        require(success, "Could Not Response Randomness");
        emit Response(data);
    }
    
    
    /**
     * withdraw LINK function to avoid locking LINK in the contract
     */
    function withdrawLink(uint256 amount) external onlyOwner {
        address reciever = owner();
        LINK.transfer(reciever, amount);
    }
    

    /**
     * withdraw MATIC paid by applicants
     * only owner can call this function
     */
    function withdrawCash() external onlyOwner {
        address payable reciever = payable(owner());
        reciever.transfer(totalSupply());
    }
    

    /**
     * return LINK supply of the contract
     */
    function linkSupply() public view returns(uint256){
        return LINK.balanceOf(address(this));
    }

    /**
     * return MATIC supply of the contract
     */
    function totalSupply() public view returns(uint256){
        return address(this).balance;
    }
}