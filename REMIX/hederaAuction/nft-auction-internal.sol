// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../hederaToken/nft-enumerable.sol";

contract ClockAuctionBase{
    struct Auction{

        //当前NFT拥有者
        address payable seller;
        //初始价格
        uint128 startingPrice;
        //结束价格
        uint128 endingPrice;
        //持续时间
        uint64 duration;
        //开始时间
        uint64 startedAt;
    }

    NFTEnumerable public nonFungibleContract;
    mapping(uint256 => Auction)tokenIdToAuction;
    mapping(uint256 => address[])tokenIdToHistory;
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);

    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    event AuctionConcelled(uint256 tokenId);


    modifier canBeStoredWith64Bits(uint256 _value) {
        require(_value <= 18446744073709551615);
        _;
    }

    modifier canBeStoredWith128Bits(uint256 _value) {
        require(_value < 340282366920938463463374607431768211455);
        _;
    }

    //判断claimant是不是tokenid的拥有者
    function _owns(address _claimant, uint256 _tokenId)
    internal
    view
    returns(bool){
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    //托管NFT给这个合约，用来拍卖
    function _escrow(address _owner, uint256 _tokenId)
    internal{
        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }

    //转账交易
    function _transferFrom(address _from, address _to, uint256 _tokenId)
    internal{
        nonFungibleContract.transferFrom(_from, _to, _tokenId);
    }
    

    //增加拍卖
    function _addAuction(uint256 _tokenId, Auction memory _auction)
    internal{
        require(_auction.duration >= 1 minutes,
        "sunyao:_addAuction _auction.duration >= 1 minutes");

        tokenIdToAuction[_tokenId] = _auction;
        tokenIdToHistory[_tokenId].push(msg.sender);
        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    //取消拍卖
    function _cancelAuction(uint256 _tokenId, address _seller)
    internal{
        _removeAuction(_tokenId);
        _transferFrom(address(this), _seller, _tokenId);
        emit AuctionConcelled(_tokenId);
    }

    function _bid(uint256 _tokenId, uint256 _bidAmount)
    internal
    returns(uint256){
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction),
        "sunyao:_bid _isOnAuction(auction)");
        uint256 price = _currentPrice(auction);
        require(_bidAmount > price,
        "sunyao:_bid _bidAmount > price");

        address payable seller = auction.seller;

        _removeAuction(_tokenId);

        if(price > 0){
            uint256 sellerProceeds = price;
            seller.transfer(sellerProceeds);
        }
        tokenIdToHistory[_tokenId].push(msg.sender);
        emit AuctionSuccessful(_tokenId, price, msg.sender);
        return price;
    }

    //拍卖结束
    function _removeAuction(uint256 _tokenId)
    internal{
        delete tokenIdToAuction[_tokenId];
    }

    //判断是不是在拍卖
    function _isOnAuction(Auction storage _auction)
    internal
    view
    returns(bool){
        return (_auction.startedAt > 0);
    }

    function _currentPrice(Auction storage _auction)
    internal
    view
    returns(uint256){
        uint256 secondsPassed = 0;

        if(block.timestamp > _auction.startedAt){
            secondsPassed = block.timestamp - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    function _computeCurrentPrice(uint256 _startingPrice,uint256 _endingPrice,uint256 _duration,uint256 _secondsPassed)
    internal
    pure
    returns(uint256){
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            
            return uint256(currentPrice);
        }
    }
    
}