// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Attestation} from "eas-contracts/IEAS.sol";

import {IValidatingResolver} from "../../../interfaces/IValidatingResolver.sol";

/// @title OwnableAllowlistResolver
/// @notice A sample validating resolver that checks whether the attester is in the allowlist. The can be updated by the owner.
contract OwnableAllowlistResolver is Ownable2Step, IValidatingResolver {
    using EnumerableSet for EnumerableSet.AddressSet;

    ////////////////////////////// State //////////////////////////////

    EnumerableSet.AddressSet private s_allowedAddresses;

    ////////////////////////////// Constructor //////////////////////////////

    constructor(
        address _owner,
        address[] memory _allowedAddresses
    ) Ownable(_owner) {
        for (uint256 i = 0; i < _allowedAddresses.length; i++) {
            s_allowedAddresses.add(_allowedAddresses[i]);
        }
    }

    //////////////////////////////// External Functions //////////////////////////////

    function addAllowedAddress(address _address) external onlyOwner {
        s_allowedAddresses.add(_address);
    }

    function removeAllowedAddress(address _address) external onlyOwner {
        s_allowedAddresses.remove(_address);
    }

    //////////////////////////////// Validating Resolver //////////////////////////////

    function onAttest(
        Attestation calldata attestation,
        uint256 /* value */
    ) external view returns (bool) {
        return isAllowed(attestation.attester);
    }

    function onRevoke(
        Attestation calldata /* attestation */,
        uint256 /* value */
    ) external pure returns (bool) {
        return true;
    }

    //////////////////////////////// Getters //////////////////////////////

    function isAllowed(address _address) public view returns (bool) {
        return s_allowedAddresses.contains(_address);
    }

    function getAllowedAddresses() external view returns (address[] memory) {
        return s_allowedAddresses.values();
    }

    function getAllowedAddressesLength() external view returns (uint256) {
        return s_allowedAddresses.length();
    }

    function getAllowedAddress(uint256 _index) external view returns (address) {
        return s_allowedAddresses.at(_index);
    }
}
