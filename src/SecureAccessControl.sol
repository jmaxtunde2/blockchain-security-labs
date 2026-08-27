// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureAccessControl {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function withdraw(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        recipient.transfer(amount);
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");

        owner = newOwner;
    }

    receive() external payable {}
}