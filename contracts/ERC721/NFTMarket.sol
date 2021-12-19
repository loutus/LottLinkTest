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


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket{

    struct Offer {
        bool isForSale;
        address contAddr;
        uint tokenId;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        address contAddr;
        uint tokenId;
        address Bidder;
        uint value;
    }


    mapping(address => mapping(uint => Offer)) public tokensOfferedForSale;
    mapping(address => mapping(uint => Bid)) public tokenBids;
    mapping(address => uint) public pendingWithdrawals;

    event TokenOffered(address contAddr, uint indexed tokenId, uint minValue, address indexed toAddress);
    event TokenBidEntered(address contAddr, uint indexed tokenId, uint value, address indexed fromAddress);
    event TokenBidWithdrawn(address contAddr, uint indexed tokenId, uint value, address indexed fromAddress);
    event TokenBought(address contAddr, uint indexed tokenid, uint value, address indexed fromAddress, address indexed toAddress);
    event TokenNoLongerForSale(address contAddr, uint indexed tokenId);


    function offerTokenForSale(address contAddr, uint tokenId, uint minSalePriceInWei) public {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) == msg.sender, "market: you are not owner of this token");
        require(NFT.getApproved(tokenId) == address(this), "market: approve this contract as operator");
        tokensOfferedForSale[contAddr][tokenId] = Offer(true, contAddr, tokenId, msg.sender, minSalePriceInWei, address(0));
        emit TokenOffered(contAddr, tokenId, minSalePriceInWei, address(0));
    }

    function offerTokenForSaleToAddress(address contAddr, uint tokenId, uint minSalePriceInWei, address toAddress) public {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) == msg.sender, "market: you are not owner of this token");
        require(NFT.getApproved(tokenId) == address(this), "market: approve this contract as operator");
        tokensOfferedForSale[contAddr][tokenId] = Offer(true, contAddr, tokenId, msg.sender, minSalePriceInWei, toAddress);
        emit TokenOffered(contAddr, tokenId, minSalePriceInWei, toAddress);
    }

    function tokenNoLongerForSale(address contAddr, uint tokenId) public {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) == msg.sender, "market: you are not owner of this token");
        tokensOfferedForSale[contAddr][tokenId] = Offer(false, contAddr, tokenId, msg.sender, 0, address(0));
        emit TokenNoLongerForSale(contAddr, tokenId);
    }

    function buyToken(address contAddr, uint tokenId) public payable {
        IERC721 NFT = IERC721(contAddr);
        Offer memory offer = tokensOfferedForSale[contAddr][tokenId];
        require(offer.isForSale, "token is not for sale");
        if (offer.onlySellTo != address(0) && offer.onlySellTo != msg.sender) {
            revert("Market: not supposed to be sold to this user");
        }
        require(msg.value >= offer.minValue, "not enough eth");
        require(offer.seller == NFT.ownerOf(tokenId), "seller no longer owner of token");

        address seller = offer.seller;

        NFT.safeTransferFrom(seller, msg.sender, tokenId);
        pendingWithdrawals[seller] += msg.value;
        tokenNoLongerForSale(contAddr, tokenId);
        emit TokenBought(contAddr, tokenId, msg.value, seller, msg.sender);

        // Check for the case where there is a Bid from the new owner and refund it.
        // Any other Bid can stay in place.
        Bid memory bid = tokenBids[contAddr][tokenId];
        if (bid.Bidder == msg.sender) {
            // Kill the Bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;
            tokenBids[contAddr][tokenId] = Bid(false, contAddr, tokenId, address(0), 0);
        }
    }

    function enterBidForToken(address contAddr, uint tokenId) public payable {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) != msg.sender, "you already owned this token");
        require(msg.value != 0, "zero Bid value");
        Bid memory existing = tokenBids[contAddr][tokenId];
        require(msg.value >= existing.value, "you have to Bid at least equal to existing Bid");
        if (existing.value > 0) {
            // refund the failing Bid
            pendingWithdrawals[existing.Bidder] += existing.value;
        }
        tokenBids[contAddr][tokenId] = Bid(true, contAddr, tokenId, msg.sender, msg.value);
        emit TokenBidEntered(contAddr, tokenId, msg.value, msg.sender);
    }

    function withdrawBidForToken(address contAddr, uint tokenId) public {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) != msg.sender, "you already owned this token");
        Bid memory bid = tokenBids[contAddr][tokenId];
        require(bid.Bidder == msg.sender, "you have not Bid for this token");
        
        emit TokenBidWithdrawn(contAddr, tokenId, bid.value, msg.sender);
        tokenBids[contAddr][tokenId] = Bid(false, contAddr, tokenId, address(0), 0);
        // refund the Bid money
        address payable reciever = payable(msg.sender);
        reciever.transfer(bid.value);
    }

    function acceptBidForToken(address contAddr, uint tokenId, uint minPrice) public {
        IERC721 NFT = IERC721(contAddr);
        require(NFT.ownerOf(tokenId) == msg.sender, "market: you are not owner of this token");
        require(NFT.getApproved(tokenId) == address(this), "market: approve this contract as operator");
        Bid memory bid = tokenBids[contAddr][tokenId];
        require(bid.value != 0, "there is no Bid for this token");
        require(bid.value >= minPrice, "the Bid value is lesser than minPrice");
        address seller = msg.sender;
        NFT.safeTransferFrom(seller, bid.Bidder, tokenId);

        tokensOfferedForSale[contAddr][tokenId] = Offer(false, contAddr, tokenId, bid.Bidder, 0, address(0));
        tokenBids[contAddr][tokenId] = Bid(false, contAddr, tokenId, address(0), 0);
        pendingWithdrawals[seller] += bid.value;
        emit TokenBought(contAddr, tokenId, bid.value, seller, bid.Bidder);
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        address payable reciever = payable(msg.sender);
        reciever.transfer(amount);
    }
}