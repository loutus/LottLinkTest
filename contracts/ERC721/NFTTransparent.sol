// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTTransparent is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor

    uint public x;

    // constructor() initializer {}

    function initialize() initializer public {
        __ERC721_init("MyToken", "MTK");
        __Ownable_init();
        x = 7;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function upgradetest(uint256 _x) public{
        x = _x;
    }
}