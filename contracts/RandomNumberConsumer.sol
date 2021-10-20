// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract RandomNumberConsumer is VRFConsumerBase, Ownable {
    
    bytes32 internal keyHash;
    uint256 internal linkFee;
    uint256 internal maticFee;

    mapping (bytes32 => Applicant) public applicants;

    struct Applicant{
        address contractAddress;
        bytes4 callBackSelector;
        uint256 randomResult;
    }
    
    event Response(bool success, bytes data);

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: mumbai
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
        maticFee = 0.1 * 10 ** 18;
    }
    

    /** 
     * Requests randomness 
     */
    function getRandomNumber(bytes4 _callBackSelector) public payable {
        require(msg.value >= maticFee, "Not enough Matic");
        require(LINK.balanceOf(address(this)) >= linkFee, "Not enough LINK");
        bytes32 requestId = requestRandomness(keyHash, linkFee);
        applicants[requestId] = Applicant(msg.sender, _callBackSelector, 0);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        applicants[requestId].randomResult = randomness;
        Applicant memory app = applicants[requestId];
        callBack(
            app.contractAddress,
            app.callBackSelector,
            app.randomResult
        );
    }

    /**
     * Callback function to the applicant contract
     */
    function callBack(address contractAddress, bytes4 selector, uint256 randomResult) private {
        (bool success, bytes memory data) = contractAddress.call(abi.encodeWithSelector(selector, randomResult));
        emit Response(success, data);
    }
    
    
    // Implement a withdraw function to avoid locking your LINK in the contract
    function withdrawLink() external onlyOwner {
        address reciever = owner();
        LINK.transfer(reciever, linkSupply());
    }
    
    function withdrawMatic() external onlyOwner {
        address payable reciever = payable(owner());
        reciever.transfer(maticSupply());
    }
    
    function linkSupply() public view returns(uint256){
        return LINK.balanceOf(address(this));
    }
    
    function maticSupply() public view returns(uint256){
        return address(this).balance;
    }
}