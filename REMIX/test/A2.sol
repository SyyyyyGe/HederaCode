// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

contract A2{
    constructor()payable{

    }


    function withdraw1(uint256 amount)
    public
    payable{
        payable(msg.sender).transfer(amount);
    }

    // function cun()
    // public
    // payable{
    //     payable(this).transfer(msg.sender);
    // }

    function withdraw2(uint256 amount) external {
        // This forwards all available gas. Be sure to check the return value!
        (bool success, ) = payable(msg.sender).call{value:amount, gas:2300}("");
        require(success, "Transfer failed.");
    }

    receive() external payable{

    }
}