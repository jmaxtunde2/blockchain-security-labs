// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GuardOnlyVault} from "../src/GuardOnlyVault.sol";
import {ReentrancyAttacker} from "../src/ReentrancyAttacker.sol";

contract GuardOnlyVaultTest is Test {
    GuardOnlyVault public vault;
    ReentrancyAttacker public attacker;

    address alice = makeAddr("alice");
    address attackerUser = makeAddr("attackerUser");

    function setUp() public {
        vault = new GuardOnlyVault();
        attacker = new ReentrancyAttacker(address(vault));

        vm.deal(alice, 10 ether);
        vm.deal(attackerUser, 1 ether);
    }

    function test_ReentrancyStillBlockedByGuard() public {
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        vm.prank(attackerUser);

        vm.expectRevert();

        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 10 ether);
        assertEq(address(attacker).balance, 0);
    }
}