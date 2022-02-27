// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;


import "./erc721.sol";
import "../hederautils/is-contract-lib.sol";
import "./erc721-token-receiver.sol";
import "../hederautils/erc165-supports-interface.sol";

contract NFT is ERC721,SupportedInterface{

    using AddressUtils for address;
    //通过tokenId找到Owner
    mapping(uint256 => address) internal idToOwner;
    
    //通过tokenId找到approved addresss
    mapping(uint256 => address) internal idToApproval;

    //通过address知道用户拥有的NFT数量
    mapping (address => uint256) private ownerToNFTokenCount;

    //查看owner有没有授权给operator
    mapping (address => mapping(address => bool)) internal ownerToOperators;

    //确保授权人操作
    modifier canOperator(uint256 _tokenId){
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender || ownerToOperators[owner][msg.sender],
        "sunyao:canOperator no power to operate");
        _;
    }
    //确保授权人交易
    modifier canTransfer(uint256 _tokenId){
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender
        || ownerToOperators[owner][msg.sender]
        || idToApproval[_tokenId] == msg.sender,
        "sunyao:canTransfer no power to transfer");
        _;
    }
    //确保NFT可以被交易
    modifier validNFT(uint256 _tokenId){
        require(idToOwner[_tokenId] != address(0),
        "sunyao:validNFT invalid NFT");
        _;
    }

    constructor(){
        //接受erc721规范
        supportedInterface[0x80ac58cd] = true;
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner)override external view returns (uint256){
        return ownerToNFTokenCount[_owner];
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId)override external view validNFT(_tokenId) returns (address){
        return idToOwner[_tokenId];
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) override external payable canTransfer(_tokenId) validNFT(_tokenId){
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external payable canTransfer(_tokenId) validNFT(_tokenId){
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) override external payable canTransfer(_tokenId) validNFT(_tokenId){
        address owner = idToOwner[_tokenId];
        require(owner == _from,
        "sunyao:transferForm owner != from");
        require(_to != address(0),
        "sunyao:transferForm to == address");
        _transfer(_to, _tokenId);
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId)override external payable canOperator(_tokenId) validNFT(_tokenId){
        address owner =  idToOwner[_tokenId];
        require(owner != _approved,
        "sunyao:approve owner != approved");
        idToApproval[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved)override external{
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId)override external view validNFT(_tokenId) returns (address) {
        return idToApproval[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator)override external view returns (bool) {
        return ownerToOperators[_owner][_operator];
    }

    //创建NFT
    function _mint(address _to, uint256 _tokenId)internal virtual {
        require(_to != address(0),
        "sunyao: _mint to != address(0)");
        require(idToOwner[_tokenId] == address(0),
        "sunyao: _mint idToOwner[_tokenId] == address(0)");
        _addNFT(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    //销毁NFT
    function _burn(uint256 _tokenId)internal virtual validNFT(_tokenId){
        address owner = idToOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeNFT(owner, _tokenId);
        emit Transfer(owner, address(0), _tokenId);
    }

    //删除授权
    function _clearApproval(uint256 _tokenId)internal{
        delete idToApproval[_tokenId];
    }

    //移除NFT
    function _removeNFT(address _addr, uint256 _tokenId)internal virtual{
        require(idToOwner[_tokenId] == _addr,
        "sunyao:_removeNFT no power to remove NFT");
        ownerToNFTokenCount[_addr] -= 1;
        delete idToOwner[_tokenId];
    }

    //添加NFT
    function _addNFT(address _addr, uint256 _tokenId) virtual internal{
        require(idToOwner[_tokenId] == address(0),
        "sunyao:_addNFT the owner having owner, loss to add NFT");
        ownerToNFTokenCount[_addr] += 1;
        idToOwner[_tokenId] = _addr;
    }

    //交易
    function _transfer(address _to, uint256 _tokenId)internal{
        address _from = idToOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeNFT(_from, _tokenId);
        _addNFT(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data)private{
        address owner = idToOwner[_tokenId];
        require(owner == _from,
        "sunyao:_safeTransferFrom transferring, owner is not from");
        require(_to != address(0),
        "sunyao:_safeTransferFrom address account to is 0x0");
        _transfer(_to, _tokenId);
        if(_to.isContract()){
            bytes4 result = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            bytes4 trueResult = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
            require(result == trueResult,
            "sunyao:_safeTransferFrom contract account cant receive the NFT");
        }
    }
}
