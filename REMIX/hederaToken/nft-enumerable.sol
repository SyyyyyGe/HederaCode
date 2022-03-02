// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./erc721-enumerable.sol";
import "./nft.sol";
import "../hederautils/is-contract-lib.sol";


contract NFTEnumerable is NFT, ERC721Enumerable{
    using AddressUtils for address;
    //记录总的tokens
    uint256[] internal tokens;
    
    //记录一个tokenId对应在tokens的位置
    mapping(uint256 => uint256)internal idToIndex;

    //记录一个owner拥有的所有tokenId
    mapping(address => uint256[])internal ownerToIds;

    //记录一个tokenid在owner的tokens中index是多少
    mapping(uint256 => uint256)internal idToOwnerindex;

    constructor(string memory name, string memory symbol)NFT(name, symbol){
        //ERC165接口
        supportedInterface[0x780e9d63] = true;
    }

    //记录这个合约总的tokens
    function totalSupply()
    override
    external 
    view 
    returns (uint256){
        return tokens.length;
    }

    //通过一个index获得tokens序列中的tokenId
    function tokenByIndex(uint256 _index)
    override 
    external 
    view 
    returns (uint256){
        require(_index < tokens.length,
        "sunyao:tokenByIndex _index < tokens.length");
        return tokens[_index];
    }

    //通过一个index获得owner的tokens中的对应tokenId
    function tokenOfOwnerByIndex(address _owner, uint256 _index)
    override 
    external 
    view 
    returns (uint256){
        require(_index < ownerToIds[_owner].length,
        "sunyao:tokenOfOwnerByIndex _index < ownerToIds[owner].length");
        return ownerToIds[_owner][_index];
    }

    function mint(address _to, string memory _uri)
    external{
        _mint(_to, _uri);
    }    


    function burn(uint256 _tokenId)
    external{
        _burn(_tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId)
    internal 
    override
    virtual{
        address owner = idToOwner[_tokenId];
        require(owner == _from,
        "sunyao:transferForm owner != from");
        require(_to != address(0),
        "sunyao:transferForm to == address");
        _preTransferFrom(_from, _to, _tokenId, "");
        _removeNFTEnumerable(_tokenId);
        _removeNFT(_tokenId);
        _addNFT(_to, _tokenId);
        _addNFTEnumerable(_to, _tokenId);
        _afterTransferFrom(_from, _to, _tokenId, "");
        emit Transfer(_from, _to, _tokenId);
    }

    //内部函数：安全转移
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)
    internal
    override
    virtual{
        address owner = idToOwner[_tokenId];
        require(owner == _from,
        "sunyao:_safeTransferFrom owner == _from");
        require(_to != address(0),
        "sunyao:_safeTransferFrom _to != address(0)");
        _preTransferFrom(_from, _to, _tokenId, data);
        _removeNFTEnumerable(_tokenId);
        _removeNFT(_tokenId);
        _addNFT(_to, _tokenId);
        _addNFTEnumerable(_to, _tokenId);
        _afterTransferFrom(_from, _to, _tokenId, "");
        emit Transfer(_from, _to, _tokenId);
        if(_to.isContract()){
            bytes4 result = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(result == CONTRACT_RECEIVE_SUCCESS_BYTE,
            "sunyao:_safeTransferFrom contract account cant receive the NFT");
        }
    }

    
    //添加NFT函数，需要自己处理,这里不能重载addNFT！！！下面也一样
    function _addNFTEnumerable(address _to, uint256 _tokenId)
    internal{
        idToOwnerindex[_tokenId] = ownerToIds[_to].length;
        ownerToIds[_to].push(_tokenId);
    }   

    //创建NFT函数，添加进tokens
    function _createNFTEumerable(uint256 _tokenId)
    internal{
        idToIndex[_tokenId] = tokens.length;
        tokens.push(_tokenId);
    }


    //移除一个NFT，需要将NFT从一个人的拥有序列中移除
    function _removeNFTEnumerable(uint256 _tokenId)
    internal{
        address owner = idToOwner[_tokenId];
        uint256 tokenToRemoveIndex = idToOwnerindex[_tokenId];
        uint256 lastTokenIndex = ownerToIds[owner].length - 1;
        if (lastTokenIndex != tokenToRemoveIndex){
            uint256 lastToken = ownerToIds[owner][lastTokenIndex];
            ownerToIds[owner][tokenToRemoveIndex] = lastToken;
            idToOwnerindex[lastToken] = tokenToRemoveIndex;
        }
        ownerToIds[owner].pop();
    }

    //删除一个NFT，需要将NFT从总的序列中删除
    function _deleteNFTEnumerable(uint256 _tokenId)
    internal{
        uint256 tokenIndex = idToIndex[_tokenId];
        uint256 lastIndex = tokens.length - 1;
        uint256 lastToken1 = tokens[lastIndex];

        tokens[tokenIndex] = lastToken1;
        idToIndex[lastToken1] = tokenIndex;
        delete idToIndex[_tokenId]; 
    }

    function _afterMint(address _to, uint256 _tokenId)
    internal
    virtual
    override{
        _addNFTEnumerable(_to, _tokenId);
        _createNFTEumerable(_tokenId);  
    }

    function _preBurn(uint256 _tokenId)
    internal
    virtual
    override{
        _removeNFTEnumerable(_tokenId);
        _deleteNFTEnumerable(_tokenId);
    }

}
