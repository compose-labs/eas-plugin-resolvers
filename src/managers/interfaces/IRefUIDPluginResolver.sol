// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ISchemaResolver} from "eas-contracts/resolver/ISchemaResolver.sol";

import {PluginResolver} from "../../PluginResolver.sol";
import {IExecutingResolver} from "../../interfaces/IExecutingResolver.sol";

/**
 * @title IRefUidPluginResolver
 * @dev Interface for the PluginResolver contract which manages an array of validating and executing resolver contracts
 */
interface IRefUidPluginResolver is ISchemaResolver {
    ////////////////////////////// Events //////////////////////////////

    /// @notice Emitted when the refUid to pluginResolver mapping is set
    event RefUidToPluginResolverSet(bytes32 indexed refUid, PluginResolver indexed pluginResolver);

    /// @notice Emitted when an executing resolver fails, but the error is caught
    event ExecutingResolverFailed(IExecutingResolver indexed resolver, bool indexed isAttestation);

    ////////////////////////////// Errors //////////////////////////////

    error RefUidPluginResolver__InvalidSchema(bytes32 providedSchema, bytes32 expectedSchema);

    error RefUidPluginResolver__Unauthorized(address providedSender, address expectedSender);

    error RefUidPluginResolver__SchemaUidAlreadySet();

    ////////////////////////////// Functions //////////////////////////////

    /// @notice Sets the intended schema UID
    /// @param _intendedSchemaUid The intended schema UID
    function setIntendedSchemaUid(bytes32 _intendedSchemaUid) external;

    /// @notice Sets the refUid to the pluginResolver
    /// @param refUid The refUid to set
    /// @param pluginResolver The pluginResolver to set
    function setRefUidToPluginResolver(bytes32 refUid, PluginResolver pluginResolver) external;
}
