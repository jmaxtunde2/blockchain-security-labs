// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SlippageProtectedAMM {
    uint256 public reserveETH;
    uint256 public reserveToken;

    // Basis point
    uint256 public constant FEE_BPS = 30;
    uint256 public constant BPS = 10_000;

    // Errors
    error InvalidAmount();
    error InsufficientLiquidity();
    error SlippageExceeded();

    // Constructor
    constructor(uint256 initialETH, uint256 initialToken) payable{
        if(initialETH == 0 || initialToken == 0){
            revert InvalidAmount();
        }

        // Initialisation
        reserveETH = initialETH;
        reserveToken = initialToken;
    }

    function getAmountOut(uint256 amountIn) public view returns (uint256) {
        if(amountIn == 0){
            revert InvalidAmount();
        } 

        uint256 fee = amountIn * FEE_BPS/BPS; 
        uint256 amountAfterFee = amountIn - fee;

        uint256 amountOut = (reserveToken * amountAfterFee)/ (reserveETH + amountAfterFee);

        if(amountOut == 0 || amountOut >= reserveToken){
            revert InsufficientLiquidity();
        }

        return amountOut;
    }

    function swapETHForToken(uint256 amountOutMin) 
        external 
        payable
        returns (uint256 amountOut)
    {
        amountOut = getAmountOut(msg.value);

        if(amountOut < amountOutMin){
            revert SlippageExceeded();
        }
        
        reserveETH += msg.value;
        reserveToken -= amountOut;

        (bool success,) = msg.sender.call{value:amountOut}("");
        require(success, "Transaction failed");
    }
}