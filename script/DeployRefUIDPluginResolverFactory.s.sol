// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {RefUidPluginResolverFactory} from "../src/managers/RefUidPluginResolverFactory.sol";

contract DeployRefUidPluginResolverFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        RefUidPluginResolverFactory refUidPluginResolverFactory = new RefUidPluginResolverFactory();
        vm.stopBroadcast();
        console2.log("RefUidPluginResolverFactory address: ", address(refUidPluginResolverFactory));
    }
}
