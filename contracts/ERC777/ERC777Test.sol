// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC777/presets/ERC777PresetFixedSupply.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

/**
 * @dev {ERC777} token, including:
 *
 *  - Preminted initial supply
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *
 * _Available since v3.4._
 */
contract LOTTTest is ERC777 {

    address[] _defaultOperators = [0x54D7C27Ad926639065932Aa91f5A45133C6b56B5];


    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC777-constructor}.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) ERC777(name, symbol, _defaultOperators) {
        _mint(owner, initialSupply, "", "");
    }

    function mint(uint256 amount, address receiver) public {
        _mint(receiver, amount, "", "");
    }
}