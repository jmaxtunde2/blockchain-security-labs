// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerableAccessControl} from "../src/VulnerableAccessControl.sol";

contract VulnerableAccessControlTest is Test {
    VulnerableAccessControl public wallet;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        wallet = new VulnerableAccessControl();

        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(owner);
        (bool success,) = address(wallet).call{value: 10 ether}("");
        require(success);
    }

    function test_AttackerCannotWithdraw() public {
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.withdrawal(payable(attacker), 10 ether);

        assertEq(address(wallet).balance, 10 ether);
        assertEq(address(attacker).balance, 1 ether);
    }

    function test_OwnerCanWithdraw() public {
        vm.prank(owner);

        wallet.withdrawal(payable(owner), 5 ether);

        assertEq(address(wallet).balance, 5 ether);
    }

    function test_AttackerCannotChangeOwner() public {
        vm.prank(attacker);

        vm.expectRevert("Not owner");
        wallet.changeOwner(attacker);

        assertEq(wallet.owner(), owner);
    }
}