// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.2 ==============================
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
     * - 
     * - 
     *
     * Emits a {SignIn} event.
     */
    /**
     1. check contract link supply
     2. check applicant MATIC value
     3. Request randomness
     4. Record applicant information
     5. emit request Id
     6. return request Id
     * RNC then responses to applicant corresponding to request Id
     * applicant should provide a selector receiving the randomness
     */
    function getRandomNumber(bytes4 _callBackSelector) external payable returns(bytes32 requestId);
}