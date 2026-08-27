// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import { VulnerableWallet} from "../src/VulnerableWallet.sol";

contract VulnerableWalletTest is Test {
    VulnerableWallet public wallet; 

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        wallet = new VulnerableWallet();

        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);

        // Acting as owner
        vm.prank(owner);
        wallet.deposit{value: 10 ether}();
    }

    function test_UnautorisedUserCanWithdraw()  public {
        vm.prank(attacker);
        wallet.withdrawal(10 ether);

        assertEq(address(wallet).balance,0 ether);
        assertEq(attacker.balance, 11 ether);
    }
}