// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./NFTLast.sol";
import "../utils/AddressProxy.sol";


contract NFTProxy is AddressProxy{
    NFTLast nonFungibleContract;
    
    //确保能够操作
    modifier canOperator(uint256 _tokenId){
        address owner = nonFungibleContract.ownerOf(_tokenId);
        require(owner == msg.sender || 
                nonFungibleContract.isApprovedForAll(owner, msg.sender) || 
                getProxy(owner) == msg.sender,
            "NFTProxy:canOperator no power to operate");
        _;
    }
    //确保授权人交易, 要求满足之一：拥有者， 被授权者， 授权者
    modifier canTransfer(uint256 _tokenId){
        address owner = nonFungibleContract.ownerOf(_tokenId);
        require(owner == msg.sender || 
                nonFungibleContract.isApprovedForAll(owner, msg.sender) || 
                nonFungibleContract.getApproved(_tokenId) == msg.sender ||
                getProxy(owner) == msg.sender,
            "NFTProxy:canTransfer no power to transfer");
        _;
    }
    //确保NFT可以被交易，要求：当前NFT已被开采
    modifier validNFT(uint256 _tokenId){
        require(nonFungibleContract.ownerOf(_tokenId) != address(0),
            "NFTProxy:validNFT invalid NFT");
        _;
    }
    
     //判断claimant是不是tokenid的拥有者
    function _owns(address _claimant, uint256 _tokenId)
    internal
    view
    returns(bool){
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    //托管NFT给这个合约，用来交易
    function _escrow(address _owner, uint256 _tokenId)
    internal{
        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }

    //转账交易
    function _transferFrom(address _from, address _to, uint256 _tokenId)
    internal{
        nonFungibleContract.transferFrom(_from, _to, _tokenId);
    }
    
    //得到拥有者
    function _getOwner(uint256 _tokenId)
    internal
    view
    returns(address){
        return nonFungibleContract.ownerOf(_tokenId);
    }

    function _canTransfer(address _seller, uint256 _tokenId)
    internal 
    view
    returns(bool){
        return (_seller == msg.sender || 
                nonFungibleContract.isApprovedForAll(_seller, msg.sender) || 
                nonFungibleContract.getApproved(_tokenId) == msg.sender ||
                getProxy(_seller) == msg.sender);
    }

    function _canOperator(address _seller)
    internal 
    view
    returns(bool){
        return (_seller == msg.sender || 
                nonFungibleContract.isApprovedForAll(_seller, msg.sender) || 
                getProxy(_seller) == msg.sender);
    }

    function _setIdToStatus(uint256 _tokenId, uint256 _status)
    internal{
        nonFungibleContract.setidToStatus(_tokenId, _status);
    }

    function _getIdToStatus(uint256 _tokenId)
    internal
    view
    returns(uint256){
        return nonFungibleContract.getidToStatus(_tokenId);
    }
}