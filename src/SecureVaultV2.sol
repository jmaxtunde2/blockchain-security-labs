// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SecureVaultV2 {
    mapping (address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // This function used call with the right CEI preventing reentrancy attack
    function withdrawal(uint256 amount) external {
        // Check
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        // Effect
        balances[msg.sender] -= amount;

        // Interaction
        (bool success,) = msg.sender.call{value:amount}("");
        require(
            success,
            "Transaction failed"
        );
    }
}