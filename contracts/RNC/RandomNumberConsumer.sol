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
//   ============== Verify Random Function by ChainLink ===============

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRNC.sol";


contract RandomNumberConsumer is IRNC, VRFConsumerBase, Ownable {
    
    bytes32 internal keyHash;
    uint256 internal linkFee;
    address public DAOContract;
    
    AggregatorInterface internal priceFeed;

    mapping (bytes32 => Applicant) public applicants;

    struct Applicant{
        address contractAddress;
        bytes4 callBackSelector;
        uint256 randomResult;
    }


    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: MATIC MUMBAI
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     * Aggregator: LINK / MATIC
     * AggregatorAddress: 0x12162c3E810393dEC01362aBf156D7ecf6159528
     */
    constructor(address _DAOContract) 
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        DAOContract = _DAOContract;
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        linkFee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
        priceFeed = AggregatorInterface(0x12162c3E810393dEC01362aBf156D7ecf6159528);
    }


    /**
     * @dev See {IRNC-applicantFee}.
     */
    function applicantFee() external view returns(uint256 fee) {
        return uint256(priceFeed.latestAnswer() / 1000);
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
     * @dev Callback function used by VRF Coordinator
     *
     * fulfill applicant last info (randomness)
     * response to the applicant request
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
     * @dev Response function to the applicant contract.
     *
     * Requirements:
     *
     * - call back should be successful.
     * 
     * Emits a {Response} event.
     */
    function response(address contractAddress, bytes4 selector, uint256 randomResult) private {
        (bool success, bytes memory data) = contractAddress.call(abi.encodeWithSelector(selector, randomResult));
        require(success, "Could Not Response Randomness");
        emit Response(data);
    }
    
    
    /**
     * @dev Withdraw LINK function to avoid locking LINK in the contract
     */
    function withdrawLink(uint256 amount) external onlyOwner {
        address reciever = owner();
        LINK.transfer(reciever, amount);
    }
    

    /**
     * @dev Withdraw MATIC paid by applicants
     *
     * Requirements:
     *
     * - only owner can call this function.
     */
    function withdrawCash() external onlyOwner {
        address payable reciever = payable(owner());
        reciever.transfer(totalSupply());
    }
    

    /**
     * @dev Returns LINK supply of the contract
     */
    function linkSupply() public view returns(uint256){
        return LINK.balanceOf(address(this));
    }

    /**
     * @dev Returns MATIC supply of the contract
     */
    function totalSupply() public view returns(uint256){
        return address(this).balance;
    }

    /**
     * @dev request to DAO for link supply
     *
     * transfer all matic supply to DAO contract.
     */
    function requestForLink() public {
        (bool success, bytes memory data) = DAOContract.call{value:totalSupply()}(abi.encodeWithSignature("requestForLink"));
    }
}