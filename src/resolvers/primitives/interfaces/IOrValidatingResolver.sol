// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IValidatingResolver} from "../../../interfaces/IValidatingResolver.sol";

interface IOrValidatingResolver is IValidatingResolver {
    ////////////////////////////// Events //////////////////////////////

    /// @notice Emitted when a validating resolver is added.
    event ValidatingResolverAdded(IValidatingResolver indexed resolver);

    /// @notice Emitted when a validating resolver is removed.
    event ValidatingResolverRemoved(IValidatingResolver indexed resolver);

    ////////////////////////////// Errors //////////////////////////////

    error OrValidatingResolver__InvalidResolver(address resolver);
    error OrValidatingResolver__DuplicateResolver(address resolver);

    ////////////////////////////// External Functions //////////////////////////////

    function addValidatingResolver(IValidatingResolver _resolver) external;

    function removeValidatingResolver(IValidatingResolver _resolver) external;
}
