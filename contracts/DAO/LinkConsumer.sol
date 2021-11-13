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

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract LinkConsumer is AccessControlEnumerable{

    uint256 internal linkValue;
    LinkTokenInterface immutable internal LINK;

    bytes32 public constant RNC_ROLE = keccak256("RNC_ROLE");

    /**
     * Constructor
     * 
     * Network: MATIC MUMBAI
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Aggregator: LINK / MATIC
     */
    constructor(){
        LINK = LinkTokenInterface(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);  // LINK Token MUMBAI
        linkValue = 0.001 * 10 ** 18; // 0.001 LINK for 10 generation random number (Varies by network)

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(RNC_ROLE, _msgSender());
    }

    /**
     * return LINK supply of the contract
     */
    function linkSupply() public view returns(uint256){
        return LINK.balanceOf(address(this));
    }

    /**
     * @dev charge RNC contract with enough LINK supply for 10 generations.
     * 
     * Requirements:
     *
     * - caller should be a valid RNC.
     */
    function requestForLink() external payable returns(bool) {
        require(hasRole(RNC_ROLE, _msgSender()), "caller should be a valid RNC");
        LINK.transfer(_msgSender(), linkValue);
        return true;
    }
}