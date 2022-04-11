更新了NFT和NFTLast,沿用openzeepelin的安全mint功能，命名为safeMint(address to, uint256 tokenId, string memoey uri, bytes memory data)和safeMint(address to, uint256 tokenId, string memoey uri)。


utils文件夹内沿用了openzeepelin的ERC721Holder，用于实现了ERC721TokenReceiver接口，主要用于合约账户接受safeMint和接受safeTransferFrom，如果要接受和合约账户需要继承这个ERC721Holder或者自己编写接口实现，不然会接受失败。
