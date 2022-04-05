// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../utils/SafeCast.sol";
import "../token/NFTProxy.sol";

abstract contract NFTAuctionInternal is NFTProxy{

    using SafeCast for uint256;
    /*
        拍卖
    */
    struct Auction{
        //售卖的人
        address payable seller;
        //拍卖出最高价的人
        address payable winner;
        //目前拍卖价格
        uint128 nowAmount;
        //拍卖时间
        uint64 duration;
        //拍卖开始时间
        uint64 startedAt;
    }
    //拍卖列表
    Auction[] internal auctions;

    //存储交易序列index
    mapping(uint256 => uint256)internal idToAuctionIndex;

    //通过tokenid得到交易
    mapping(uint256 => Auction)internal idToAuction;

    //通过id和address得到一个用户在这个拍卖存了多少钱
    mapping(uint256 => mapping(address => uint256))idToDeposits;

    /*
        交易历史
    */
    struct AuctionDetail{
        //卖家
        address seller;
        //买家
        address buyer;
        //价格（单位wei）
        uint256 price;
    }

    //交易历史
    mapping(uint256 => AuctionDetail[])internal idToAuctionDetail;

    /*
        事件
    */

    //创建拍卖的事件
    event AuctionCreated(uint256 tokenId, uint256 nowAmount, uint256 duration);

    //拍卖成功的事件
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    //拍卖取消的事件
    event AuctionConcelled(uint256 tokenId);

    //取钱成功的事件
    event WithdrawSuccessful(address from, uint256 amount);

    //取钱失败的事件
    event WithdrawLoss(address from, uint256 amount);
    
    
    //创建拍卖
    function _createAuction(uint256 _tokenId, uint256 _nowAmount, uint256 _duration)
    internal{
        address owner = _getOwner(_tokenId);
        _escrow(owner, _tokenId);
        Auction memory auction = Auction(
            payable(owner),
            payable(owner),
            _nowAmount.toUint128(),
            _duration.toUint64(),
            block.timestamp.toUint64()
        );
        _addAuction(_tokenId, auction);
         emit AuctionCreated(
            uint256(_tokenId),
            uint256(_nowAmount),
            uint256(_duration)
        );
    }


    //增加拍卖
    function _addAuction(uint256 _tokenId, Auction memory _auction)
    internal{
        require(_auction.duration >= 1 minutes,
        "_addAuction: _auction.duration >= 1 minutes");
        idToAuction[_tokenId] = _auction;
        auctions.push(_auction);
        idToAuctionIndex[_tokenId] = auctions.length - 1; 
    }

    //取消拍卖
    function _cancelAuction(uint256 _tokenId)
    internal{
        Auction memory auction = idToAuction[_tokenId];
        address _winner = auction.winner;
        address _seller = auction.seller;
        _transferFrom(address(this), _winner, _tokenId);
        _removeAuction(_tokenId);
        uint256 value = idToDeposits[_tokenId][_winner];
        idToDeposits[_tokenId][_winner] = 0;
        (bool success, ) = _seller.call{value:value}("");
        require(success, "cancelAuction lose");
        idToAuctionDetail[_tokenId].push(AuctionDetail(_seller, _winner, value));
        emit AuctionConcelled(_tokenId);
    }

    //竞拍
    function _bid(Auction memory _auction, uint256 _tokenId, uint256 _bidAmount)
    internal{
        _updateAuction(_auction, _tokenId, payable(msg.sender), _bidAmount);
        idToDeposits[_tokenId][msg.sender] = _bidAmount;
    }

    //更新拍卖
    function _updateAuction(Auction memory _auction, uint256 _tokenId, address payable _winner, uint256 _nowAmount)
    internal{
        _auction.winner = _winner;
        _auction.nowAmount = _nowAmount.toUint128();
        uint256 targetAuctionIndex = idToAuctionIndex[_tokenId];
        auctions[targetAuctionIndex] = _auction;
        idToAuction[_tokenId] = _auction;
    }

    //拍卖结束
    function _removeAuction(uint256 _tokenId)
    internal{
        uint256 targetAuctionIndex = idToAuctionIndex[_tokenId];
        uint256 lastAuctionIndex = auctions.length - 1;
        auctions[targetAuctionIndex] = auctions[lastAuctionIndex];
        auctions.pop();
        delete idToAuctionIndex[_tokenId];
        delete idToAuction[_tokenId];
    }

    //取钱
    function _withdraw(uint256 _tokenId)
    internal
    returns(bool){
        uint256 _value = idToDeposits[_tokenId][msg.sender];
        if(_value > 0){
            idToDeposits[_tokenId][msg.sender] = 0;
            (bool success, ) = msg.sender.call{value:_value}("");
            if(success)emit WithdrawSuccessful(msg.sender, _value);
            else emit WithdrawLoss(msg.sender, _value);
            return success;
        }
        return false;
    }

    //判断是不是在拍卖
    function _isOnAuction(uint256 _tokenId)
    internal
    view
    returns(bool){
        Auction memory _auction = idToAuction[_tokenId];
        return _auction.startedAt > 0;
    }

    //判断是不是在拍卖
    function _isOnBidding(uint256 _tokenId)
    internal
    view
    returns(bool){
        Auction memory _auction = idToAuction[_tokenId];
        uint256 elapsedTime = block.timestamp - _auction.startedAt;
        return _auction.startedAt > 0 && elapsedTime <= _auction.duration;
    }

    receive() external payable{

    }
    
}