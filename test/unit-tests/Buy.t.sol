// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/Napoli.sol";

import "../mocks/MockERC20.sol";

contract BuyTest is Test {
    Napoli public napoli;
    MockERC20 public weth;

    uint256 public price = 20e18;
    uint256 public fee = 2e18;

    address feeRecipient = address(0xdead);

    function setUp() public {
        weth = new MockERC20("WETH", "WETH");

        napoli = new Napoli("https://napoli.testnet/", address(weth), price, fee, feeRecipient);

        weth.mint(address(this), 2000e18);
        weth.approve(address(napoli), type(uint256).max);
    }

    function testBuyOne() public {
        // act
        napoli.buy(1);

        // assertion
        assertEq(napoli.balanceOf(address(this)), 1);
        assertEq(napoli.ownerOf(1), address(this));
        assertEq(napoli.totalSold(), 1);
        assertEq(weth.balanceOf(address(napoli)), price);
        assertEq(weth.balanceOf(address(feeRecipient)), fee);
    }

    function testBuyTen() public {
        // act
        napoli.buy(10);

        // assertion
        assertEq(napoli.balanceOf(address(this)), 10);
        assertEq(napoli.ownerOf(10), address(this));
        assertEq(napoli.totalSold(), 10);
        assertEq(weth.balanceOf(address(napoli)), price * 10);
        assertEq(weth.balanceOf(address(feeRecipient)), fee * 10);
    }
}
