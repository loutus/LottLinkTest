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

interface IERC721CrossChainTransfer {
    
    /**
     * @dev Emitted when `tokenId` token from `from` address is locked in this contract
     * to be redeem in the same contract on `targetChainId` chain and transfer to `to` address.
     */
    event TransferCrossChainRequest(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        uint256 targetChainId
    );

    /**
     * @dev Lock the `tokenId` from `from` in this contract to be be regenerated on `targetChainId` and transfer to `to`.
     * 
     *  WARNING:
     * 
     * - if `to` on `targetChainId` does not exist, token would be transfered back to from address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     * 
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {TransferCrossChainRequest} event.
     */
    function transferCrossChainRequest(
        uint256 tokenId,
        address from,
        address to,
        uint256 targetChainId
    ) external;


    /**
     * @dev Redeems `tokenId` on current chain and transfers it to its owner.
     * 
     * Requirements:
     *
     * - only Cross Chain relayer can redeem a token.
     */
    function redeem(address to, uint256 tokenId) external;
}