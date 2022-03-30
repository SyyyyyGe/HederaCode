// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;


import "../utils/Console.sol";
import "./A.sol";


contract B is Console{
    A a;
    constructor(address _A){a = A(_A);}
    function getAMsg()
    public{
        address aa = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
        address bb = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
        log("address(B)", address(this));
        log("B:address(msg.sender)", address(msg.sender));
        a.getMsg();
    }
}