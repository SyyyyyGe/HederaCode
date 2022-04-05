// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;



import "../utils/AddressUtils.sol";
import "../utils/ERC165SupportedInterface.sol";
import "../interface/ERC721.sol";
import "../interface/ERC721Metadata.sol";
import "../interface/ERC721TokenReceiver.sol";


contract NFT is ERC721,ERC165SupportedInterface,ERC721Metadata{

    //本合约出现三个名词：拥有者，授权者，被授权者
    //拥有者：拥有对应token的人，对应owner
    //被授权者：被拥有者或者授权者 授权能够操控token权利的人，只能有一人， 往往是合约本身的地址，如果不设定，那么表示这个tokenid不支持交易
    //授权者：拥有者的同伙，在一定程度上等于拥有者，可以有多人
    using AddressUtils for address;
    

    //一组NFT的symbol
    string internal nft_name;

    //一组NFT的symbol
    string internal nft_symbol;

    //一组NFT中，每一个NFT的URI
    mapping(uint256 => string)internal idToUri;

    //通过tokenId找到Owner
    mapping(uint256 => address) internal idToOwner;

    //通过tokenId找到approved addresss
    mapping(uint256 => address) internal idToApproval;

    //通过address知道用户拥有的NFT数量
    mapping (address => uint256) internal ownerToNFTokenCount;

    //查看owner有没有授权给operator
    mapping (address => mapping(address => bool)) internal ownerToOperators;
    
    bytes4 internal constant CONTRACT_RECEIVE_SUCCESS_BYTE = 0x150b7a02;
    //确保授权人操作, 要求满足之一：拥有者， 授权者
    modifier canOperator(uint256 _tokenId){
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender || ownerToOperators[owner][msg.sender],
            "sunyao:canOperator no power to operate");
        _;
    }
    //确保授权人交易, 要求满足之一：拥有者， 被授权者， 授权者
    modifier canTransfer(uint256 _tokenId){
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender
            || ownerToOperators[owner][msg.sender]
            || idToApproval[_tokenId] == msg.sender,
            "sunyao:canTransfer no power to transfer");
        _;
    }
    //确保NFT可以被交易，要求：当前NFT已被开采
    modifier validNFT(uint256 _tokenId){
        require(idToOwner[_tokenId] != address(0),
            "sunyao:validNFT invalid NFT");
        _;
    }

    constructor(string memory _name, string memory _symbol){
        nft_name = _name;
        nft_symbol = _symbol;
    }

    function supportsInterface(bytes4 interfaceId) 
    public 
    pure
    virtual 
    override 
    returns (bool) {
        return
            interfaceId == type(ERC721).interfaceId ||
            interfaceId == type(ERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    //获取name
    function name()
    override
    external
    view
    returns (string memory _name){
        _name = nft_name;
    }

    //获取symbol
    function symbol()
    override
    external
    view
    returns (string memory _symbol){
        _symbol = nft_symbol;
    }

    //获取一个token的URI，用于交互
    function tokenURI(uint256 _tokenId)
    override
    external
    view
    validNFT(_tokenId)
    returns (string memory) {
        return _tokenURI(_tokenId);
    }


    //查询一个账号剩余tokens的数量
    function balanceOf(address _owner)
    override
    external
    view
    returns (uint256){
        return ownerToNFTokenCount[_owner];
    }

    //查询一个token的拥有者
    function ownerOf(uint256 _tokenId)
    override
    external
    view
    validNFT(_tokenId)
    returns (address){
        return idToOwner[_tokenId];
    }

    //安全转移，前提是这个转移必须是符合canTransfer和alidNFT的，与普通转移区别在于这个转移对于接受者是不是合约账户会有特殊判断
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data)
    override
    external
    payable
    virtual
    canTransfer(_tokenId)
    validNFT(_tokenId){
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    //安全转移，前提是这个转移必须是符合canTransfer和alidNFT的
    function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    override
    external
    payable
    virtual
    canTransfer(_tokenId)
    validNFT(_tokenId){
        _safeTransferFrom(_from, _to, _tokenId, "");
    }


    //普通转移，前提是这个转移必须是符合canTransfer和validNFT的
    function transferFrom(address _from, address _to, uint256 _tokenId)
    override
    external
    payable
    virtual
    canTransfer(_tokenId)
    validNFT(_tokenId){
        _transferFrom(_from, _to, _tokenId);
    }

    //授权，拥有者和授权者可以进行操作，指定一个被授权者。 
    function approve(address _approved, uint256 _tokenId)
    override
    external
    payable
    canOperator(_tokenId)
    validNFT(_tokenId){
        address owner =  idToOwner[_tokenId];
        idToApproval[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    //拥有者命名授权者
    function setApprovalForAll(address _operator, bool _approved)
    override
    external{
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    //查看一个硬币的被授权者
    function getApproved(uint256 _tokenId)
    override
    external
    view
    validNFT(_tokenId)
    returns (address) {
        return idToApproval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
    override
    external
    view
    returns (bool) {
        return ownerToOperators[_owner][_operator];
    }

    //获取一个token的URI，用于继承
    function _tokenURI(uint256 _tokenId)
    internal
    view
    returns(string memory){
        return idToUri[_tokenId];
    }

    //创建NFT,通过uri创建
    function _mint(address _to, uint256 _tokenId)
    internal
    virtual {
        require(_to != address(0),
            "sunyao: _mint to != address(0)");
        require(idToOwner[_tokenId] == address(0),
            "sunyao: idToOwner[_tokenId] == address(0)");
        _preMint(_to, _tokenId);
        _addNFT(_to, _tokenId);
        _afterMint(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    //设置uri
    function _setUri(uint256 _tokenId, string memory _uri)
    internal {
        idToUri[_tokenId] = _uri;
    }

    //销毁NFT
    function _burn(uint256 _tokenId)
    internal
    virtual
    validNFT(_tokenId){
        address owner = idToOwner[_tokenId];
        _preBurn(_tokenId);
        _removeNFT(_tokenId);
        delete(idToUri[_tokenId]);
        _afterBurn(_tokenId);
        emit Transfer(owner, address(0), _tokenId);
    }

    function _addLike(address _to, uint256 _tokenId)
    internal
    validNFT(_tokenId){
        
    }
    //交易
    function _transferFrom(address _from, address _to, uint256 _tokenId)
    internal
    virtual{
        address owner = idToOwner[_tokenId];
        require(owner == _from,
            "sunyao:transferForm owner != from");
        require(_to != address(0),
            "sunyao:transferForm to == address");
        _preTransferFrom(_from, _to, _tokenId, "");
        _removeNFT(_tokenId);
        _addNFT(_to, _tokenId);
        _afterTransferFrom(_from, _to, _tokenId, "");
        emit Transfer(_from, _to, _tokenId);
    }

    //内部函数：安全转移
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)
    internal
    virtual{
        address owner = idToOwner[_tokenId];
        require(owner == _from,
            "sunyao:_safeTransferFrom owner == _from");
        require(_to != address(0),
            "sunyao:_safeTransferFrom _to != address(0)");
        _preTransferFrom(_from, _to, _tokenId, data);
        _removeNFT(_tokenId);
        _addNFT(_to, _tokenId);
        _afterTransferFrom(_from, _to, _tokenId, data);
        emit Transfer(_from, _to, _tokenId);
        if(_to.isContract()){
            bytes4 result = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(result == CONTRACT_RECEIVE_SUCCESS_BYTE,
                "sunyao:_safeTransferFrom contract account cant receive the NFT");
        }
    }

    //添加NFT
    function _addNFT(address _to, uint256 _tokenId)
    internal{
        ownerToNFTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;
    }


    //移除NFT
    function _removeNFT(uint256 _tokenId)
    internal{
        address _from = idToOwner[_tokenId];
        ownerToNFTokenCount[_from] -= 1;
        delete idToOwner[_tokenId];
        delete idToApproval[_tokenId];
    }

    //下面函数利用回调机制提高合约灵活性
    //在mint前执行
    function _preMint(address _to, uint256 _tokenId)
    internal
    virtual{}

    //在mint后执行
    function _afterMint(address _to, uint256 _tokenId)
    internal
    virtual{}

    //在burn前执行
    function _preBurn(uint256 _tokenId)
    internal
    virtual{}

    //在burn后执行
    function _afterBurn(uint256 _tokenId)
    internal
    virtual{}

    //在transferFrom前执行
    function _preTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)
    internal
    virtual{}

    //在transferFrom后执行
    function _afterTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)
    internal
    virtual{}
}
