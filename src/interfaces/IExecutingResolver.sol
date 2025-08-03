// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Attestation} from "eas-contracts/IEAS.sol";

interface IExecutingResolver {
    /// @notice A resolver callback that should be called by the plugin resolver.
    /// @param attestation The new attestation.
    /// @param value An explicit ETH amount that was sent to the resolver. Please note that this value is verified in
    ///     both attest() and multiAttest() callbacks EAS-only callbacks and that in case of multi attestations, it'll
    ///     usually hold that msg.value != value, since msg.value aggregated the sent ETH amounts for all the
    ///     attestations in the batch.
    function onAttest(Attestation calldata attestation, uint256 value) external;

    /// @notice A resolver callback that should be called by the plugin resolver.
    /// @param attestation The existing attestation to be revoked.
    /// @param value An explicit ETH amount that was sent to the resolver. Please note that this value is verified in
    ///     both revoke() and multiRevoke() callbacks EAS-only callbacks and that in case of multi attestations, it'll
    ///     usually hold that msg.value != value, since msg.value aggregated the sent ETH amounts for all the
    ///     attestations in the batch.
    function onRevoke(Attestation calldata attestation, uint256 value) external;
}
