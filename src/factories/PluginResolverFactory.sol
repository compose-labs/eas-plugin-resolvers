// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {PluginResolver} from "../PluginResolver.sol";

/**
 * @title PluginResolverFactory
 * @dev PluginResolverFactory contract to deploy PluginResolver using CREATE2
 */
contract PluginResolverFactory {
    /// @notice Array of deployed PluginResolver contracts
    PluginResolver[] public contracts;

    /// @notice Emitted when a new PluginResolver is deployed
    event ResolverDeployed(
        address indexed deployer,
        address indexed initOwner,
        PluginResolver indexed deployedContract
    );

    /// @notice Deploys a new PluginResolver contract
    /// @param _owner The owner of the new resolver. If address(0), msg.sender is used
    /// @param _salt The salt for CREATE2 deployment
    /// @return The newly deployed PluginResolver contract
    function deploy(
        address _owner,
        bytes32 _salt,
        address _eas
    ) external returns (PluginResolver) {
        if (_owner == address(0)) {
            _owner = msg.sender;
        }
        PluginResolver resolver = new PluginResolver{salt: _salt}(_owner, _eas);
        contracts.push(resolver);
        emit ResolverDeployed(msg.sender, _owner, resolver);
        return resolver;
    }

    /// @notice Computes the deterministic address for a PluginResolver deployment
    /// @param _salt The salt for CREATE2 deployment
    /// @param _bytecode The contract bytecode
    /// @return The computed address
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

    /// @notice Gets the initialization bytecode for a PluginResolver
    /// @param _owner The owner address to initialize with
    /// @return The contract bytecode with constructor arguments
    function getBytecode(address _owner) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                type(PluginResolver).creationCode,
                abi.encode(_owner)
            );
    }
}
