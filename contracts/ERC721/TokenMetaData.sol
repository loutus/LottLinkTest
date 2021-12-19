// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ======================================================================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink =============

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract TokenMetaData is ERC721{

    mapping(uint256 => string) tokenPublicInfo;
    mapping(uint256 => string) private tokenPrivateInfo;
    mapping(uint256 => string) tokenPublicFileHash;
    mapping(uint256 => string) private tokenPrivateFileHash;

    function _setMetaData(
        uint256 tokenId,
        string memory _publicInfo,
        string memory _privateInfo,
        string memory _publicFileHash,
        string memory _privateFileHash
    ) internal {
        tokenPublicInfo[tokenId] = _publicInfo;
        tokenPrivateInfo[tokenId] = _privateInfo;
        tokenPublicFileHash[tokenId] = _publicFileHash;
        tokenPrivateFileHash[tokenId] = _privateFileHash;
    }

    function publicInfo(uint256 tokenId) external view returns(string memory _publicInfo) {
        require(_exists(tokenId), "TokenMetaData: nonexistent token");
        return tokenPublicInfo[tokenId];
    }

    function privateInfo(uint256 tokenId) external returns(string memory _privateInfo) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: you are not owner nor approved");
        return tokenPrivateInfo[tokenId];
    }

    function publicFileHash(uint256 tokenId) external view returns(string memory _publicFileHash) {
        require(_exists(tokenId), "TokenMetaData: nonexistent token");
        return tokenPublicFileHash[tokenId];
    }

    function privateFileHash(uint256 tokenId) external returns(string memory _privateFileHash) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: you are not owner nor approved");
        return tokenPrivateFileHash[tokenId];
    }
}