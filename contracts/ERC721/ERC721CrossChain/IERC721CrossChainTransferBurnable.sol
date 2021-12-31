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

interface IERC721CrossChainTransferBurnable {
    
    /**
     * @dev Emitted when `tokenId` token from `fromAddr` address is locked in this contract
     * to be regenerate in the same contract on `targetChainId` chain and transfer to `toAddr` address.
     */
    event TransferCrossChainRequest(
        uint256 indexed tokenId,
        address indexed fromAddr,
        address indexed toAddr,
        uint256 targetChainId
    );

    /**
     * @dev request to transfer `tokenId` token from `fromAddr` to `toAddr` on `targetChainId`.
     * 
     *  WARNING:
     * 
     * - if `toAddr` on `targetChainId` does not exist, token would be transfered back to from address.
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
        address fromAddr,
        address toAddr,
        uint256 targetChainId
    ) external;


    /**
     * @dev Burns `tokenId` on current chain.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * - The caller must own `tokenId` or be an approved operator.
     *
     * Emits a {Transfer} event.
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev Regenerates `tokenId` on current chain and transfers it to `toAddr`.
     * 
     * Requirements:
     *
     * - `tokenId` must not exist on current chain.
     * - `to` cannot be the zero address.
     * - only cross chain relayer can regenerate a token.
     *
     * Emits a {Transfer} event.
     */
    function regenerate(address to, uint256 tokenId) external;
}