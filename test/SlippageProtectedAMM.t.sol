// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {SlippageProtectedAMM} from '../src/SlippageProtectedAMM.sol';

contract SlippageProtectedAMMTest is Test {
    SlippageProtectedAMM public amms;
    address trader = makeAddr('trader');

    uint256 constant INITIAL_ETH = 10 ether;
    uint256 constant INITIAL_TOKEN = 100 ether;

    function setUp() public {
        amms = new SlippageProtectedAMM{value:INITIAL_ETH}(INITIAL_ETH, INITIAL_TOKEN);

        vm.deal(trader,1000 ether);
    }

    function test_InitialReserves() public view {
        assertEq(amms.reserveETH(), INITIAL_ETH);
        assertEq(amms.reserveToken(), INITIAL_TOKEN);
    }

    function  test_GetAmountOut() public view {

        uint256 amountOut = amms.getAmountOut(1 ether);

        assertGt(amountOut,0);
        assertLt(amountOut, INITIAL_TOKEN);
        
    }

    function test_Cannot_Use_ZeroAmount() public {
        vm.expectRevert(SlippageProtectedAMM.InvalidAmount.selector);

        amms.getAmountOut(0);
    }

    function test_NormalSwapSucceed() public {
        uint256 initialEth = amms.reserveETH();
        uint256 initialToken = amms.reserveToken();

        uint256 expectedAmountOutput = amms.getAmountOut(1 ether);
        vm.prank(trader);
        uint256 actualAmount = amms.swapETHForToken{value:1 ether}(expectedAmountOutput);

        assertEq(expectedAmountOutput,actualAmount);
        assertEq(amms.reserveETH(),initialEth + 1 ether);
        assertEq(amms.reserveToken(),initialToken-actualAmount);
    }

    function test_SwapRevertAmoutOutputLessThanAmountSlipExpected() public{
        uint256 expectedAmoutOutput = amms.getAmountOut(1 ether);
        uint256 amountOutMin = expectedAmoutOutput + 2;
         vm.expectRevert(SlippageProtectedAMM.SlippageExceeded.selector);
         vm.prank(trader);
    
      amms.swapETHForToken{value:1 ether}(amountOutMin);

    }

    function test_ZeroInputReverted() public {
        uint256 initialETH = amms.reserveETH();
        uint256 initialToken = amms.reserveToken();

        vm.expectRevert(SlippageProtectedAMM.InvalidAmount.selector);

        vm.prank(trader);
        amms.swapETHForToken{value: 0}(0);

        assertEq(amms.reserveETH(), initialETH);
        assertEq(amms.reserveToken(), initialToken);
    }

    function test_ConstantProductInvariant_SmallSwap() public {
        uint256 initialK =
            amms.reserveETH() * amms.reserveToken();

        uint256 amountOut =
            amms.getAmountOut(0.1 ether);

        vm.prank(trader);
        amms.swapETHForToken{value: 0.1 ether}(amountOut);

        uint256 finalK =
            amms.reserveETH() * amms.reserveToken();

        assertGt(finalK, initialK);
    }

    function test_ConstantProductInvariant_MediumSwap() public {
        uint256 initialK =
            amms.reserveETH() * amms.reserveToken();

        uint256 amountOut =
            amms.getAmountOut(1 ether);

        vm.prank(trader);
        amms.swapETHForToken{value: 1 ether}(amountOut);

        uint256 finalK =
            amms.reserveETH() * amms.reserveToken();

        assertGt(finalK, initialK);
    }

    function test_ConstantProductInvariant_LargeSwap() public {
        uint256 initialK =
            amms.reserveETH() * amms.reserveToken();

        uint256 amountOut =
            amms.getAmountOut(5 ether);

        vm.prank(trader);
        amms.swapETHForToken{value: 5 ether}(amountOut);

        uint256 finalK =
            amms.reserveETH() * amms.reserveToken();

        assertGt(finalK, initialK);
    }
}