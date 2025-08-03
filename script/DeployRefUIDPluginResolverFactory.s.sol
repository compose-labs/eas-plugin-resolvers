// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import "../src/managers/RefUIDPluginResolverFactory.sol";

contract DeployRefUIDPluginResolverFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        RefUIDPluginResolverFactory refUIDPluginResolverFactory = new RefUIDPluginResolverFactory();
        vm.stopBroadcast();
        console2.log(
            "RefUIDPluginResolverFactory address: ",
            address(refUIDPluginResolverFactory)
        );
    }
}
