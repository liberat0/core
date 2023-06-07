// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/ERC721A/contracts/ERC721A.sol";

import "./INapoli.sol";

/**
 * @title Napoli
 * @notice Napoli is a ponzi game, where the N th person who deposits, need to wait until 2xN total participants to get 2x and leave the pool
 */
contract Napoli is ERC721A, Ownable, INapoli {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    // =============================================================
    //                           Immutables
    // =============================================================

    /// @dev token used
    address public immutable token;

    /// @dev price per ticket
    uint256 public immutable price;

    /// @dev fee paid to fee recipient at deposit
    uint256 public immutable fee;

    // =============================================================
    //                            Storage
    // =============================================================

    /// @dev base url that cannot be changed
    string private base;

    /// @dev fee recipient address
    address public feeRecipient;

    // =============================================================
    //                          Constructor
    // =============================================================

    constructor(string memory _base, address _token, uint256 _price, uint256 _fee, address _feeRecipient)
        ERC721A("NAPOLI", "NAPOLI")
    {
        base = _base;
        token = _token;
        price = _price;
        fee = _fee;
        feeRecipient = _feeRecipient;
    }

    // =============================================================
    //                         View Functions
    // =============================================================

    /**
     * @dev return uri which stores the token metadata
     */
    function tokenURI(uint256 id) public view override returns (string memory uri) {
        uri = string.concat(base, id.toString());
    }

    // =============================================================
    //                         Owner Settings
    // =============================================================

    /**
     * @dev owner can set the new recipient, but cannot change the fee
     */
    function setRecipient(address newRecipient) external onlyOwner {
        feeRecipient = newRecipient;

        emit FeeRecipientUpdated(newRecipient);
    }

    /**
     * @notice buy tickets
     */
    function buy(uint256 quantity) external {
        _buy(quantity, msg.sender);
    }

    /**
     * @notice redeem ticket when total supply is high enough
     */
    function redeem(uint256 id) external {
        _redeem(id, msg.sender);
    }

    /**
     * @dev transfer quantity and fee from sender, mint receipt in return
     */
    function _buy(uint256 quantity, address from) internal {
        // transfer price to lock in
        IERC20(token).safeTransferFrom(from, address(this), price * quantity);

        // transfer fee
        if (fee != 0 && feeRecipient != address(0)) {
            IERC20(token).safeTransferFrom(from, feeRecipient, fee * quantity);
        }

        // mint token
        _mint(from, quantity);

        emit Purchase(from, quantity);
    }

    /**
     * @dev burn token and get back 2x price when there is enough total minters
     */
    function _redeem(uint256 id, address sender) internal {
        // check msg.sender
        if (sender != ownerOf(id)) revert Auth();
        if (_nextTokenId() - 1 < id * 2) revert TooEarly();

        // burn receipt
        _burn(id);

        // transfer 2x
        IERC20(token).safeTransfer(sender, price * 2);

        emit Redeem(id);
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
