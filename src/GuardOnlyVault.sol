// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GuardOnlyVault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawal(uint256 amount)
        external
        nonReentrant
    {
        // CHECK
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        // INTERACTION — deliberately BEFORE EFFECT
        (bool success,) = msg.sender.call{value: amount}("");

        require(
            success,
            "Transaction failed"
        );

        // EFFECT — deliberately moved after external call
        balances[msg.sender] -= amount;
    }
}