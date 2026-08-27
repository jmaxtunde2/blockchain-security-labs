// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SignatureReplaySecureV2 {
    address public owner;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawWithSignature(
        address user,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) external {
        require(nonce == nonces[user], "Invalid nonce");

        bytes32 messageHash = keccak256(
            abi.encodePacked(user, amount, nonce)
        );

        address signer = recoverSigner(messageHash, signature);

        require(signer == owner, "Invalid signature");

        // Consume the nonce BEFORE the external call.
        nonces[user]++;

        balances[user] -= amount;

        (bool success,) = user.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) public pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        return ecrecover(hash, v, r, s);
    }
}