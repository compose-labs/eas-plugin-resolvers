// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {SchemaResolver} from "eas-contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/IEAS.sol";

import {PluginResolver} from "../PluginResolver.sol";
import {IRefUIDPluginResolver} from "./interfaces/IRefUIDPluginResolver.sol";
import {Semver} from "../utils/Semver.sol";

/**
 * @title RefUIDPluginResolver
 * @dev A resolver that allows the PluginResolver to be set, based on the refUID of the attestation.
 *      A PluginResolver can only be set for a refUID by the referenced attestation attester.
 *      This contract is not owned and is meant to be immutable so that the schema connected to this resolver is credibly neutral.
 *      To protect against abuse, the setRefUIDToPluginResolver function can only be called by the attester of the referenced attestation.
 *      Remember that a PluginResolver is ownable and the installed plugins can be changed by the owner.
 *      This allows a schema to be created once, but re-used with many different resolvers (assuming attestations are indended to reference another attestation)
 *      For example:
 *          - A schema is created for a product
 *          - A schema is created for ordering a product with this RefUIDPluginResolver set as the resolver
 *          - Someone creates a product by attesting to the product schema
 *          - They create a PluginResolver for that product, and call the setRefUIDToPluginResolver function on the order schema resolver (this contract) to set the PluginResolver for their product's orders
 *          - Order attestations reference product attestations and the appropriate PluginResolver is used to validate and execute the order
 */
contract RefUIDPluginResolver is Semver, SchemaResolver, IRefUIDPluginResolver {
    ////////////////////////////// State //////////////////////////////

    // the schemaUid that this resolver is intended to be set on
    bytes32 public INTENDED_SCHEMA_UID;
    // a flag to make sure the INTENDED_SCHEMA_UID is only set once
    bool private schemaSet = false;
    // a mapping to store the PluginResolver for each refUID
    mapping(bytes32 refUID => PluginResolver pluginResolver)
        public refUIDToPluginResolver;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(address _eas) Semver(0, 0, 1) SchemaResolver(IEAS(_eas)) {}

    ////////////////////////////// External Functions //////////////////////////////

    /// @inheritdoc IRefUIDPluginResolver
    function setIntendedSchemaUid(bytes32 _intendedSchemaUid) external {
        if (schemaSet) {
            revert RefUIDPluginResolver__SchemaUidAlreadySet();
        }
        INTENDED_SCHEMA_UID = _intendedSchemaUid;
        schemaSet = true;
    }

    /// @inheritdoc IRefUIDPluginResolver
    function setRefUIDToPluginResolver(
        bytes32 refUID,
        PluginResolver pluginResolver
    ) external {
        Attestation memory attestation = _eas.getAttestation(refUID);
        // make sure attester is msg.sender
        if (attestation.attester != msg.sender) {
            revert RefUIDPluginResolver__Unauthorized(
                msg.sender,
                attestation.attester
            );
        }
        refUIDToPluginResolver[refUID] = pluginResolver;
        emit RefUIDToPluginResolverSet(refUID, pluginResolver);
    }

    ////////////////////////////// Internal Functions //////////////////////////////

    /// @dev First loops through the validatingResolvers and calls onAttest on each,
    ///     if all validatingResolvers return true, it then (and only then)
    ///     loops through the executingResolvers and calls onAttest on each
    /// @param attestation The attestation to validate
    /// @param value The value of the attestation
    function onAttest(
        Attestation calldata attestation,
        uint256 value
    ) internal override returns (bool) {
        // make sure the attestation is coming from the the intended schema (make sure someone didn't put this resolver contract on an unintended schema)
        if (attestation.schema != INTENDED_SCHEMA_UID) {
            revert RefUIDPluginResolver__InvalidSchema(
                attestation.schema,
                INTENDED_SCHEMA_UID
            );
        }
        // use the refUID to find the pluginResolver
        PluginResolver pluginResolver = refUIDToPluginResolver[
            attestation.refUID
        ];
        // if the pluginResolver is not set, just return true to let the attestation go through
        if (address(pluginResolver) == address(0)) {
            return true;
        }
        // iterate over validatingResolvers and call onAttest on each. If any fail, return false
        uint256 validatingResolversLength = pluginResolver
            .getValidatingResolversLength();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (
                !pluginResolver.getValidatingResolverAt(i).onAttest(
                    attestation,
                    value
                )
            ) {
                return false;
            }
        }
        // iterate over executingResolvers and call onAttest on each
        // if the catchExecutingResolverErrors flag is set, catch the errors and return true
        bool catchExecutingResolverErrors = pluginResolver
            .getCatchExecutingResolverErrors();
        uint256 executingResolversLength = pluginResolver
            .getExecutingResolversLength();
        for (uint256 i = 0; i < executingResolversLength; i++) {
            if (catchExecutingResolverErrors) {
                try
                    pluginResolver.getExecutingResolverAt(i).onAttest(
                        attestation,
                        value
                    )
                {
                    // Execution successful, continue to the next resolver
                } catch {
                    // Emit event with the address of the failed executing resolver
                    emit ExecutingResolverFailed(
                        pluginResolver.getExecutingResolverAt(i),
                        true
                    );
                }
            } else {
                pluginResolver.getExecutingResolverAt(i).onAttest(
                    attestation,
                    value
                );
            }
        }
        return true;
    }

    /// @dev First loops through the validatingResolvers and calls onRevoke on each,
    ///     if all validatingResolvers return true, it then (and only then)
    ///     loops through the executingResolvers and calls onRevoke on each
    /// @param attestation The attestation to revoke
    /// @param value The value of the attestation
    function onRevoke(
        Attestation calldata attestation,
        uint256 value
    ) internal override returns (bool) {
        // make sure the attestation is coming from the the intended schema (make sure someone didn't put this resolver contract on an unintended schema)
        if (attestation.schema != INTENDED_SCHEMA_UID) {
            revert RefUIDPluginResolver__InvalidSchema(
                attestation.schema,
                INTENDED_SCHEMA_UID
            );
        }
        // use the refUID to find the pluginResolver
        PluginResolver pluginResolver = refUIDToPluginResolver[
            attestation.refUID
        ];
        // if the pluginResolver is not set, just return true to let the revoke go through
        if (address(pluginResolver) == address(0)) {
            return true;
        }
        // iterate over validatingResolvers and call onRevoke on each. If any fail, return false
        uint256 validatingResolversLength = pluginResolver
            .getValidatingResolversLength();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (
                !pluginResolver.getValidatingResolverAt(i).onRevoke(
                    attestation,
                    value
                )
            ) {
                return false;
            }
        }
        // iterate over executingResolvers and call onRevoke on each
        // if the catchExecutingResolverErrors flag is set, catch the errors and return true
        bool catchExecutingResolverErrors = pluginResolver
            .getCatchExecutingResolverErrors();
        uint256 executingResolversLength = pluginResolver
            .getExecutingResolversLength();
        for (uint256 i = 0; i < executingResolversLength; i++) {
            if (catchExecutingResolverErrors) {
                try
                    pluginResolver.getExecutingResolverAt(i).onRevoke(
                        attestation,
                        value
                    )
                {
                    // Execution successful, continue to the next resolver
                } catch {
                    // Emit event with the address of the failed executing resolver
                    emit ExecutingResolverFailed(
                        pluginResolver.getExecutingResolverAt(i),
                        false
                    );
                }
            } else {
                pluginResolver.getExecutingResolverAt(i).onRevoke(
                    attestation,
                    value
                );
            }
        }
        return true;
    }
}
