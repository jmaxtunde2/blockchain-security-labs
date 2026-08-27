// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract VulnerableWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {}

    function withdrawal(uint256 amount) external {
        payable(msg.sender).transfer(amount);
    }
}