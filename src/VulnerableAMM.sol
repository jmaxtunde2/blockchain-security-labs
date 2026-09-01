// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableAMM {
    uint256 public reserveETH;
    uint256 public reserveToken;

    constructor(uint256 initialETH, uint256 initialToken) payable {
        reserveETH = initialETH;
        reserveToken = initialToken;
    }

    function getPrice() public view returns (uint256) {
        return reserveETH * 1 ether / reserveToken;
    }

    function swapETHForToken() external payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "No ETH");

        tokenAmount = msg.value * reserveToken / reserveETH;

        reserveETH += msg.value;
        reserveToken -= tokenAmount;
    }

    function swapTokenForETH(uint256 tokenAmount) external returns (uint256 ethAmount) {
        require(tokenAmount > 0, "No tokens");
        require(tokenAmount <= reserveToken, "Insufficient token reserve");

        ethAmount = tokenAmount * reserveETH / reserveToken;

        reserveToken -= tokenAmount;
        reserveETH -= ethAmount;

        (bool success,) = msg.sender.call{value: ethAmount}("");
        require(success, "Transfer failed");
    }
}
