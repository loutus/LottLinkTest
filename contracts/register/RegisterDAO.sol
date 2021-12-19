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
//   =============== Verify Random Function by ChanLink ===============

import "../DAO/DAOCall.sol";
import "../ERC20/ILOTT.sol";

contract RegisterDAO is DAOCall{

    function LOTTToken() public view returns(ILOTT){
        address LOTTAddress = DAOGetAddress(keccak256("LOTT"));
        return ILOTT(LOTTAddress);
    }

    function registerSign(address signer, address presenter, bool pureSign) 
        public
        payable
        returns(bool completed)
    {
        ILOTT LOTT = LOTTToken();
        if(pureSign) {
            LOTT.mint(signer, DAOGetUint(keccak256("pureSignBonus")));
        } else {
            LOTT.mint(presenter, DAOGetUint(keccak256("normalSignBonus")));
        } if(presenter != address(0)) {
            LOTT.mint(presenter, DAOGetUint(keccak256("presenterBonus")));
        }
        return true;
    }

    /**
     * @dev Returns Ether supply of the contract
     */
    function EthSupply() public view returns(uint256){
        return address(this).balance;
    }

    /**
     * @dev Withdraw Eth paid by users
     *
     * Requirements:
     *
     * - only roll `withdrawAccess` can call this function.
     */
    function withdrawEth(address payable receiver, uint256 amount) external {
        receiver.transfer(amount);
    }
}