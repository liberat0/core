// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/ERC721A/contracts/ERC721A.sol";

/**
 * @title Napoli
 * @notice Napoli is a ponzi game, where the N th person who deposits, need to wait until 2xN total participants to get 2x and leave the pool
 */
contract Napoli is ERC721A {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    /// @dev token used
    address public immutable token;

    /// @dev price per ticket
    uint256 public immutable price;

    /// @dev total tickets sold
    uint256 public totalTickets;

    /// @dev not enough following deposits
    error TooEarly();

    /// @dev cannot redeem on behalf on this token
    error Auth();

    constructor(address _token, uint256 _price) ERC721A("NAPOLI", "NAPOLI") {
        token = _token;
        price = _price;
    }

    function tokenURI(uint256 id) public pure override returns (string memory uri) {
        uri = string.concat("https://", id.toString());
    }

    /**
     * @dev buy tickets
     */
    function buy(uint256 quantity) external {
        // transfer from
        IERC20(token).safeTransferFrom(msg.sender, address(this), quantity * price);

        // mint token
        _mint(msg.sender, quantity);
    }

    /**
     * @dev redeem ticket when total price is enough
     */
    function redeem(uint256 id) public {
        // check msg.sender
        if (msg.sender != ownerOf(id)) revert Auth();
        if (_nextTokenId() - 1 < id * 2) revert TooEarly();

        // burn receipt
        _burn(id);

        // transfer 2x
        IERC20(token).safeTransfer(msg.sender, price * 2);
    }

    /**
     * @dev returns the total amount of ticket sold
     */
    function totalSold() external view returns (uint256) {
        return _nextTokenId() - 1;
    }

    /**
     * @dev returns the starting token ID.
     * @dev this is overriding ERC721A contract
     */
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
