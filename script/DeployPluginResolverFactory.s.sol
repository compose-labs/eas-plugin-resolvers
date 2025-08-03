// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {PluginResolverFactory} from "../src/factories/PluginResolverFactory.sol";

contract DeployPluginResolverFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        PluginResolverFactory pluginResolverFactory = new PluginResolverFactory();
        vm.stopBroadcast();
        console2.log(
            "PluginResolverFactory address: ",
            address(pluginResolverFactory)
        );
    }
}
