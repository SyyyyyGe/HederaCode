// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;


contract NFTFavor{

    mapping(address => uint256[])ownerToFavors;
    mapping(uint256 => mapping(address => uint256))FavorsIndex;

    

    //添加喜欢的nft
    function _addFavor(uint256 _tokenId)
    internal{
        address _to = msg.sender;
        ownerToFavors[_to].push(_tokenId);
        FavorsIndex[_tokenId][_to] = ownerToFavors[_to].length - 1; 
    }

    //删除喜欢的nft
    function _removeFavor(uint256 _tokenId)
    internal{
        address _from = msg.sender;
        uint256 targetFavorIndex = FavorsIndex[_tokenId][_from];
        uint256 lastFavorIndex = ownerToFavors[_from].length - 1;
        uint256 lastTokenId = ownerToFavors[_from][lastFavorIndex];
        ownerToFavors[_from][targetFavorIndex] = lastTokenId;
        ownerToFavors[_from].pop();
        delete FavorsIndex[_tokenId][_from];
    }

}