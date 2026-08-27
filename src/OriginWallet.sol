// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OriginWallet {
    address public owner;
    constructor() {
        owner = tx.origin;
    }

    function deposit() external payable {}

    function  withdrawal(uint256 amount) external {
        require(
            tx.origin == owner,"Not owner"
        );

        payable(msg.sender).transfer(amount);
    }
}