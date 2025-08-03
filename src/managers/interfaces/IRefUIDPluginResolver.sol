// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ISchemaResolver} from "eas-contracts/resolver/ISchemaResolver.sol";

import {PluginResolver} from "../../PluginResolver.sol";
import {IExecutingResolver} from "../../interfaces/IExecutingResolver.sol";

/**
 * @title IRefUIDPluginResolver
 * @dev Interface for the PluginResolver contract which manages an array of validating and executing resolver contracts
 */
interface IRefUIDPluginResolver is ISchemaResolver {
    ////////////////////////////// Events //////////////////////////////

    /// @notice Emitted when the refUID to pluginResolver mapping is set
    event RefUIDToPluginResolverSet(
        bytes32 indexed refUID,
        PluginResolver indexed pluginResolver
    );

    /// @notice Emitted when an executing resolver fails, but the error is caught
    event ExecutingResolverFailed(
        IExecutingResolver indexed resolver,
        bool indexed isAttestation
    );

    ////////////////////////////// Errors //////////////////////////////

    error RefUIDPluginResolver__InvalidSchema(
        bytes32 providedSchema,
        bytes32 expectedSchema
    );

    error RefUIDPluginResolver__Unauthorized(
        address providedSender,
        address expectedSender
    );

    error RefUIDPluginResolver__SchemaUIDAlreadySet();

    ////////////////////////////// Functions //////////////////////////////

    /// @notice Sets the intended schema UID
    /// @param _intendedSchemaUID The intended schema UID
    function setIntendedSchemaUID(bytes32 _intendedSchemaUID) external;

    /// @notice Sets the refUID to the pluginResolver
    /// @param refUID The refUID to set
    /// @param pluginResolver The pluginResolver to set
    function setRefUIDToPluginResolver(
        bytes32 refUID,
        PluginResolver pluginResolver
    ) external;
}
