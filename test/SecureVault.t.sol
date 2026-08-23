//SPDX-Licence-Identifier:MIT
pragma solidity ^0.8.13;

import { Test } from 'forge-std/Test.sol';
import { SecureVault} from '../src/SecureVault.sol';

contract SecureVaultTest is Test {
    SecureVault public vault;

    address alice = makeAddr('alice');
    address bob = makeAddr('bob');

    function setUp() public{
        vault = new SecureVault();

        vm.deal(alice, 10 ether);
    }

    function test_deposit() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balances(alice), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    function test_withdraw()  public {
        vm.startPrank(alice);

        vault.deposit{value:5 ether}();

        uint256 aliceBalanceBefore = alice.balance;

        vault.withdrawal(2 ether);

        vm.stopPrank();

        assertEq(vault.balances(alice), 3 ether);
        assertEq(address(vault).balance, 3 ether);
        assertEq(alice.balance, aliceBalanceBefore + 2 ether);
    }

    function test_cannotWithdrawMoreThanBalance() public {
        vm.startPrank(alice);

        vault.deposit{value: 1 ether}();
        vm.expectRevert("Insufficient Balance");

        vault.withdrawal(2 ether);

        vm.stopPrank();

        assertEq(vault.balances(alice), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    function test_bobCannotWithdrawAliceBalance() public{
        vm.prank(alice);

        vault.deposit{value: 5 ether}();

        vm.prank(bob);

        vm.expectRevert("Insufficient Balance");

        vault.withdrawal(5 ether);

        assertEq(vault.balances(alice), 5 ether);
        assertEq(vault.balances(bob), 0 ether);
        assertEq(address(vault).balance, 5 ether);
    }
}