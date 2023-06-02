// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/ERC721A/contracts/ERC721A.sol";

contract Napoli is ERC721A {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    /// @dev token used
    address immutable public token;

    /// @dev price per ticket
    uint256 immutable public price;

    /// @dev total tickets sold
    uint256 public totalTickets;

    error TooEarly();

    error Auth();

    constructor(address _token, uint256 _price) ERC721A("NAPOLI", "NAPOLI"){
        token = _token;
        price = _price;
    }

    function tokenURI(uint256 id) public pure override returns (string memory uri) {
        uri = string.concat("https://", id.toString());
    }

    function deposit(uint quantity) external {
        // transfer from
        IERC20(token).safeTransferFrom(msg.sender, address(this), quantity * price);

        // mint token
        _mint(msg.sender, quantity);
    }

    function withdraw(uint id) public {
        // check
        if (msg.sender != ownerOf(id)) revert Auth();
        if (_nextTokenId() - 1 < id * 2) revert TooEarly();

        // burn receipt
        _burn(id);

        // transfer 2x
        IERC20(token).safeTransfer(msg.sender, price * 2);
    }

    /**
     * @dev Returns the starting token ID.
     */
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
