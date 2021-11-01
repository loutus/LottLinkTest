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


interface IRNC {


    /**
     * @dev Returns cost of every random number generation, applicant should pay.
     */
    function generateFee() external view returns(uint256 fee);

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