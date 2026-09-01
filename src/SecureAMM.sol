// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureAMM {
    uint256 public reserveETH;
    uint256 public reserveToken;

    constructor(
        uint256 initialETH,
        uint256 initialToken
    ) payable {
        reserveETH = initialETH;
        reserveToken = initialToken;
    }

    function getSpotPrice() public view returns (uint256) {
        return reserveToken * 1 ether / reserveETH;
    }

    function swapETHForToken() external payable returns (uint256) {
        require(msg.value > 0, "No ETH");

        uint256 tokenOut =
            (reserveToken * msg.value) /
            (reserveETH + msg.value);

        reserveETH += msg.value;
        reserveToken -= tokenOut;

        return tokenOut;
    }
}