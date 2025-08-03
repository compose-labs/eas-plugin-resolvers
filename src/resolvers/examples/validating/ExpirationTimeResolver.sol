// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Attestation} from "eas-contracts/IEAS.sol";

import {IValidatingResolver} from "../../../interfaces/IValidatingResolver.sol";

/// @title ExpirationTimeResolver
/// @notice A sample validating resolver that checks whether the expiration time is later than a specific timestamp.
contract ExpirationTimeResolver is IValidatingResolver {
    ////////////////////////////// State //////////////////////////////

    uint256 private immutable I_VALID_AFTER;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(uint256 validAfter) {
        I_VALID_AFTER = validAfter;
    }

    //////////////////////////////// Validating Resolver //////////////////////////////

    function onAttest(Attestation calldata attestation, uint256 /* value */ ) external view returns (bool) {
        return attestation.expirationTime >= I_VALID_AFTER;
    }

    function onRevoke(Attestation calldata, /* attestation */ uint256 /* value */ ) external pure returns (bool) {
        return true;
    }
}
