// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This contract introduces checking the owner
contract VulnerableWalletV2 {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {}

    function withdrawal(uint256 amount) external {
        require(
            owner == msg.sender,
            "Not owner" 
        );

        payable(msg.sender).transfer(amount);
    }
}