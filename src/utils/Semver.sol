// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {ISemver} from "./interfaces/ISemver.sol";

/// @title Semver
/// @notice A simple contract for managing contract versions.
contract Semver is ISemver {
    // Contract's major version number.
    uint256 private immutable _major;

    // Contract's minor version number.
    uint256 private immutable _minor;

    // Contract's patch version number.
    uint256 private immutable _patch;

    /// @dev Create a new Semver instance.
    /// @param major Major version number.
    /// @param minor Minor version number.
    /// @param patch Patch version number.
    constructor(uint256 major, uint256 minor, uint256 patch) {
        _major = major;
        _minor = minor;
        _patch = patch;
    }

    /// @notice Returns the full semver contract version.
    /// @return Semver contract version as a string.
    function getVersion() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    Strings.toString(_major),
                    ".",
                    Strings.toString(_minor),
                    ".",
                    Strings.toString(_patch)
                )
            );
    }
}
