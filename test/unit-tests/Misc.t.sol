// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/Napoli.sol";

import "../mocks/MockERC20.sol";

contract BuyTest is Test {
    Napoli public napoli;
    MockERC20 public weth;
    uint256 public price = 20e18;

    function setUp() public {
        weth = new MockERC20("WETH", "WETH");

        napoli = new Napoli("https://napoli.testnet/", address(weth), price, 0, address(0));
    }

    function testURL() public {
        // assertion
        assertEq(napoli.tokenURI(1), "https://napoli.testnet/1");
    }

    function testSetRecipient() public {
        // act
        napoli.setRecipient(address(0xaa));

        // assertion
        assertEq(napoli.feeRecipient(), address(0xaa));
    }
}
