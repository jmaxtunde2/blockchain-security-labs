// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SignatureReplayVulnerable} from "../src/SignatureReplayVulnerable.sol";

contract SignatureReplayVulnerableTest is Test {
    SignatureReplayVulnerable public wallet;

    uint256 ownerPrivateKey = 0xA11CE;
    address owner;
    address alice;

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        alice = makeAddr("alice");

        vm.prank(owner);
        wallet = new SignatureReplayVulnerable();

        vm.deal(alice, 2 ether);

        vm.prank(alice);
        wallet.deposit{value: 2 ether}();
    }

    function test_SignatureCanBeReplayed() public {
        uint256 amount = 1 ether;

        // Create the exact message that the contract expects.
        bytes32 messageHash = keccak256(
            abi.encodePacked(alice, amount)
        );

        // Sign the message using the owner's private key.
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(ownerPrivateKey, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        // First withdrawal.
        wallet.withdrawWithSignature(
            alice,
            amount,
            signature
        );

        assertEq(wallet.balances(alice), 1 ether);
        assertEq(address(wallet).balance, 1 ether);

        // Replay the EXACT SAME signature.
        wallet.withdrawWithSignature(
            alice,
            amount,
            signature
        );

        // The second withdrawal succeeds.
        assertEq(wallet.balances(alice), 0);
        assertEq(address(wallet).balance, 0);
    }
}