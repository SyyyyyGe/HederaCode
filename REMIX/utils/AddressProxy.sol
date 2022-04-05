// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 

contract AddressProxy{
    mapping(address => address)proxy;

    function setProxy(address _to)
    public
    virtual{
        require(msg.sender != address(this), "AddressProxy: msg.sender != address(this)");
        proxy[msg.sender] = _to;
    }

    function getProxy(address _to)
    public
    view
    virtual
    returns(address){
        return proxy[_to];
    }
}