// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTAuctionInternal.sol";
import "../utils/ReentrancyGuard.sol";

contract NFTAuction is NFTAuctionInternal, ReentrancyGuard{
    
    //构造函数
    constructor(address _nftAddress){
        nonFungibleContract = NFTLast(_nftAddress);
    }
    function showAccountBalance()
    public
    view
    returns(uint256){
        return address(this).balance;
    }
    //展示一个人的竞拍的钱
    function showOnesBidding(address _target, uint256 _tokenId)
    public
    view
    virtual
    returns(uint256){
        return idToDeposits[_tokenId][_target];
    }

    //展示所有在交易的nft
    function showAllAuctions()
    public
    view
    virtual
    returns(Auction[] memory){
        return auctions;
    }

    //得到现在拍卖列表长度
    function getAuctionsLen()
    public
    view 
    virtual
    returns(uint256){
        return auctions.length;
    }
    
    //得到一个token的交易细节
    function getAuctionDetail(uint256 _tokenId)
    public
    view
    virtual
    returns(AuctionDetail[] memory){
        return idToAuctionDetail[_tokenId];
    }
    
    //创建拍卖
    function createAuction(uint256 _tokenId, uint256 _nowAmount, uint256 _duration)
    public
    canTransfer(_tokenId)
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
        require(_isOnBidding(_tokenId), "bid: _isOnAuction(auction)");
        uint256 price = auction.nowAmount;
        uint256 bidAmount = idToDeposits[_tokenId][msg.sender] + msg.value;
        require(bidAmount > price, "bid: msg.value > price");
        _bid(auction, _tokenId, bidAmount);
    }

    //取消拍卖
    function cancelAuction(uint256 _tokenId)
    public
    nonReentrant
    virtual{
        Auction memory auction = idToAuction[_tokenId];
        if(_isOnBidding(_tokenId)){
            address seller = auction.seller;
            require(seller == msg.sender || 
                nonFungibleContract.isApprovedForAll(seller, msg.sender) || 
                nonFungibleContract.getApproved(_tokenId) == msg.sender,
            "cancelAuction:canTransfer no power to transfer");
            _cancelAuction(_tokenId);
        }else{
            require(_isOnAuction(_tokenId), "cancelAuction: _isOnAuction(auction)");
            _cancelAuction(_tokenId);
        }
    }

    //通过tokenid获得一个拍卖
    function getAuction(uint256 _tokenId)
    public
    virtual
    returns(Auction memory) {
        Auction memory auction = idToAuction[_tokenId];
        require(_isOnAuction(_tokenId), "getAuction: _isOnAuction(_tokenId)");
        return auction;
    }

    //取钱
    function withdraw(uint256 _tokenId)
    public
    nonReentrant
    virtual{
        Auction memory auction = idToAuction[_tokenId];
        uint256 elapsedTime = block.timestamp - auction.startedAt;
        if(auction.startedAt > 0 && elapsedTime > auction.duration){
            _cancelAuction(_tokenId);
        }
        if(auction.startedAt > 0 && elapsedTime <= auction.duration){
            require(msg.sender != auction.winner, "withdraw :msg.sender != auction.winner");
        }
        _withdraw(_tokenId);
    }

}