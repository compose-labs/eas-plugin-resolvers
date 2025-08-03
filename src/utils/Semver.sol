// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {ISemver} from "./interfaces/ISemver.sol";

/// @title Semver
/// @notice A simple contract for managing contract versions.
contract Semver is ISemver {
    // Contract's major version number.
    uint256 private immutable I_MAJOR;

    // Contract's minor version number.
    uint256 private immutable I_MINOR;

    // Contract's patch version number.
    uint256 private immutable I_PATCH;

    /// @dev Create a new Semver instance.
    /// @param major Major version number.
    /// @param minor Minor version number.
    /// @param patch Patch version number.
    constructor(uint256 major, uint256 minor, uint256 patch) {
        I_MAJOR = major;
        I_MINOR = minor;
        I_PATCH = patch;
    }

    /// @notice Returns the full semver contract version.
    /// @return Semver contract version as a string.
    function getVersion() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    Strings.toString(I_MAJOR),
                    ".",
                    Strings.toString(I_MINOR),
                    ".",
                    Strings.toString(I_PATCH)
                )
            );
    }
}
