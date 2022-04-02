// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    event OwnershipTransfer(address indexed _old, address indexed _new);
    modifier onlyOwner{
        require(msg.sender == owner,
        "Ownable:onlyOwner msg.sender == owner");

        _;
    }

    function ownershipTransfer(address _new)internal onlyOwner{
        require(_new != address(0),
        "sunyao:ownershipTransfer _new != address(0)");
        owner = _new;
        emit OwnershipTransfer(msg.sender, _new);
    }
}
