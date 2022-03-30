// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTAuctionInternal.sol";


contract NFTAuction is NFTAuctionInternal{

    //构造
    constructor(address _nftAddress){
        nonFungibleContract = NFTLast(_nftAddress);
    }

    
    //展示所有在交易的nft
    function showAllNFTOnAuction()
    external
    view
    returns(Auction[] memory){
        return auctions;
    }

    function getAuctionsLen()
    external
    view 
    returns(uint256){
        return auctions.length;
    }
    
    //创建交易
    function createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration)
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration)
    external{
        require(_owns(msg.sender, _tokenId),
        "sunyao: createAuction _owns(msg.sender, _tokenId)");
        _createAuction(_tokenId, _startingPrice, _endingPrice, _duration, 100);
    }

    //创建交易
    function createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _offer)
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration)
    onlyOffer(_offer)
    external{
        require(_owns(msg.sender, _tokenId),
        "sunyao: createAuction _owns(msg.sender, _tokenId)");
        _createAuction(_tokenId, _startingPrice, _endingPrice, _duration, _offer);
    }

    //竞拍
    function bid(uint256 _tokenId)
    public
    payable{
        _bid(_tokenId, msg.value);
        _transferFrom(address(this), msg.sender, _tokenId);
    }

    //取消交易
    function cancelAuction(uint256 _tokenId)
    public{
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction),
        "sunyao: cancelAuction _isOnAuction(auction)");

        address seller = auction.seller;

        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    //通过tokenid获得一个交易
    function getAuction(uint256 _tokenId)
        public
        view
        returns(Auction memory) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return auction;
    }

    //得到当前价格
    function getCurrentPrice(uint256 _tokenId)
        public
        view
        returns (uint256){
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction),
        "sunyao:getCurrentPrice _isOnAuction(auction)");
        return _currentPrice(auction);
    }
    
    
}
