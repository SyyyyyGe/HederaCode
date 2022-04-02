// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "../interface/ERC165.sol";
import "../utils/Console.sol";

contract Test2 is Console{

    function supportsInterface(bytes4 _interfaceID)external pure returns (bool){
        
        if(_interfaceID == this.supportsInterface.selector)return true;
        return false;
    }

    function test2()
    public{
        log("byte4", type(ERC165).interfaceId);
    }

    function test3()
    public{
        
    }
}