// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AddressUtils{
    function isContract(address _addr)internal view returns(bool){
        return _addr.code.length > 0;
    }

}
