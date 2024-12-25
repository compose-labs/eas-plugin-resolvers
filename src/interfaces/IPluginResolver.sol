// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {ISchemaResolver} from "eas-contracts/resolver/ISchemaResolver.sol";

import {IValidatingResolver} from "./IValidatingResolver.sol";
import {IExecutingResolver} from "./IExecutingResolver.sol";

/**
 * @title IPluginResolver
 * @author Kyle Kaplan
 * @dev Interface for the PluginResolver contract which manages an array of validating and executing resolver contracts
 */
interface IPluginResolver is ISchemaResolver {
    ////////////////////////////// Events //////////////////////////////

    /// @notice Emitted when an executing resolver fails, but the error is caught
    event ExecutingResolverFailed(
        IExecutingResolver indexed resolver,
        bool indexed isAttestation
    );

    /// @notice Emitted when a validating resolver is added.
    event ValidatingResolverAdded(IValidatingResolver indexed resolver);

    /// @notice Emitted when a validating resolver is removed.
    event ValidatingResolverRemoved(IValidatingResolver indexed resolver);

    /// @notice Emitted when an executing resolver is added.
    event ExecutingResolverAdded(IExecutingResolver indexed resolver);

    /// @notice Emitted when an executing resolver is removed.
    event ExecutingResolverRemoved(IExecutingResolver indexed resolver);

    /// @notice Emitted when the catch executing resolver errors flag is set
    /// @param catchErrors The new value of the flag
    event CatchExecutingResolverErrorsSet(bool catchErrors);

    ////////////////////////////// Errors //////////////////////////////

    error PluginResolver__IndexOutOfBounds(uint256 index, uint256 length);
    error PluginResolver__InvalidResolver(address resolver);
    error PluginResolver__DuplicateResolver(address resolver);

    ////////////////////////////// Functions //////////////////////////////

    /// @notice Sets whether to catch executing resolver errors
    /// @param catchErrors Whether to catch executing resolver errors
    function setCatchExecutingResolverErrors(bool catchErrors) external;

    /// @notice Returns whether to catch executing resolver errors
    /// @return Whether to catch executing resolver errors
    function getCatchExecutingResolverErrors() external view returns (bool);

    /// @notice Adds a validating resolver to the array
    /// @param resolver The resolver to add
    function addValidatingResolver(IValidatingResolver resolver) external;

    /// @notice Removes a validating resolver from the array
    /// @param resolver The resolver to remove
    function removeValidatingResolver(IValidatingResolver resolver) external;

    /// @notice Returns the length of the validatingResolvers array
    /// @return The number of validating resolvers
    function getValidatingResolversLength() external view returns (uint256);

    /// @notice Returns the validating resolver at the given index
    /// @param index The index of the resolver to return
    /// @return The validating resolver at the given index
    function getValidatingResolverAt(
        uint256 index
    ) external view returns (IValidatingResolver);

    /// @notice Adds an executing resolver to the array
    /// @param resolver The resolver to add
    function addExecutingResolver(IExecutingResolver resolver) external;

    /// @notice Removes an executing resolver from the array
    /// @param resolver The resolver to remove
    function removeExecutingResolver(IExecutingResolver resolver) external;

    /// @notice Returns the length of the executingResolvers array
    /// @return The number of executing resolvers
    function getExecutingResolversLength() external view returns (uint256);

    /// @notice Returns the executing resolver at the given index
    /// @param index The index of the resolver to return
    /// @return The executing resolver at the given index
    function getExecutingResolverAt(
        uint256 index
    ) external view returns (IExecutingResolver);
}
