// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RandomNumberConsumer is VRFConsumerBase, Ownable {
    
    bytes32 internal keyHash;
    uint256 internal linkFee;
    uint256 public appFee;

    mapping (bytes32 => Applicant) public applicants;

    struct Applicant{
        address contractAddress;
        bytes4 callBackSelector;
        uint256 randomResult;
    }
    
    event Request(bytes32 requestId);
    event Response(bool success, bytes data);

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Matic Mainnet
     * Chainlink VRF Coordinator address: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
     * LINK token address:                0xb0897686c545045aFc77CF20eC7A532E3120E0F1
     * Key Hash: 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
     */
    constructor() 
        VRFConsumerBase(
            0x3d2341ADb2D31f1c5530cDC622016af293177AE0, // VRF Coordinator
            0xb0897686c545045aFc77CF20eC7A532E3120E0F1  // LINK Token
        )
    {
        keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
        linkFee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
        appFee = 0.01 * 10 ** 18;
    }
    

    /**
     1. check contract link supply
     2. check applicant matic value
     3. Request randomness
     4. Record applicant information
     5. emit request Id
     6. return request Id
     * RNC then responses to applicant corresponding to request Id
     * applicant should provide a selector receiving the randomness
     */
    function getRandomNumber(bytes4 _callBackSelector) public payable returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= linkFee, "Not enough LINK");
        require(msg.value >= appFee, "Not enough Matic");
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
        emit Response(success, data);
    }
    
    
    /**
     * withdraw LINK function to avoid locking LINK in the contract
     */
    function withdrawLink(uint256 amount) external onlyOwner {
        address reciever = owner();
        LINK.transfer(reciever, amount);
    }
    

    /**
     * withdraw matic paid by applicants
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