// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "../utils/Console.sol";
// import "../A2.sol";
contract B2 is Console{
    function sendValue(address payable _to, uint256 amount)
    payable
    public{
        uint256 a = 1;
        uint256 b = 1;
        (bool success, bytes memory message) = _to.call{value:amount}("heiheihei");
        log("a+b",a+b);
        log("success", success);
        log("message", message);
    }
}