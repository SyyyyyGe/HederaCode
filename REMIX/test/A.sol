// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;
import "../utils/Console.sol";
contract A is Console{
    constructor(){}
    function getMsg()
    public{
        log("msg.sender", msg.sender);
        log("address(this)",address(this));
    }
}