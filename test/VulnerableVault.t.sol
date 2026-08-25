    
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {VulnerableVault} from "../src/VulnerableVault.sol";
import {ReentrancyAttacker} from "../src/ReentrancyAttacker.sol";

contract VulnerableVaultTest is Test {
    VulnerableVault public vault;
    ReentrancyAttacker public attacker;

    address alice = makeAddr("alice");
    address attackerUser = makeAddr("attackerUser");

    function setUp() public {
        vault = new VulnerableVault();
        attacker = new ReentrancyAttacker(address(vault));

        vm.deal(alice, 10 ether);
        vm.deal(attackerUser, 1 ether);
    }

    function test_ReentrancyAttack() public {
        // Alice deposits 10 ETH into the vault.
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        console.log("=== BEFORE ATTACK ===");
        console.log("Vault:", address(vault).balance);
        console.log("Attacker contract:", address(attacker).balance);

        // Attacker deposits 1 ETH and begins the attack.
        vm.prank(attackerUser);
        attacker.attack{value: 1 ether}();

        console.log("=== AFTER ATTACK ===");
        console.log("Vault:", address(vault).balance);
        console.log("Attacker contract:", address(attacker).balance);

        // Vault should be drained.
        assertEq(address(vault).balance, 0);

        // Attacker should have the original 1 ETH
        // plus Alice's 10 ETH.
        assertEq(address(attacker).balance, 11 ether);
    }
}