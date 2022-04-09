// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTAuctionInternal.sol";
import "../utils/ReentrancyGuard.sol";
contract NFTAuction is NFTAuctionInternal, ReentrancyGuard{
    
    //构造函数
    constructor(address _nftAddress){
        nonFungibleContract = NFTLast(_nftAddress);
    }

    //展示一个人的竞拍的钱
    function showOnesBidding(address _target, uint256 _tokenId)
    public
    view
    virtual
    returns(uint256){
        return idToDeposits[_tokenId][_target];
    }

    //展示所有的拍卖
    function showAllAuctions()
    public
    view
    virtual
    returns(Auction[] memory){
        return auctions;
    }

    function showAuctionHistory(uint256 _tokenId)
    public
    view
    virtual
    returns(AuctionHistory[] memory){
        return idToAuctionHistory[_tokenId];
    }
    //得到现在拍卖列表长度
    function getAuctionsLen()
    public
    view 
    virtual
    returns(uint256){
        return auctions.length;
    }
    
    //得到一个token的拍卖细节
    function getAuctionDetail(uint256 _tokenId)
    public
    view
    virtual
    returns(AuctionDetail[] memory){
        return idToAuctionDetail[_tokenId];
    }
    
    //创建拍卖（nft的owner，operator，proxy可以进行对该nft拍卖）
    function createAuction(uint256 _tokenId, uint256 _nowAmount, uint256 _duration)
    public
    canOperator(_tokenId)
    virtual{
        _createAuction(_tokenId, _nowAmount, _duration);
    }

    //竞拍
    function bid(uint256 _tokenId)
    public
    nonReentrant
    virtual
    payable{
        Auction memory auction = idToAuction[_tokenId];
        require(_isOnBidding(auction), "bid: _isOnBidding(auction)");        
        uint256 price = auction.nowAmount;
        uint256 value = idToDeposits[_tokenId][msg.sender];
        uint256 bidAmount = value + msg.value;
        require(bidAmount > price, "bid: msg.value > price");
        _bid(auction, _tokenId, bidAmount, (value == 0));
    }

    //取消拍卖
    function cancelAuction(uint256 _tokenId)
    public
    nonReentrant
    virtual{
        Auction memory auction = idToAuction[_tokenId];
        require(auction.startedAt > 0, "cancelAuction: auction.startedAt > 0");
        uint256 elapsedTime = block.timestamp - auction.startedAt;
        if(elapsedTime <= auction.duration){
            address seller = auction.seller;
            require(_canOperator(seller), "cancelAuction: !_canOperator(seller)");
        }
        _cancelAuction(_tokenId, auction);
    }

    //通过tokenid获得一个拍卖
    function getAuction(uint256 _tokenId)
    public
    view
    virtual
    returns(Auction memory) {
        Auction memory auction = idToAuction[_tokenId];
        require(_isOnAuction(auction), "getAuction: _isOnAuction(_tokenId)");
        return auction;
    }

    //取钱
    function withdraw()
    public
    nonReentrant
    virtual{
        _withdraw();
    }

}