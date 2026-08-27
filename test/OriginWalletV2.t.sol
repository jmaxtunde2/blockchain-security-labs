// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from 'forge-std/Test.sol';
import {OriginWalletV2} from "../src/OriginWalletV2.sol";
import {OriginAttack} from "../src/OriginAttack.sol";

contract OriginWalletV2Test is Test {
    OriginWalletV2 public wallet;
    OriginAttack public attacker;

    address owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        wallet = new OriginWalletV2();
        attacker = new OriginAttack(address(wallet));

        vm.deal(owner, 10 ether);

        vm.prank(owner);
        wallet.deposit{value:10 ether}();
    }

    function test_Tx_OriginCannotBeByPass() public {
        vm.prank(owner);

        vm.expectRevert("Not owner");
        attacker.attack(10 ether);

        assertEq(address(wallet).balance, 10 ether);
        assertEq(address(attacker).balance,0);
    }

}