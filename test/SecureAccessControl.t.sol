// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecureAccessControl} from "../src/SecureAccessControl.sol";

contract SecureAccessControlTest is Test {
    SecureAccessControl public wallet;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        wallet = new SecureAccessControl();

        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(owner);
        (bool success,) = address(wallet).call{value: 10 ether}("");
        require(success);
    }

    function test_AttackerCannotTakeOwnership() public {
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.changeOwner(attacker);

        assertEq(wallet.owner(), owner);
    }

    function test_AttackerCannotWithdraw() public {
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.withdraw(payable(attacker), 10 ether);

        assertEq(address(wallet).balance, 10 ether);
        assertEq(address(attacker).balance, 1 ether);
    }

    function test_OwnerCanChangeOwner() public {
        vm.prank(owner);

        wallet.changeOwner(attacker);

        assertEq(wallet.owner(), attacker);
    }

    function test_OwnerCanWithdraw() public {
        vm.prank(owner);

        wallet.withdraw(payable(owner), 5 ether);

        assertEq(address(wallet).balance, 5 ether);
    }

    function test_AttackerCannotDrainAfterFailedOwnershipAttack() public {
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.changeOwner(attacker);

        // Ownership must remain with the legitimate owner.
        assertEq(wallet.owner(), owner);

        // Attacker still cannot withdraw.
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.withdraw(payable(attacker), 10 ether);

        assertEq(address(wallet).balance, 10 ether);
        assertEq(address(attacker).balance, 1 ether);
    }
}