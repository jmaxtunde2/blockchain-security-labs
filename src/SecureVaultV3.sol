// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import { ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SecureVaultV3 is ReentrancyGuard {
    mapping (address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawal(uint256 amount) 
        external 
        nonReentrant
        {
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