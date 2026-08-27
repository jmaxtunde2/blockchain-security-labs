// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SignatureReplaySecureV2} from "../src/SignatureReplaySecureV2.sol";

contract SignatureReplaySecureTestV2 is Test {
    SignatureReplaySecureV2 public wallet;

    uint256 ownerPrivateKey = 0xA11CE;
    address owner;
    address alice;

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        alice = makeAddr("alice");

        vm.prank(owner);
        wallet = new SignatureReplaySecureV2();

        vm.deal(alice, 2 ether);

        vm.prank(alice);
        wallet.deposit{value: 2 ether}();
    }

    function test_SignatureCannotBeReplayed() public {
        uint256 amount = 1 ether;
        uint256 nonce = wallet.nonces(alice);

        // Create the message that the secure contract expects.
        bytes32 messageHash = keccak256(
            abi.encodePacked(alice, amount, nonce)
        );

        // Owner signs the message.
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(ownerPrivateKey, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        // First withdrawal succeeds.
        wallet.withdrawWithSignature(
            alice,
            amount,
            nonce,
            signature
        );

        assertEq(wallet.balances(alice), 1 ether);
        assertEq(wallet.nonces(alice), 1);
        assertEq(address(wallet).balance, 1 ether);

        // Try to replay the EXACT SAME signature.
        vm.expectRevert("Invalid nonce");

        wallet.withdrawWithSignature(
            alice,
            amount,
            nonce,
            signature
        );

        // Funds remain protected.
        assertEq(wallet.balances(alice), 1 ether);
        assertEq(wallet.nonces(alice), 1);
        assertEq(address(wallet).balance, 1 ether);
    }
}