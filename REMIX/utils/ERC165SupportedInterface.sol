// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/ERC165.sol";

contract ERC165SupportedInterface is ERC165{
    //存储被调用的接口，用来支持ERC规范
    mapping(bytes4 => bool)internal supportedInterface;

    constructor(){
        //表示该合约接受ERC165规范
        supportedInterface[0x01ffc9a7] = true;
    }
    function supportsInterface(bytes4 _interfaceID)override external view returns (bool){
        return supportedInterface[_interfaceID];
    }
}
