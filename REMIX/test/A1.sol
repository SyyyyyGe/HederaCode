// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;
contract A1{
    mapping(uint256 => uint256)internal mp;

    function getmp(uint256 _id)
    public
    view
    returns(uint256){
        return mp[_id];
    }

    function setmp(uint256 _id, uint256 _num)
    public{
        mp[_id] = _num;
    }
}