// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerableAMM} from "../src/VulnerableAMM.sol";

contract VulnerableAMMTest is Test {
    VulnerableAMM public amm;

    address trader = makeAddr("trader");

    function setUp() public {
        amm = new VulnerableAMM{value: 10 ether}(10 ether, 1000 ether);

        vm.deal(trader, 1 ether);
    }

    function test_SpotPriceCanBeMoved() public {
        uint256 initialPrice = amm.getPrice();

        vm.prank(trader);
        amm.swapETHForToken{value: 1 ether}();

        uint256 newPrice = amm.getPrice();

        assertEq(initialPrice, 0.01 ether);
        assertGt(newPrice, initialPrice);
    }
}