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


interface IRNC {

    /**
     * @dev Emitted when an applicant requests for randomness.
     */
    event Request(bytes32 requestId);

    /**
     * @dev Emitted when RNC responses to the applicant.
     */
    event Response(bytes data);


    /**
     * @dev Returns cost of every random number generation which applicant should pay.
     */
    function applicantFee() external view returns(uint256 fee);

    /**
     * @dev Request for a 30 digits random number and record applicant's information.
     *
     * Applicant should provide a `call back selector` to receive the `random number`.
     * The `getRandomNumber function` takes `call back selector` as input.
     * RNC will then automatically response to applicant's selector.
     *
     * Requirements:
     *
     * - Enough LINK token should be available in RNC To generate a random number.
     * - Enough `msg.value` should be paid by the applicant to activate `getRandomNumber() payable`.
     *
     * Emits a {Request} event.
     */
    function getRandomNumber(bytes4 _callBackSelector) external payable returns(bytes32 requestId);
}