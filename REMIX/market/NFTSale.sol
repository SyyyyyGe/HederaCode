// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSaleInternal.sol";
import "../utils/ReentrancyGuard.sol";

contract NFTSale is NFTSaleInternal, ReentrancyGuard{
    //构造函数
    constructor(address _nftAddress){
        nonFungibleContract = NFTLast(_nftAddress);
    }


    //展示所有在交易的nft
    function showAllSales()
    public
    view
    virtual
    returns(Sale[] memory){
        return sales;
    }

    //得到现在直售列表长度
    function getSalesLen()
    public
    view 
    virtual
    returns(uint256){
        return sales.length;
    }

    //得到一个token的交易细节
    function getSaleDetail(uint256 _tokenId)
    public
    view
    virtual
    returns(SaleDetail[] memory){
        return idToSaleDetail[_tokenId];
    }
    
    //创建直售
    function createSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration)
    public
    canTransfer(_tokenId)
    virtual{
        _createSale(_tokenId, _startingPrice, _endingPrice, _duration, 100);
    }

    
    //创建直售
    function createSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
    public
    canOperator(_tokenId)
    virtual{
        require(_discount <= 100, "createSale: _discount <= 100");
        _createSale(_tokenId, _startingPrice, _endingPrice, _duration, _discount);
    }

     //msg.sender购买token
    function buy(uint256 _tokenId)
    public
    nonReentrant
    virtual
    payable{
        Sale memory sale = idToSale[_tokenId];
        require(_isOnSelling(sale),"buy: _isOnSelling(_tokenId)");
        uint256 price = _currentPrice(sale);
        require(msg.value >= price,"buy: _buyAmount >= price");
        _buy(sale.seller, _tokenId);
        _transferFrom(address(this), msg.sender, _tokenId);
    }

     //msgsender更新直售
    function updateSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
    public
    virtual{
        Sale memory sale = idToSale[_tokenId];
        require(_canOperator(sale.seller), "updateSale: !_canOperator(sale.seller)");
        require(_discount <= 100, "updateSale:_discount <= 100");
        require(_isOnSelling(sale), "updateSale:_isOnSelling(_tokenId)");
        _updateSale(_tokenId, _startingPrice, _endingPrice, _duration, _discount);
    }

    //取消直售
    function cancelSale(uint256 _tokenId)
    public
    nonReentrant
    virtual{
        Sale memory sale = idToSale[_tokenId];
        require(_canOperator(sale.seller), "updateSale: !_canOperator(sale.seller)");
        require(_isOnSale(sale), "cancelSale: _isOnSale(_tokenId)");
        address seller = sale.seller;
        _cancelSale(_tokenId, seller);
    }

    //通过tokenid得到一个直售
    function getSale(uint256 _tokenId)
    public
    view
    virtual
    returns(Sale memory) {
        Sale memory sale = idToSale[_tokenId];
        require(_isOnSale(sale), "getSale: _isOnSale(_tokenId)");
        return sale;
    }

    //得到当前价格
    function getCurrentPrice(uint256 _tokenId)
    public
    view
    virtual
    returns (uint256){
        Sale memory sale = idToSale[_tokenId];
        require(_isOnSelling(sale), "getCurrentPrice: _isOnSale(sale)");
        return _currentPrice(sale);
    }
}