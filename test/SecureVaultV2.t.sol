// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { SecureVaultV2} from '../src/SecureVaultV2.sol';
import { ReentrancyAttacker} from '../src/ReentrancyAttacker.sol';

contract SecureVaultV2Test is Test{
    SecureVaultV2 public vault;
    ReentrancyAttacker public attacker;

    address alice = makeAddr("alice");
    address attackerUser = makeAddr("attackerUser");

    function setUp() public {
        vault = new SecureVaultV2();
        attacker = new ReentrancyAttacker(address(vault));

        vm.deal(alice, 10 ether);
        vm.deal(attackerUser, 1 ether);
    }

    function test_ReentrancyAttackFails() public {
        // Alice deposits 10 ETH.
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        // Attacker attempts the same attack.
        vm.prank(attackerUser);

        vm.expectRevert();

        attacker.attack{value: 1 ether}();

        // Alice's 10 ETH must still be in the vault.
        assertEq(address(vault).balance, 10 ether);

        // Attacker must not have stolen Alice's ETH.
        assertEq(address(attacker).balance, 0);
    }   

    function test_AttackerCannotDrainAliceFunds() public {
        // Alice deposits 10 ETH
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        // Snapshot state before attack
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;

        // Attacker attempts to drain the vault
        vm.prank(attackerUser);
        vm.expectRevert();

        attacker.attack{value: 1 ether}();

        // Vault must remain intact
        assertEq(
            address(vault).balance,
            vaultBalanceBefore
        );

        // Attacker must not profit
        assertEq(
            address(attacker).balance,
            attackerBalanceBefore
        );
    }

    function test_AttackerBalanceRemainsZeroAfterFailedAttack() public {
        // Alice deposits 10 ETH
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        // Attacker attempts the reentrancy attack
        vm.prank(attackerUser);
        vm.expectRevert();

        attacker.attack{value: 1 ether}();

        // The attacker's temporary deposit must also be rolled back
        assertEq(
            vault.balances(address(attacker)),
            0
        );
    }

    function  test_NormalWithdrawalStillWorks() public {
        vm.prank(alice);
        vault.deposit{value: 5 ether}();

        uint256 aliceBalanceBefore = alice.balance;
        
        vm.prank(alice);
        vault.withdrawal(2 ether);

        assertEq(
            vault.balances(alice), 3 ether
        );

        assertEq(
            alice.balance,
            aliceBalanceBefore + 2 ether
        );

        assertEq(
            address(vault).balance,
            3 ether
        );

    }

    function test_AttackerCannotWithdrawAliceFunds() public {
        vm.prank(alice);
        vault.deposit{value: 10 ether}();

        vm.prank(attackerUser);

        vm.expectRevert("Insufficient balance");

        vault.withdrawal(10 ether);

        assertEq(vault.balances(alice), 10 ether);
        assertEq(vault.balances(attackerUser), 0);
        assertEq(address(vault).balance, 10 ether);
    }
}