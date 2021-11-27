// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract ERC777Test is ERC777 {
    
    address[] _defaultOperators;

    constructor() ERC777("ERC777Test", "ERC777", _defaultOperators) {
        _mint(msg.sender, 10000, "", "");
    }
}