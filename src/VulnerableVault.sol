// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VulnerableVault {
    mapping (address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawal(uint256 amount) external payable {
        // Check
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        // Interaction
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Transaction failed");

        // Effect
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}