// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecurePriceOracle} from "../src/SecurePriceOracle.sol";
import {SecureLending} from "../src/SecureLending.sol";

contract SecureLendingTest is Test {
    SecurePriceOracle public oracle;
    SecureLending public lending;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        oracle = new SecurePriceOracle(100 ether);

        lending = new SecureLending(address(oracle));

        vm.deal(attacker, 1 ether);

        // Give the lending protocol ETH to provide legitimate loans.
        vm.deal(address(lending), 10 ether);
    }

    function test_AttackerCannotManipulateOracleAndOverborrow() public {
        vm.startPrank(attacker);

        // Attacker deposits 1 ETH.
        lending.depositCollateral{value: 1 ether}();

        // Attacker tries to manipulate the oracle.
        vm.expectRevert("Not Oracle Owner");
        oracle.setPrice(1000 ether);

        // Oracle must still report the original price.
        assertEq(oracle.getPrice(), 100 ether);

        // With 1 ETH collateral valued at 100,
        // attempting to borrow 10 ETH must fail.
        vm.expectRevert("Insufficient collateral");
        lending.borrow(101 ether);

        vm.stopPrank();

        assertEq(lending.debt(attacker), 0);
        assertEq(lending.collateral(attacker), 1 ether);
        assertEq(address(lending).balance, 11 ether);
    }
}