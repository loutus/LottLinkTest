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

import "./DecentralAccess.sol";

/**
 * @dev this is an eternal contract which holds DAO contract address.
 */

contract DAOInit is DecentralAccess{

    address private _DAO;

    event DAOChanged(address indexed previousDAO, address indexed newDAO);

    /**
     * @dev returns the current DAO contract address.
     */
    function DAO() external view returns(address DAOAddr) {
        return _DAO;
    }

    /**
     * @dev Transfers ownership of the contract to a `_newDAO`.
     * Can only be called by the Gov.
     * 
     */
    function changeDAO(address newDAO) public onlyGov {
        address previousDAO = _DAO; 
        _DAO = newDAO;
        emit DAOChanged(previousDAO, newDAO);
    }
}