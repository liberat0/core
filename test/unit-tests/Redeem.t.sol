// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/Napoli.sol";

import "../mocks/MockERC20.sol";

contract Redeem is Test {
    Napoli public napoli;
    MockERC20 public weth;
    uint256 public price = 20e18;
    uint256 public fee = 2e18;
    address public feeRecipient = address(0xdead);

    function setUp() public {
        weth = new MockERC20("WETH", "WETH");
        napoli = new Napoli("https://napoli.testnet/", address(weth), price, fee, feeRecipient);

        weth.mint(address(this), 200e18);
        weth.approve(address(napoli), type(uint256).max);
    }

    function testRedeemFirstTicket() public {
        // arrrange
        napoli.buy(2);

        // act
        napoli.redeem(1);

        // assert
        assertEq(weth.balanceOf(address(napoli)), 0);
    }

    function testRedeemSecondTicket() public {
        // arrrange
        napoli.buy(4);

        // act
        napoli.redeem(2);

        // assert
        assertEq(weth.balanceOf(address(napoli)), price * 2);
    }

    function testCannotDoubleRedeem() public {
        // arrrange
        napoli.buy(4);
        napoli.redeem(1);

        // act
        vm.expectRevert(IERC721A.OwnerQueryForNonexistentToken.selector);
        napoli.redeem(1);
    }

    function testCannotRedeemImmediately() public {
        // arrrange
        napoli.buy(1);

        // act
        vm.expectRevert(INapoli.TooEarly.selector);
        napoli.redeem(1);
    }

    function testCannotRedeemFromNonOwner() public {
        // arrrange
        napoli.buy(2);

        // act
        vm.expectRevert(INapoli.Auth.selector);
        vm.prank(address(0xbeef));
        napoli.redeem(1);
    }
}
