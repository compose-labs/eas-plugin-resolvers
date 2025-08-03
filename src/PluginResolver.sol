// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SchemaResolver} from "eas-contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/IEAS.sol";

import {Semver} from "./utils/Semver.sol";
import {EnumerableValidatingResolverSet} from "./utils/EnumerableValidatingResolverSet.sol";
import {EnumerableExecutingResolverSet} from "./utils/EnumerableExecutingResolverSet.sol";
import {IValidatingResolver} from "./interfaces/IValidatingResolver.sol";
import {IExecutingResolver} from "./interfaces/IExecutingResolver.sol";
import {IPluginResolver} from "./interfaces/IPluginResolver.sol";

/**
 * @title PluginResolver
 * @author Kyle Kaplan
 * @dev PluginResolver to add an array of validating and executing resolver contracts onAttest and onRevoke
 */
contract PluginResolver is
    Semver,
    Ownable2Step,
    SchemaResolver,
    IPluginResolver
{
    using EnumerableValidatingResolverSet for EnumerableValidatingResolverSet.Set;
    using EnumerableExecutingResolverSet for EnumerableExecutingResolverSet.Set;

    ////////////////////////////// State //////////////////////////////

    // array of validating resolvers
    EnumerableValidatingResolverSet.Set private s_validatingResolvers;
    // array of executing resolvers
    EnumerableExecutingResolverSet.Set private s_executingResolvers;
    // flag to catch or not catch errors from executing resolvers
    bool private s_catchExecutingResolverErrors;

    ////////////////////////////// Constructor //////////////////////////////

    /**
     * @notice Constructor for PluginResolver
     * @param _owner The address of the owner of the PluginResolver
     * @param _catchExecutingResolverErrors Flag to catch or not catch errors from executing resolvers
     */
    constructor(
        address _owner,
        address _eas,
        bool _catchExecutingResolverErrors
    ) Semver(0, 0, 1) SchemaResolver(IEAS(_eas)) Ownable(_owner) {
        s_catchExecutingResolverErrors = _catchExecutingResolverErrors;
    }

    ////////////////////////////// External Functions //////////////////////////////

    /// @inheritdoc IPluginResolver
    function setCatchExecutingResolverErrors(
        bool catchErrors
    ) external onlyOwner {
        s_catchExecutingResolverErrors = catchErrors;
        emit CatchExecutingResolverErrorsSet(catchErrors);
    }

    /// @inheritdoc IPluginResolver
    function addValidatingResolver(
        IValidatingResolver resolver
    ) external onlyOwner {
        if (address(resolver) == address(0)) {
            revert PluginResolver__InvalidResolver(address(resolver));
        }
        if (!s_validatingResolvers.add(resolver)) {
            revert PluginResolver__DuplicateResolver(address(resolver));
        }
        emit ValidatingResolverAdded(resolver);
    }

    /// @inheritdoc IPluginResolver
    function removeValidatingResolver(
        IValidatingResolver resolver
    ) external onlyOwner {
        if (!s_validatingResolvers.remove(resolver)) {
            revert PluginResolver__InvalidResolver(address(resolver));
        }
        emit ValidatingResolverRemoved(resolver);
    }

    /// @inheritdoc IPluginResolver
    function addExecutingResolver(
        IExecutingResolver resolver
    ) external onlyOwner {
        if (address(resolver) == address(0)) {
            revert PluginResolver__InvalidResolver(address(resolver));
        }
        if (!s_executingResolvers.add(resolver)) {
            revert PluginResolver__DuplicateResolver(address(resolver));
        }
        emit ExecutingResolverAdded(resolver);
    }

    /// @inheritdoc IPluginResolver
    function removeExecutingResolver(
        IExecutingResolver resolver
    ) external onlyOwner {
        if (!s_executingResolvers.remove(resolver)) {
            revert PluginResolver__InvalidResolver(address(resolver));
        }
        emit ExecutingResolverRemoved(resolver);
    }

    /// @inheritdoc IPluginResolver
    function getCatchExecutingResolverErrors() external view returns (bool) {
        return s_catchExecutingResolverErrors;
    }

    /// @inheritdoc IPluginResolver
    function getValidatingResolversLength() external view returns (uint256) {
        return s_validatingResolvers.length();
    }

    /// @inheritdoc IPluginResolver
    function getValidatingResolverAt(
        uint256 index
    ) external view returns (IValidatingResolver) {
        if (index >= s_validatingResolvers.length()) {
            revert PluginResolver__IndexOutOfBounds(
                index,
                s_validatingResolvers.length()
            );
        }
        return s_validatingResolvers.at(index);
    }

    /// @notice Returns all validating resolver addresses for off-chain enumeration
    /// @dev This function is intended for off-chain use as iterating over a dynamic array can be gas intensive
    /// @return Array of all validating resolver addresses
    function getValidatingResolvers()
        external
        view
        returns (IValidatingResolver[] memory)
    {
        return s_validatingResolvers.values();
    }

    /// @inheritdoc IPluginResolver
    function getExecutingResolversLength() external view returns (uint256) {
        return s_executingResolvers.length();
    }

    /// @inheritdoc IPluginResolver
    function getExecutingResolverAt(
        uint256 index
    ) external view returns (IExecutingResolver) {
        if (index >= s_executingResolvers.length()) {
            revert PluginResolver__IndexOutOfBounds(
                index,
                s_executingResolvers.length()
            );
        }
        return s_executingResolvers.at(index);
    }

    /// @notice Returns all executing resolver addresses for off-chain enumeration
    /// @dev This function is intended for off-chain use as iterating over a dynamic array can be gas intensive
    /// @return Array of all executing resolver addresses
    function getExecutingResolvers()
        external
        view
        returns (IExecutingResolver[] memory)
    {
        return s_executingResolvers.values();
    }

    ////////////////////////////// Internal Functions //////////////////////////////

    /// @notice First loops through the validatingResolvers and calls onAttest on each,
    ///         if all validatingResolvers return true, it then (and only then)
    ///         loops through the executingResolvers and calls onAttest on each
    /// @dev This function is called by the EAS contract when an attestation is made and protected by the onlyEAS modifier
    /// @param attestation The attestation to validate
    /// @param value The value of the attestation
    function onAttest(
        Attestation calldata attestation,
        uint256 value
    ) internal override returns (bool) {
        // iterate over validatingResolvers and call onAttest on each
        uint256 validatingResolversLength = s_validatingResolvers.length();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (!s_validatingResolvers.at(i).onAttest(attestation, value)) {
                return false;
            }
        }
        // iterate over executingResolvers and call onAttest on each
        uint256 executingResolversLength = s_executingResolvers.length();
        for (uint256 i = 0; i < executingResolversLength; i++) {
            if (s_catchExecutingResolverErrors) {
                try s_executingResolvers.at(i).onAttest(attestation, value) {
                    // Execution successful, continue to the next resolver
                } catch {
                    // Emit event with the address of the failed executing resolver
                    emit ExecutingResolverFailed(
                        s_executingResolvers.at(i),
                        true
                    );
                }
            } else {
                // Don't catch errors, let them bubble up
                s_executingResolvers.at(i).onAttest(attestation, value);
            }
        }
        return true;
    }

    /// @notice First loops through the validatingResolvers and calls onRevoke on each,
    ///         if all validatingResolvers return true, it then (and only then)
    ///         loops through the executingResolvers and calls onRevoke on each
    /// @dev This function is called by the EAS contract when an attestation is revoked and protected by the onlyEAS modifier
    /// @param attestation The attestation to revoke
    /// @param value The value of the attestation
    function onRevoke(
        Attestation calldata attestation,
        uint256 value
    ) internal override returns (bool) {
        // iterate over validatingResolvers and call onRevoke on each
        uint256 validatingResolversLength = s_validatingResolvers.length();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (!s_validatingResolvers.at(i).onRevoke(attestation, value)) {
                return false;
            }
        }
        // iterate over executingResolvers and call onRevoke on each
        uint256 executingResolversLength = s_executingResolvers.length();
        for (uint256 i = 0; i < executingResolversLength; i++) {
            if (s_catchExecutingResolverErrors) {
                try s_executingResolvers.at(i).onRevoke(attestation, value) {
                    // Execution successful, continue to the next resolver
                } catch {
                    // Emit event with the address of the failed executing resolver
                    emit ExecutingResolverFailed(
                        s_executingResolvers.at(i),
                        false
                    );
                }
            } else {
                // Don't catch errors, let them bubble up
                s_executingResolvers.at(i).onRevoke(attestation, value);
            }
        }
        return true;
    }
}
