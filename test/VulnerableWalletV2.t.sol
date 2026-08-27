// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { VulnerableWalletV2 } from "../src/VulnerableWalletV2.sol";

contract VulnerableWalletV2Test is Test {
    VulnerableWalletV2 public wallet;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        wallet = new VulnerableWalletV2();

        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);

        // Acting like owner
        vm.prank(owner);
        wallet.deposit{value:10 ether}();
    }

    function test_AttackerCannotWithdraw() public {
        // Acting like attacker
        vm.prank(attacker);
        vm.expectRevert();
        wallet.withdrawal(10 ether);

        assertEq(address(wallet).balance, 10 ether);
        assertEq(attacker.balance, 1 ether);
    }

    function test_OwnerCanWithdraw() public {
        // Acting like the owner
        vm.prank(owner);
        wallet.withdrawal(5 ether);

        assertEq(address(wallet).balance, 5 ether);
        assertEq(owner.balance, 5 ether);
    }
}
