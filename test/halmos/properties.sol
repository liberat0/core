// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "../mocks/MockERC20.sol";

import "src/Napoli.sol";

import "lib/forge-std/src/console2.sol";
import "lib/forge-std/src/Test.sol";

contract NapoliInvariants is Napoli, Test {
    constructor(string memory _base, address _token, uint256 _price, uint256 _fee, address _feeRecipient)
        Napoli(_base, _token, _price, _fee, _feeRecipient)
    {}

    function testBuyOtherBalancePreservation(uint256 quantity, address buyer, address others) public {
        require(others != buyer);

        uint256 oldBalanceOther = balanceOf(others);

        _buy(quantity, buyer);

        uint256 newBalanceOther = balanceOf(others);

        assert(newBalanceOther == oldBalanceOther);
    }

    function testBuyTotalSupplyPreservation(uint256 quantity, address buyer) public {
        require(buyer != address(0));

        uint256 oldBalance = _nextTokenId();

        _buy(quantity, buyer);

        uint256 newBalance = _nextTokenId();

        assert(newBalance == oldBalance + quantity);
    }

    function testRedeemBalancePreservation(uint256 id) public {
        address owner = ownerOf(id);
        require(owner != address(0));

        uint256 oldBalance = balanceOf(owner);

        _redeem(id, owner);

        uint256 newBalance = balanceOf(owner);

        assert(newBalance == oldBalance - 1);
    }
}
