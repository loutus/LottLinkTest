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


abstract contract DecentralAccess {

    address private _gov;

    event GovChanged(address indexed previousGov, address indexed newGov);

    /**
     * @dev Initializes the contract setting the deployer as the initial Gov.
     */
    constructor() {
        _gov = msg.sender;
    }

    /**
     * @dev Restrict access to the Gov.
     */
    modifier onlyGov {
        require(msg.sender == _gov);
        _;
    }

    /**
     * @dev Returns the address of the current Gov.
     */
    function gov() external view virtual returns (address) {
        return _gov;
    }

    /**
     * @dev Change the Governance ecosystem in epecial cases.
     */
    function changeGov(address newGov) public onlyGov {
        address previousGov = _gov;
        _gov = newGov;
        emit GovChanged(previousGov, newGov);
    }
}