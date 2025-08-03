// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Attestation} from "eas-contracts/IEAS.sol";

import {IExecutingResolver} from "../../../interfaces/IExecutingResolver.sol";

/// @title SendTokensResolver
/// @notice A sample schema resolver that sends a specific amount of tokens to an attester.
contract SendTokensResolver is IExecutingResolver {
    using SafeERC20 for IERC20;

    ////////////////////////////// Errors //////////////////////////////

    error InvalidAmount();
    error InvalidToken();
    error InvalidFromAddress();

    ////////////////////////////// Events //////////////////////////////

    event TokensSent(address indexed attester, uint256 amount);

    ////////////////////////////// State //////////////////////////////

    IERC20 private immutable I_TARGET_TOKEN;
    uint256 private immutable I_TARGET_AMOUNT;
    address private immutable I_FROM_ADDRESS;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(IERC20 targetToken, uint256 targetAmount, address fromAddress) {
        if (address(targetToken) == address(0)) revert InvalidToken();
        if (targetAmount == 0) revert InvalidAmount();
        if (fromAddress == address(0)) revert InvalidFromAddress();

        I_TARGET_TOKEN = targetToken;
        I_TARGET_AMOUNT = targetAmount;
        I_FROM_ADDRESS = fromAddress;
    }

    //////////////////////////////// Executing Resolver //////////////////////////////

    function onAttest(Attestation calldata attestation, uint256 /* value */ ) external {
        // Ensure the attester is not address(0)
        if (attestation.attester == address(0)) revert InvalidFromAddress();

        I_TARGET_TOKEN.safeTransferFrom(I_FROM_ADDRESS, attestation.attester, I_TARGET_AMOUNT);
        emit TokensSent(attestation.attester, I_TARGET_AMOUNT);
    }

    function onRevoke(Attestation calldata, /* attestation */ uint256 /* value */ ) external pure {}

    ////////////////////////////// Getters //////////////////////////////

    /// @notice Returns the token that will be transferred
    function getTargetToken() external view returns (IERC20) {
        return I_TARGET_TOKEN;
    }

    /// @notice Returns the amount of tokens that will be transferred
    function getTargetAmount() external view returns (uint256) {
        return I_TARGET_AMOUNT;
    }

    /// @notice Returns the address tokens will be transferred from
    function getFromAddress() external view returns (address) {
        return I_FROM_ADDRESS;
    }
}
