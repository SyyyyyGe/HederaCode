// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AddressUtils{
    function isContract(address _addr)internal view returns(bool){
        uint256 size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}
