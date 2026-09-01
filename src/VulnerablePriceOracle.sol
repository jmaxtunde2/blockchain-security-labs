// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerablePriceOracle {
    uint256 public tokenPrice;

    constructor(uint256 _initialPrice){
        tokenPrice = _initialPrice;
    }

    function setPrice(uint256 newPrice) external {
        tokenPrice = newPrice;
    }

    function getPrice() external view returns (uint256) {
        return tokenPrice;
    }
}