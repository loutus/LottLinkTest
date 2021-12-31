// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./TokenMetaData.sol";


contract LOTTNFT is ERC721, ERC721URIStorage, Ownable, ERC721Burnable, TokenMetaData {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("LOTTNFT", "LOTTNFT") {}

    function safeMint(
        address to,
        string memory uri,
        string memory publicInfo,
        string memory privateInfo,
        string memory publicFileHash,
        string memory privateFileHash
    ) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _setMetaData(
            tokenId,
            publicInfo,
            privateInfo,
            publicFileHash,
            privateFileHash
        );
    }


    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}