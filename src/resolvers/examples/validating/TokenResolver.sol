// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Attestation} from "eas-contracts/IEAS.sol";

import {IValidatingResolver} from "../../../interfaces/IValidatingResolver.sol";

/// @title TokenResolver
/// @notice A sample schema resolver that checks whether a specific amount of tokens was approved to be included in an attestation.
contract TokenResolver is IValidatingResolver {
    using SafeERC20 for IERC20;

    ////////////////////////////// Errors //////////////////////////////

    error InvalidAllowance();

    ////////////////////////////// State //////////////////////////////

    IERC20 private immutable _targetToken;
    uint256 private immutable _targetAmount;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(IERC20 targetToken, uint256 targetAmount) {
        _targetToken = targetToken;
        _targetAmount = targetAmount;
    }

    //////////////////////////////// Validating Resolver //////////////////////////////

    function onAttest(
        Attestation calldata attestation,
        uint256 /* value */
    ) external view returns (bool) {
        if (
            _targetToken.allowance(attestation.attester, address(this)) <
            _targetAmount
        ) {
            revert InvalidAllowance();
        }

        return true;
    }

    function onRevoke(
        Attestation calldata /* attestation */,
        uint256 /* value */
    ) external pure returns (bool) {
        return true;
    }
}
