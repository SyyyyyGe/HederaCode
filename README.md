$\color{red}所有可调用api均为virtual形式，不影响正常操作，方便后续扩展$

### NFTLast合约api

- 构造函数，用来初始化合约
  - constructor(string _name, string _symbol)
- 开发者函数(只有合约创建者能够调用)
  - **暂停所有交易，方便更新合约**
    - pause()
  - **启动所有交易，更新合约后使用**
    - unpause()
- 添加函数，用来进行一些添加操作
  - **添加自己的喜欢**
    -  addFavor(uint256 _tokenId)
  - **添加市场NFT**(只有合约创建者能够调用)
    - mint(adress _to,uint256 _tokenId,string _uri)
- 删除函数，用来进行一些删除操作
  - **删除自己的喜欢**
    -  removeFavor(uint256 _tokenId)
  - **删除市场NFT** 
    -  burn(adress _to,uint256 _tokenId,string _uri)
- 交易函数，用来进行交易
  - 安全交易函数，与普通转移区别在于这个转移对于接受者是不是合约账户会有特殊判断，从把token从from给to
    -  safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data)
    -  safeTransferFrom(address _from, address _to, uint256 _tokenId)
  - **普通交易函数**
    -  transferFrom(address _from, address _to, uint256 _tokenId)
- 授权函数：
  - **进行授权，每个用户只能有一个授权者，往往是交易合约，只有负责交易，不能负责转移授权**
    - approve(address _approved, uint256 _tokenId)
  - **进行信任，每个用户可以有多个信任人，往往是合作方或者信任对象，权力约等于owner**
    -  setApprovalForAll(address _operator, bool _approved)
- 查询函数，用来进行一些查询
  - 接口调用
    -  supportsInterface(bytes4 interfaceId) returns（bool）
  - 查询一个人喜欢的nft的数量：
    - getOwnerFavorsLen（address _to） returns(uint256)
  - **查询一个人喜欢的所有nft** :
    -  showFavors(address _to) returns(uint256[])
  - 查询一个人拥有的nft的数量:
    - balanceOf(address _owner)
  - **查询一个人拥有的所有nft**：
    - getUserTokens(address _owner) returns(uint256[])
  - 查询一个合约的所有nft数量:
    -  totalSupply() returns(uint256)
  - 查询整个市场的第index个nft：
    - tokenByIndex（uint256 _index）returns(uint256)
  - 查询一个用户的第index个nft：
    - tokenOfOwnerByIndex(address _owner, uint256 _index) returns(uint256)
  - 查询合约的name：
    - name() returns(string)
  - 查询合约的symbol: 
    -  symbol() returns(string)
  - **查询一个token的uri:** 
    -  tokenURI(uint256 _tokenId)returns(string)
  - 查询一个token的拥有者
    - ownerOf(uint256 _tokenId) returns(address)
  - **查询一个token的授权者：**
    - getApproved(uint256 _tokenId) returns(address)
  - 查询一个token是否对于operator具有信任：
    - isApprovedForAll(address _owner, address _operator) returns(bool)



### $\color{red}NFTSale合约（同过去的auction合约类似）$

#### 功能点

- 实现价格动态变化；

- 改变直售过期判断，可永久直售，可限时直售
- 可更新直售
- 可查看nft直售历史
- 不只nft拥有者可进行操作，operator也可以进行创建和取消。
- 交易时，使用call函数代替transfer，允许转账接收者处理自己收款的逻辑，并且调用openzeppelin的防重入合约，实现交易的更安全更开放

#### 具体api

结构体

```solidity
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
```

- 构造函数，传参为nft合约地址
  -  constructor(address _nftAddress)
- 查询函数
  - **得到一个token当前的交易**
    -  getSale(uint256 _tokenId)returns(Sale)
  - **得到一个nft当前价格**
    -  getCurrentPrice(uint256 _tokenId)returns(uint256)
  - **展示所有在直售的nft**（筛选操作可以在这基础上进行，前端后端都可以筛选，得到这个auction后，我们可以得到这个拍卖的折扣百分比offer，并且可以通过查询价格，得到当前价格，然后按照条件筛选）
    -  showAllSales() returns(Auction[])
  - 得到直售列表的长度
    - getSalesLen() returns(uint256)
  - 得到一个token的直售历史
    - getSaleDetail(uint256 _tokenId)returns(SaleDetail[])
- **$\color{red}更新交易$**
  - updateSale(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
- **创建交易**（开始价格往往高于结束价格，这个是为了市场方便卖出去nft，是一个动态价格，随着时间流逝，价格会不断减少，直到接近结束价格，offer是折扣百分比，默认是100，即不折扣）
  -  createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration)
  -  createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _discount)
- **购买函数**
  - buy(uint256 _tokenId)
- **删除函数**
  - 取消交易
    - cancelSale(uint256 _tokenId)

### NFTAuction合约

$\color{red}(结构体更新)$

```solidity
//以下是合约存储结构体
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
struct AuctionDetail{
    //卖家
    address seller;
    //买家
    address buyer;
    //价格（单位wei）
    uint256 price;
}
```

- $\color{red}实现自动删除过期交易$
- 构造函数，传参为nft合约地址
  -  constructor(address _nftAddress)
- 查询函数
  - 展示拍卖列表的长度
    - getAuctionsLen() returns(uint256)
  - $\color{red}得到当前合约的账户余额$
    - showAccountBalance() returns(uint256)
  - **$\color{red}展示一个人竞拍一个token下注的钱$**
    - showOnesBidding(address _target, uint256 _tokenId) returns(uint256)
  - **得到一个token当前的交易**
    -  getAuction(uint256 _tokenId)returns(Auction)
  - **展示所有在交易的nft**（筛选操作可以在这基础上进行，前端后端都可以筛选，得到这个auction后，我们可以得到这个拍卖的折扣百分比offer，并且可以通过查询价格，得到当前价格，然后按照条件筛选）
    - showAllAuctions() returns(Auction[])
  - 得到交易列表的细节
    - getAuctionsLen() returns(uint256)
  - 得到一个token的交易历史
    - getAuctionDetail(uint256 _tokenId)returns(AuctionDetail[])
- **创建拍卖**
  -  createAuction(uint256 _tokenId, uint256 _nowAmount, uint256 _duration)
  -  createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, uint256 _offer)
- **交易函数**
  - 竞拍（存钱进入合约，存的钱+已经存入的钱为自己的竞拍价）
    - bid(uint256 _tokenId)
  - 取钱
    - withdraw(uint256 _tokenId)
- **删除函数**
  - 取消拍卖(所有人可以调用，但是只有在拍卖结束后，其他人才可以调用成功，否则只有owner和operator可以成功)
    - cancelAuction(uint256 _tokenId)
