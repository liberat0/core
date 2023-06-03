// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @title INapoli
 * @notice Interface for Napoli
 */
interface INapoli {
    // =============================================================
    //                            Errors
    // =============================================================

    /// @dev not enough following deposits
    error TooEarly();

    /// @dev cannot redeem on behalf on this token
    error Auth();

    // =============================================================
    //                            Events
    // =============================================================

    event Purchase(address account, uint256 quantity);

    event Redeem(uint256 id);

    event FeeRecipientUpdated(address newRecipient);
}
