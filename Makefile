#!/usr/bin/make
include .env

# Default values for variables
RPC_URL ?= base_sepolia
CHAIN_ID ?= 84532

local-node:
	anvil --chain-id 84532

.PHONY: local-node

deployRefUIDPluginResolverFactory:
	forge script script/DeployRefUIDPluginResolverFactory.s.sol:DeployRefUIDPluginResolverFactory --broadcast --rpc-url $(RPC_URL) --sender $(MSG_SENDER) --keystore ~/.foundry/keystores/my_key

deployPluginResolverFactory:
	forge script script/DeployPluginResolverFactory.s.sol:DeployPluginResolverFactory --broadcast --rpc-url $(RPC_URL) --sender $(MSG_SENDER) --keystore ~/.foundry/keystores/my_key

verifyRefUIDPluginResolver:
	forge verify-contract $(CONTRACT) RefUIDPluginResolver --chain-id $(CHAIN_ID) --watch --constructor-args $(CONSTRUCTOR_ARGS)

verifyRefUIDPluginResolverFactory:
	forge verify-contract $(CONTRACT) RefUIDPluginResolverFactory --chain-id $(CHAIN_ID) --watch

verifyPluginResolverFactory:
	forge verify-contract $(CONTRACT) PluginResolverFactory --chain-id $(CHAIN_ID) --watch