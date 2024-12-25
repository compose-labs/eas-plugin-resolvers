// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import "../src/factories/PluginResolverFactory.sol";

contract DeployPluginResolverFactory is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        PluginResolverFactory pluginResolverFactory = new PluginResolverFactory();
        vm.stopBroadcast();
        console2.log(
            "PluginResolverFactory address: ",
            address(pluginResolverFactory)
        );
    }
}
