#!/usr/bin/make
include .env

# Default values for variables
RPC_URL ?= anvil
CHAIN_ID ?= 31337

local-node:
	anvil --chain-id 84532

.PHONY: local-node

deployPluginResolverFactory:
	forge script script/DeployPluginResolverFactory.s.sol:DeployPluginResolverFactory --broadcast --rpc-url $(RPC_URL) --sender $(MSG_SENDER) --keystore ~/.foundry/keystores/my_key

deployRefUidPluginResolverFactory:
	forge script script/DeployRefUidPluginResolverFactory.s.sol:DeployRefUidPluginResolverFactory --broadcast --rpc-url $(RPC_URL) --sender $(MSG_SENDER) --keystore ~/.foundry/keystores/my_key

verifyPluginResolverFactory:
	forge verify-contract $(CONTRACT) PluginResolverFactory --chain-id $(CHAIN_ID) --watch

verifyRefUidPluginResolverFactory:
	forge verify-contract $(CONTRACT) RefUidPluginResolverFactory --chain-id $(CHAIN_ID) --watch

verifyPluginResolver:
	forge verify-contract $(CONTRACT) PluginResolver --chain-id $(CHAIN_ID) --watch --constructor-args $(CONSTRUCTOR_ARGS)

verifyRefUidPluginResolver:
	forge verify-contract $(CONTRACT) RefUidPluginResolver --chain-id $(CHAIN_ID) --watch --constructor-args $(CONSTRUCTOR_ARGS)
