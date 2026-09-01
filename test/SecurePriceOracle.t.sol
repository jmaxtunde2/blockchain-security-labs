// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecurePriceOracle} from "../src/SecurePriceOracle.sol";

contract SecurePriceOracleTest is Test {

    SecurePriceOracle public oracle;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        oracle = new SecurePriceOracle(100 ether);
    }

    function test_OwnerCanChangePrice() public {
        vm.prank(owner);
        oracle.setPrice(200 ether);

        assertEq(oracle.getPrice(), 200 ether);
    }

    function test_AttackerCannotChangePrice() public{
        vm.prank(attacker);

        vm.expectRevert();
        oracle.setPrice(1000 ether);

        assertEq(oracle.getPrice(), 100 ether);
    }
}