// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {RefUIDPluginResolver} from "./RefUIDPluginResolver.sol";

/**
 * @title RefUIDPluginResolverFactory
 * @dev RefUIDPluginResolverFactory contract to deploy RefUIDPluginResolvers using CREATE2
 */
contract RefUIDPluginResolverFactory {
    RefUIDPluginResolver[] public contracts;

    event ResolverDeployed(
        address indexed deployer,
        RefUIDPluginResolver indexed deployedContract
    );

    function deploy(
        bytes32 _salt,
        address _eas
    ) external returns (RefUIDPluginResolver) {
        RefUIDPluginResolver resolver = new RefUIDPluginResolver{salt: _salt}(
            _eas
        );
        contracts.push(resolver);
        emit ResolverDeployed(msg.sender, resolver);
        return resolver;
    }

    function computeAddress(
        bytes32 _salt,
        bytes memory _bytecode
    ) public view returns (address) {
        bytes32 bytecodeHash = keccak256(_bytecode);
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                _salt,
                                bytecodeHash
                            )
                        )
                    )
                )
            );
    }

    function getBytecode() public pure returns (bytes memory) {
        return abi.encodePacked(type(RefUIDPluginResolver).creationCode);
    }
}
