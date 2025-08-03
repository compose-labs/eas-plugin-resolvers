// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Attestation} from "eas-contracts/IEAS.sol";

import {IValidatingResolver} from "../../src/interfaces/IValidatingResolver.sol";

contract MockValidatingResolver is IValidatingResolver {
    bool private shouldValidate;

    constructor(bool _shouldValidate) {
        shouldValidate = _shouldValidate;
    }

    function setShouldValidate(bool _shouldValidate) external {
        shouldValidate = _shouldValidate;
    }

    function onAttest(Attestation calldata, uint256) external view returns (bool) {
        return shouldValidate;
    }

    function onRevoke(Attestation calldata, uint256) external view returns (bool) {
        return shouldValidate;
    }
}
