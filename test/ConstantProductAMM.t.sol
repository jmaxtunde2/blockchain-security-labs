// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {ConstantProductAMM} from "../src/ConstantProductAMM.sol";

contract ConstantProductAMMTest is Test {

    ConstantProductAMM public amm;

    address trader = makeAddr("trader");

    uint256 constant INITIAL_ETH = 10 ether;
    uint256 constant INITIAL_TOKEN = 100 ether;

    function setUp() public {
        amm = new ConstantProductAMM{
            value: INITIAL_ETH
        }(
            INITIAL_ETH,
            INITIAL_TOKEN
        );

        vm.deal(trader, 1000 ether);
    }

    function test_InitialReserves() public view {
        assertEq(amm.reserveETH(), INITIAL_ETH);
        assertEq(amm.reserveToken(), INITIAL_TOKEN);
    }

    function test_GetAmountOut() public view {
        uint256 amountOut = amm.getAmountOut(1 ether);

        assertGt(amountOut, 0);
        assertLt(amountOut, INITIAL_TOKEN);
    }

    function test_CannotUseZeroAmount() public {
        vm.expectRevert(
            ConstantProductAMM.InvalidAmount.selector
        );

        amm.getAmountOut(0);
    }

    function test_CannotSwapZeroETH() public {
        vm.prank(trader);

        vm.expectRevert(
            ConstantProductAMM.InvalidAmount.selector
        );

        amm.swapETHForToken{value: 0}();
    }

    function test_SwapReturnsTokens() public {
        vm.prank(trader);

        uint256 amountOut =
            amm.swapETHForToken{value: 1 ether}();

        assertGt(amountOut, 0);
    }

    function test_SwapUpdatesReserves() public {
        uint256 ethBefore = amm.reserveETH();
        uint256 tokenBefore = amm.reserveToken();

        vm.prank(trader);

        uint256 amountOut =
            amm.swapETHForToken{value: 1 ether}();

        assertEq(
            amm.reserveETH(),
            ethBefore + 1 ether
        );

        assertEq(
            amm.reserveToken(),
            tokenBefore - amountOut
        );
    }

    function test_SwapChangesPrice() public {
        uint256 amountOutBefore =
            amm.getAmountOut(1 ether);

        vm.prank(trader);

        amm.swapETHForToken{value: 1 ether}();

        uint256 amountOutAfter =
            amm.getAmountOut(1 ether);

        assertLt(amountOutAfter, amountOutBefore);
    }

    function test_LargeSwapCannotCompletelyDrainReserve() public {
        uint256 reserveBefore = amm.reserveToken();

        vm.prank(trader);
        uint256 amountOut = amm.swapETHForToken{value: 1000 ether}();

        uint256 reserveAfter = amm.reserveToken();

        assertLt(amountOut, reserveBefore);
        assertGt(reserveAfter, 0);
    }

    
}

