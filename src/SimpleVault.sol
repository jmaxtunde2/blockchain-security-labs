// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SimpleVault {
    using SafeERC20 for IERC20;

    uint256 public totalShare;
    IERC20 public immutable asset;

    mapping (address => uint256) share;

    error InvalidAmount();
    error InsufficientShare();

    constructor(address asset_){
        asset = IERC20(asset_);
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function convertToShares(uint256 assets)
    public
    view
    returns (uint256)
    {
       if(assets == 0){
            revert InvalidAmount();
       }
    }
}