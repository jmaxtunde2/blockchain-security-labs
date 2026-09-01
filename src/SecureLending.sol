// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SecurePriceOracle} from '../src/SecurePriceOracle.sol';

contract SecureLending {
    SecurePriceOracle public oracle;

    mapping (address => uint256) public collateral;   
    mapping (address => uint256) public debt; 

    constructor(address oracleAddress){
        oracle = SecurePriceOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint256 amount) external {
        uint256 price = oracle.getPrice();

        uint256 collateralValue =
            collateral[msg.sender] * price / 1 ether;

        require(
            collateralValue >= debt[msg.sender] + amount,
            "Insufficient collateral"
        );

        debt[msg.sender] += amount;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}