// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./nft-auction-internal.sol";

contract ClockAuction is ClockAuctionBase{

    constructor(address _nftAddress){
        nonFungibleContract = NFTEnumerable(_nftAddress);
    }

    function createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration)
    public
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration){
        require(_owns(msg.sender, _tokenId),
        "sunyao: createAuction _owns(msg.sender, _tokenId)");
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            payable(msg.sender),
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(block.timestamp)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId)
    public
    payable{
        Auction storage auction = tokenIdToAuction[_tokenId];
        address seller = auction.seller;
        _bid(_tokenId, msg.value);
        _transferFrom(seller, msg.sender, _tokenId);
    }

    function cancelAuction(uint256 _tokenId)
    public{
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction),
        "sunyao: cancelAuction _isOnAuction(auction)");

        address seller = auction.seller;

        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    function getAuction(uint256 _tokenId)
        public
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    function getCurrentPrice(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction),
        "sunyao:getCurrentPrice _isOnAuction(auction)");
        return _currentPrice(auction);
    }
}
