// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from 'forge-std/Test.sol';
import {OriginWallet} from "../src/OriginWallet.sol";
import {OriginAttack} from "../src/OriginAttack.sol";

contract OriginWalletTest is Test {
    OriginWallet public wallet;
    OriginAttack public attacker;

    address owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        wallet = new OriginWallet();
        attacker = new OriginAttack(address(wallet));

        vm.deal(owner, 10 ether);

        vm.prank(owner);
        wallet.deposit{value:10 ether}();
    }

    function test_Tx_OriginCanBeByPass() public {
        vm.prank(owner);
        attacker.attack(10 ether);

        assertEq(address(wallet).balance,0);
        assertEq(address(attacker).balance,10 ether);
    }

}