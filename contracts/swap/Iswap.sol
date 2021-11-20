// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.6 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   ============== Verify Random Function by ChainLink ===============

interface Iswap{

    /**
     * @dev Emitted when an applicant requests for randomness.
     */
    event Swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    /**
     * @dev swaps `_amountIn` of `_tokenIn` to `_tokenOut`.
     *
     * uses `swapExactInputSingle` function in uniswap V3,
     * which swap a fixed amount of one token for a maximum possible amount of another token.
     * 
     * Requirements:
     *
     * - 
     * - 
     * - 
     *
     * Emits a {Swap} event.
     */
    function swapExactInputSingle(address _tokenIn, address _tokenOut, uint256 amountIn) external returns (uint256 amountOut);
}