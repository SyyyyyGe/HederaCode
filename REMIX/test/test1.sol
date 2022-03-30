// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "../utils/Console.sol";
contract Test1 is Console{

    constructor(){}
    function getlog(string memory str, address addr)
    public{
        log(str, addr);
    }
}