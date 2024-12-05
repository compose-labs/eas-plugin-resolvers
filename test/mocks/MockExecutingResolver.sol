// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Attestation} from "eas-contracts/IEAS.sol";

import {IExecutingResolver} from "../../src/interfaces/IExecutingResolver.sol";

contract MockExecutingResolver is IExecutingResolver {
    bool private shouldRevert;
    bool public lastAttestValue;
    bool public lastRevokeValue;
    uint256 public attestCallCount;
    uint256 public revokeCallCount;

    constructor(bool _shouldRevert) {
        shouldRevert = _shouldRevert;
    }

    function setShouldRevert(bool _shouldRevert) external {
        shouldRevert = _shouldRevert;
    }

    function onAttest(Attestation calldata, uint256) external {
        if (shouldRevert) {
            revert("MockExecutingResolver: forced revert");
        }
        attestCallCount++;
        lastAttestValue = true;
    }

    function onRevoke(Attestation calldata, uint256) external {
        if (shouldRevert) {
            revert("MockExecutingResolver: forced revert");
        }
        revokeCallCount++;
        lastRevokeValue = true;
    }

    function reset() external {
        attestCallCount = 0;
        revokeCallCount = 0;
        lastAttestValue = false;
        lastRevokeValue = false;
    }
} 