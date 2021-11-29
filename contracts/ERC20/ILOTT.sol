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

interface ILOTT{
    function pause() external;
    function unpause() external;
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}