// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecureAMM} from "../src/SecureAMM.sol";

contract SecureAMMTest is Test {
    SecureAMM public amm;

    address trader = makeAddr("trader");

    function setUp() public {
        amm = new SecureAMM{value: 10 ether}(10 ether, 100 ether);

        vm.deal(trader, 10 ether);
    }

    function test_SwapChangesSpotPrice() public {
        uint256 initialPrice = amm.getSpotPrice();

        vm.prank(trader);
        amm.swapETHForToken{value: 1 ether}();

        uint256 newPrice = amm.getSpotPrice();

        assertTrue(newPrice != initialPrice);
    }
}