// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerablePriceOracle} from '../src/VulnerablePriceOracle.sol';

contract VulnerablePriceOracleTest is Test {
    
    VulnerablePriceOracle public oracle;
    address attacker = makeAddr("attacker");

    function setUp() public{
        oracle = new VulnerablePriceOracle(100 ether);
    }

    function  test_AttackerCanManipulate() public {
        assertEq(oracle.getPrice(), 100 ether);

        vm.prank(attacker);
        oracle.setPrice(1 ether);

        assertEq(oracle.getPrice(), 1 ether);
    }
}