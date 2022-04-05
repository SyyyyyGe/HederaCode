// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../utils/SafeCast.sol";
import "../token/NFTProxy.sol";

contract NFTSaleInternal is NFTProxy{
    using SafeCast for uint256;
    /*
        直售数据
    */
    struct Sale{
        //当前NFT拥有者
        address payable seller;
        //初始价格(若初始价格和结束价格不同，则为动态价格)
        uint128 startingPrice;
        //结束价格(若设置动态价格，且持续时间为0，那么初始价格变化到结束价格事件默认为1个月)
        uint128 endingPrice;
        //持续时间(0表示永久销售)
        uint64 duration;
        //开始时间
        uint64 startedAt;
        //折扣(默认为100)
        uint8 discount;
    }

     /*
        交易历史
    */
    struct SaleDetail{
        //卖家
        address seller;
        //买家
        address buyer;
        //价格（单位wei）
        uint256 price;
    }

    //交易历史
    mapping(uint256 => SaleDetail[])internal idToSaleDetail;

    //直售列表
    Sale[] internal sales;

    //直售交易序列index
    mapping(uint256 => uint256)internal idToSaleIndex;

    //通过tokenid得到直售交易
    mapping(uint256 => Sale)internal idToSale;


    /*
        事件
    */

    //创建直售的事件
    event SaleCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 discount);

    //直售成功的事件
    event SaleSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    //直售取消的事件
    event SaleConcelled(uint256 tokenId);

    /*
        函数
    */
    /*
        Sale的函数
    */
    //创建交易
    function _createSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
    internal{
        address owner = _getOwner(_tokenId);
        _escrow(owner, _tokenId);
        Sale memory sale = Sale(
            payable(owner),
            _startingPrice.toUint128(),
            _endingPrice.toUint128(),
            _duration.toUint64(),
            block.timestamp.toUint64(),
            _discount.toUint8()
        );
        _addSale(_tokenId, sale);
    }

    //更新直售
    function _updateSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
    internal{
        Sale memory sale = idToSale[_tokenId];
        uint256 saleIndex = idToSaleIndex[_tokenId];
        sale.startingPrice = _startingPrice.toUint128();
        sale.endingPrice = _endingPrice.toUint128();
        sale.duration = _duration.toUint64();
        sale.discount = _discount.toUint8();
        sales[saleIndex] = sale;
        idToSale[_tokenId]= sale;
    }

    //增加直售
    function _addSale(uint256 _tokenId, Sale memory _sale)
    internal{
        require(_sale.duration >= 1 minutes || _sale.duration == 0,
        "_addSale: _sale.duration >= 1 minutes || _sale.duration == 0");

        idToSale[_tokenId] = _sale;
        sales.push(_sale);
        idToSaleIndex[_tokenId] = sales.length - 1;
        emit SaleCreated(
            uint256(_tokenId),
            uint256(_sale.startingPrice),
            uint256(_sale.endingPrice),
            uint256(_sale.duration),
            uint256(_sale.discount)
        );
    }

    //取消直售
    function _cancelSale(uint256 _tokenId, address _seller)
    internal{
        _removeSale(_tokenId);
        _transferFrom(address(this), _seller, _tokenId);
        emit SaleConcelled(_tokenId);
    }

    //购买
    function _buy(address _from, uint256 _tokenId)
    internal{
        _removeSale(_tokenId);
        (bool success,) = _from.call{value:msg.value}("");
        require(success, "seller's account may be abnormal");
        idToSaleDetail[_tokenId].push(SaleDetail(_from, msg.sender, msg.value));
        emit SaleSuccessful(_tokenId, msg.value, msg.sender);
    }

    //结束直售
    function _removeSale(uint256 _tokenId)
    internal{
        uint256 targetSaleIndex = idToSaleIndex[_tokenId];
        uint256 lastSaleIndex = sales.length - 1;
        sales[targetSaleIndex] = sales[lastSaleIndex];
        sales.pop();
        delete idToSaleIndex[_tokenId];
        delete idToSale[_tokenId];
    }

    //判断是不是在直售列表内（可能在直售，也可能已结过期，但是没删除）
    function _isOnSale(Sale memory _sale)
    internal
    pure
    returns(bool){
        return _sale.startedAt > 0;
    }

    //判断是不是没过期的直售
    function _isOnSelling(Sale memory _sale)
    internal
    view
    returns(bool){
        uint256 elapsedTime = block.timestamp - _sale.startedAt;
        return (_sale.startedAt > 0 && elapsedTime <= _sale.duration);
    }

    //得到当前价格,包含折扣
    function _currentPrice(Sale memory _sale)
    internal
    view
    returns(uint256){
        uint256 secondsPassed = 0;

        if(block.timestamp > _sale.startedAt){
            secondsPassed = block.timestamp - _sale.startedAt;
        }
        return _computeCurrentPrice(
            _sale.startingPrice,
            _sale.endingPrice,
            _sale.duration,
            secondsPassed,
            _sale.discount
        );
    }
    //得到当前价格，并且乘上折扣
    function _computeCurrentPrice(uint256 _startingPrice,uint256 _endingPrice,uint256 _duration,uint256 _secondsPassed, uint256 discount)
    internal
    pure
    returns(uint256){
        if(_duration == 0)_duration = 30 * 24 * 60 * 60;
        if (_secondsPassed >= _duration) {
            return _endingPrice * discount / 100;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            return uint256(currentPrice) * discount / 100;
        }
    }
}