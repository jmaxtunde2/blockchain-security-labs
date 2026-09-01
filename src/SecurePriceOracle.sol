// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract SecurePriceOracle {
    address public owner;
    uint256 private price;

    constructor(uint256 initialPrice) {
        owner = msg.sender;
        price = initialPrice;
    }

    function setPrice(uint256 newPrice) external {
        require(
            msg.sender == owner,
            "Not Oracle Owner"
        );
        price = newPrice;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }
}