// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function test_caller() public {
        vm.prank(alice);

        assertEq(counter.getCaller(), alice);
    }

    function test_OwnerCanReset() public {
        counter.setNumber(100);

        counter.reset();

        assertEq(counter.number(), 0);
    }

    function test_NonOwnerCannotReset() public {
        counter.setNumber(100);

        vm.prank(alice);
        vm.expectRevert("Not Owner");

        counter.reset();
    }
}
