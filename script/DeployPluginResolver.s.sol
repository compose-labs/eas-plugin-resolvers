// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";

import {PluginResolver} from "../src/PluginResolver.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployPluginResolver is Script {
    function run() external returns (PluginResolver, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        return (config.pluginResolver, helperConfig);
    }
}
