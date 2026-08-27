// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OriginWalletV2 {
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {}

    function  withdrawal(uint256 amount) external {
        require(
            msg.sender == owner,"Not owner"
        );

        payable(msg.sender).transfer(amount);
    }
}