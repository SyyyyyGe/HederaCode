// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;


import "./A1.sol";


contract B1{
    A1 a;
    constructor(address _A){a = A1(_A);}
    function add(uint256 _id, uint256 _num)
    external{
        a.setmp(_id, _num);
    }

    function query(uint256 _id)
    external
    view 
    returns(uint256){
        require(_id != 0, "hhh");
        return a.getmp(_id);
    }
}