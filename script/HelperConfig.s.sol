// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {SchemaRegistry} from "eas-contracts/SchemaRegistry.sol";
import {IEAS, EAS} from "eas-contracts/EAS.sol";

import {PluginResolver} from "../src/PluginResolver.sol";

abstract contract CodeConstants {
    address public FOUNDRY_DEFAULT_SENDER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    ////////////////////////////// Errors //////////////////////////////
    error HelperConfig__InvalidChainId();

    ////////////////////////////// Types //////////////////////////////
    struct NetworkConfig {
        address eas;
        bytes32 schemaUid;
        PluginResolver pluginResolver;
        address account;
    }

    ////////////////////////////// State //////////////////////////////
    // Local network state variables
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    ////////////////////////////// Constructor //////////////////////////////
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        // Note: We skip doing the local config
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function setConfig(
        uint256 chainId,
        NetworkConfig memory networkConfig
    ) public {
        networkConfigs[chainId] = networkConfig;
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].eas != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            eas: 0xC2679fBD37d54388Ce493F1DB75320D236e1815e,
            schemaUid: bytes32(0), // todo
            pluginResolver: PluginResolver(payable(address(0))), // todo
            account: address(0) // todo
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check if we already have a local network configuration
        if (localNetworkConfig.eas != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        // Deploy the core contracts needed for the EAS system
        SchemaRegistry registry = new SchemaRegistry();
        IEAS _eas = new EAS(registry);

        // Define a test schema
        string memory schema = "bool approve";
        bool revocable = true;
        // Create the plugin resolver
        PluginResolver resolver = new PluginResolver(
            FOUNDRY_DEFAULT_SENDER, // Owner of the resolver
            address(_eas), // Address of the EAS contract
            true // Catch executing resolver errors
        );

        // Register the schema with the registry and get its UID
        bytes32 _schemaUid = registry.register(schema, resolver, revocable);
        vm.stopBroadcast();

        // Create and store the local network configuration
        localNetworkConfig = NetworkConfig({
            schemaUid: _schemaUid,
            eas: address(_eas),
            pluginResolver: resolver,
            account: FOUNDRY_DEFAULT_SENDER
        });

        // Give the default account some test ETH
        vm.deal(localNetworkConfig.account, 100 ether);

        return localNetworkConfig;
    }
}
