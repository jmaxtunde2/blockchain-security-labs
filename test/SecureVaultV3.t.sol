// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from 'forge-std/Test.sol';
import { SecureVaultV3 } from '../src/SecureVaultV3.sol';
import { ReentrancyAttacker } from '../src/ReentrancyAttacker.sol';

contract SecureVaultV3Test is Test{
    SecureVaultV3 public vault;
    ReentrancyAttacker public attacker;

    address alice = makeAddr("alice");
    address attackerUser = makeAddr("attackerUser");

    function setUp() public{
        vault = new SecureVaultV3();
        attacker = new ReentrancyAttacker(address(vault));

        vm.deal(alice, 10 ether);
        vm.deal(attackerUser, 1 ether);
    }

    function test_ReentrancyAttackFails() public {
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        vm.prank(attackerUser);
        vm.expectRevert();

        attacker.attack{value:1 ether}();

        assertEq(address(vault).balance, 10 ether);
        assertEq(address(attacker).balance, 0);
    }
}