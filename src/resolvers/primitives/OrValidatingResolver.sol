// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Attestation} from "eas-contracts/IEAS.sol";

import {EnumerableValidatingResolverSet} from "../../utils/EnumerableValidatingResolverSet.sol";
import {IValidatingResolver} from "../../interfaces/IValidatingResolver.sol";
import {IOrValidatingResolver} from "../interfaces/IOrValidatingResolver.sol";

contract OrValidatingResolver is Ownable2Step, IValidatingResolver, IOrValidatingResolver {
    using EnumerableValidatingResolverSet for EnumerableValidatingResolverSet.Set;

    ////////////////////////////// State //////////////////////////////

    EnumerableValidatingResolverSet.Set private s_validatingResolvers;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(address _owner) Ownable(_owner) {}

    ////////////////////////////// External Functions //////////////////////////////

    function addValidatingResolver(
        IValidatingResolver _resolver
    ) external onlyOwner {
        if (address(_resolver) == address(0)) {
            revert OrValidatingResolver__InvalidResolver(address(_resolver));
        }
        if (!s_validatingResolvers.add(_resolver)) {
            revert OrValidatingResolver__DuplicateResolver(address(_resolver));
        }
        emit ValidatingResolverAdded(_resolver);
    }

    function removeValidatingResolver(
        IValidatingResolver _resolver
    ) external onlyOwner {
        if (!s_validatingResolvers.remove(_resolver)) {
            revert OrValidatingResolver__InvalidResolver(address(_resolver));
        }
        emit ValidatingResolverRemoved(_resolver);
    }

    function onAttest(
        Attestation calldata attestation,
        uint256 value
    ) external returns (bool) {
        // iterate over validatingResolvers and call onAttest on each, if any passes, return true
        uint256 validatingResolversLength = s_validatingResolvers.length();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (s_validatingResolvers.at(i).onAttest(attestation, value)) {
                return true;
            }
        }
        return false;
    }

    function onRevoke(
        Attestation calldata attestation,
        uint256 value
    ) external returns (bool) {
        // iterate over validatingResolvers and call onRevoke on each, if any passes, return true
        uint256 validatingResolversLength = s_validatingResolvers.length();
        for (uint256 i = 0; i < validatingResolversLength; i++) {
            if (s_validatingResolvers.at(i).onRevoke(attestation, value)) {
                return true;
            }
        }
        return false;
    }
}
