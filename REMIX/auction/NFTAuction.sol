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
    virtual
    returns(Auction[] memory){
        return auctions;
    }

    //得到现在交易列表长度
    function getAuctionsLen()
    external
    view 
    virtual
    returns(uint256){
        return auctions.length;
    }
    
    //得到一个token的交易细节
    function getAuctionDetail(uint256 _tokenId)
    external
    view
    virtual
    returns(AuctionDetail[] memory){
        return tokenIdToAuctionDetail[_tokenId];
    }
    
    //创建交易
    function createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration)
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration)
    external
    virtual{
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
    external
    virtual{
        require(_owns(msg.sender, _tokenId),
        "sunyao: createAuction _owns(msg.sender, _tokenId)");
        _createAuction(_tokenId, _startingPrice, _endingPrice, _duration, _offer);
    }

    //竞拍
    function bid(uint256 _tokenId)
    public
    virtual
    payable{
        _bid(_tokenId, msg.value);
        _transferFrom(address(this), msg.sender, _tokenId);
    }

    function updateAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _offer)
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration)
    onlyOffer(_offer)
    external
    virtual{
        require(_isOnAuction(_tokenId), "_updateAuction:_isOnAuction(auction)");
        require(tokenIdToAuction[_tokenId].seller == msg.sender, "_updateAuction:tokenIdToAuction[_tokenId].seller == msg.sender");
        _updateAuction(_tokenId, _startingPrice, _endingPrice, _duration, _offer);
    }
    //取消交易
    function cancelAuction(uint256 _tokenId)
    public
    virtual{
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(_tokenId),
        "sunyao: cancelAuction _isOnAuction(auction)");

        address seller = auction.seller;

        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    //通过tokenid获得一个交易
    function getAuction(uint256 _tokenId)
    public
    virtual
    returns(Auction memory) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(_tokenId));
        return auction;
    }

    //得到当前价格
    function getCurrentPrice(uint256 _tokenId)
    public
    virtual
    returns (uint256){
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(_tokenId),
        "sunyao:getCurrentPrice _isOnAuction(auction)");
        return _currentPrice(auction);
    }
    
    
}
