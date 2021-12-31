// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC20Transparent is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {initialize();}

    function initialize() initializer public {
        __ERC20_init("ERC20Transparent", "ERC20T");
        __Ownable_init();
    } 

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}