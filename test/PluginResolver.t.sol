// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {EAS, Attestation} from "eas-contracts/EAS.sol";
import {AttestationRequest, RevocationRequest, AttestationRequestData, RevocationRequestData} from "eas-contracts/IEAS.sol";

import {PluginResolver} from "../src/PluginResolver.sol";
import {IValidatingResolver} from "../src/interfaces/IValidatingResolver.sol";
import {IExecutingResolver} from "../src/interfaces/IExecutingResolver.sol";
import {MockValidatingResolver} from "./mocks/MockValidatingResolver.sol";
import {MockExecutingResolver} from "./mocks/MockExecutingResolver.sol";
import {DeployPluginResolver} from "../script/DeployPluginResolver.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract PluginResolverTest is Test {
    PluginResolver public pluginResolver;
    MockValidatingResolver public validatingResolver1;
    MockValidatingResolver public validatingResolver2;
    MockExecutingResolver public executingResolver1;
    MockExecutingResolver public executingResolver2;
    EAS public eas;
    HelperConfig public helperConfig;
    address public owner;
    address public user;
    bytes32 public schemaUid;

    event ValidatingResolverAdded(address indexed resolver);
    event ValidatingResolverRemoved(address indexed resolver);
    event ExecutingResolverAdded(address indexed resolver);
    event ExecutingResolverRemoved(address indexed resolver);
    event ExecutingResolverFailed(
        IExecutingResolver indexed resolver,
        bool indexed isAttestation
    );
    event Attested(
        address indexed recipient,
        address indexed attester,
        bytes32 uid,
        bytes32 indexed schemaUid
    );
    event Revoked(
        address indexed recipient,
        address indexed attester,
        bytes32 uid,
        bytes32 indexed schemaUid
    );

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");

        // Deploy the main contract using the deployer
        DeployPluginResolver deployer = new DeployPluginResolver();
        (pluginResolver, helperConfig) = deployer.run();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        eas = EAS(config.eas);
        schemaUid = config.schemaUid;
        owner = config.account; // Update owner to be the account from config

        // Deploy mock resolvers
        validatingResolver1 = new MockValidatingResolver(true);
        validatingResolver2 = new MockValidatingResolver(true);
        executingResolver1 = new MockExecutingResolver(false);
        executingResolver2 = new MockExecutingResolver(false);
    }

    function test_Constructor() public view {
        assertEq(pluginResolver.owner(), owner);
    }

    function test_AddValidatingResolver() public {
        vm.startPrank(owner);

        vm.expectEmit(true, false, false, false);
        emit ValidatingResolverAdded(address(validatingResolver1));
        pluginResolver.addValidatingResolver(validatingResolver1);

        assertEq(pluginResolver.getValidatingResolversLength(), 1);
        assertEq(
            address(pluginResolver.getValidatingResolverAt(0)),
            address(validatingResolver1)
        );

        vm.stopPrank();
    }

    function test_RevertWhen_AddingDuplicateValidatingResolver() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__DuplicateResolver(address)",
                address(validatingResolver1)
            )
        );
        pluginResolver.addValidatingResolver(validatingResolver1);

        vm.stopPrank();
    }

    function test_RemoveValidatingResolver() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);

        vm.expectEmit(true, false, false, false);
        emit ValidatingResolverRemoved(address(validatingResolver1));
        pluginResolver.removeValidatingResolver(validatingResolver1);

        assertEq(pluginResolver.getValidatingResolversLength(), 0);

        vm.stopPrank();
    }

    function test_AddExecutingResolver() public {
        vm.startPrank(owner);

        vm.expectEmit(true, false, false, false);
        emit ExecutingResolverAdded(address(executingResolver1));
        pluginResolver.addExecutingResolver(executingResolver1);

        assertEq(pluginResolver.getExecutingResolversLength(), 1);
        assertEq(
            address(pluginResolver.getExecutingResolverAt(0)),
            address(executingResolver1)
        );

        vm.stopPrank();
    }

    function test_RevertWhen_AddingDuplicateExecutingResolver() public {
        vm.startPrank(owner);
        pluginResolver.addExecutingResolver(executingResolver1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__DuplicateResolver(address)",
                address(executingResolver1)
            )
        );
        pluginResolver.addExecutingResolver(executingResolver1);

        vm.stopPrank();
    }

    function test_RemoveExecutingResolver() public {
        vm.startPrank(owner);
        pluginResolver.addExecutingResolver(executingResolver1);

        vm.expectEmit(true, false, false, false);
        emit ExecutingResolverRemoved(address(executingResolver1));
        pluginResolver.removeExecutingResolver(executingResolver1);

        assertEq(pluginResolver.getExecutingResolversLength(), 0);

        vm.stopPrank();
    }

    function test_GetValidatingResolvers() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addValidatingResolver(validatingResolver2);

        IValidatingResolver[] memory resolvers = pluginResolver
            .getValidatingResolvers();
        assertEq(resolvers.length, 2);
        assertEq(address(resolvers[0]), address(validatingResolver1));
        assertEq(address(resolvers[1]), address(validatingResolver2));

        vm.stopPrank();
    }

    function test_GetExecutingResolvers() public {
        vm.startPrank(owner);
        pluginResolver.addExecutingResolver(executingResolver1);
        pluginResolver.addExecutingResolver(executingResolver2);

        IExecutingResolver[] memory resolvers = pluginResolver
            .getExecutingResolvers();
        assertEq(resolvers.length, 2);
        assertEq(address(resolvers[0]), address(executingResolver1));
        assertEq(address(resolvers[1]), address(executingResolver2));

        vm.stopPrank();
    }

    function test_RevertWhen_NonOwnerAddsValidatingResolver() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        pluginResolver.addValidatingResolver(validatingResolver1);
    }

    function test_RevertWhen_NonOwnerAddsExecutingResolver() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        pluginResolver.addExecutingResolver(executingResolver1);
    }

    function test_RevertWhen_NonOwnerRemovesExecutingResolver() public {
        vm.prank(owner);
        pluginResolver.addExecutingResolver(executingResolver1);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        pluginResolver.removeExecutingResolver(executingResolver1);
    }

    function test_RevertWhen_NonOwnerRemovesValidatingResolver() public {
        vm.prank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        pluginResolver.removeValidatingResolver(validatingResolver1);
    }

    function test_RevertWhen_AddingZeroAddressValidatingResolver() public {
        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__InvalidResolver(address)",
                address(0)
            )
        );
        pluginResolver.addValidatingResolver(
            MockValidatingResolver(address(0))
        );
    }

    function test_RevertWhen_AddingZeroAddressExecutingResolver() public {
        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__InvalidResolver(address)",
                address(0)
            )
        );
        pluginResolver.addExecutingResolver(MockExecutingResolver(address(0)));
    }

    function test_RevertWhen_IndexOutOfBoundsValidatingResolver() public {
        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__IndexOutOfBounds(uint256,uint256)",
                0,
                0
            )
        );
        pluginResolver.getValidatingResolverAt(0);
    }

    function test_RevertWhen_IndexOutOfBoundsExecutingResolver() public {
        vm.expectRevert(
            abi.encodeWithSignature(
                "PluginResolver__IndexOutOfBounds(uint256,uint256)",
                0,
                0
            )
        );
        pluginResolver.getExecutingResolverAt(0);
    }

    function test_OnAttest_Success() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addValidatingResolver(validatingResolver2);
        pluginResolver.addExecutingResolver(executingResolver1);
        pluginResolver.addExecutingResolver(executingResolver2);
        vm.stopPrank();

        AttestationRequest memory request = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true), // Using true as per the schema "bool approve"
                value: 0
            })
        });

        vm.prank(owner);
        bytes32 uid = eas.attest(request);
        assertEq(executingResolver1.attestCallCount(), 1);
        assertEq(executingResolver2.attestCallCount(), 1);
        assertNotEq(uid, bytes32(0));
    }

    function test_OnAttest_ValidatorReturnsFalse() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addExecutingResolver(executingResolver1);
        vm.stopPrank();

        validatingResolver1.setShouldValidate(false);

        AttestationRequest memory request = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true),
                value: 0
            })
        });

        vm.expectRevert(EAS.InvalidAttestation.selector);
        vm.prank(owner);
        eas.attest(request);
        assertEq(executingResolver1.attestCallCount(), 0);
    }

    function test_OnAttest_ExecutorReverts() public {
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addExecutingResolver(executingResolver1);
        vm.stopPrank();

        // Set the executing resolver to revert
        executingResolver1.setShouldRevert(true);

        // Prepare the attestation request
        AttestationRequest memory request = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true),
                value: 0
            })
        });

        // Call the attest function, which should trigger the revert
        vm.prank(owner);
        // Expect the Attested event to be emitted
        vm.expectEmit(true, true, true, false);
        emit Attested(address(0), owner, 0x0, schemaUid);
        // Expect the ExecutingResolverFailed event to be emitted
        vm.expectEmit(true, true, false, true);
        emit ExecutingResolverFailed(
            IExecutingResolver(executingResolver1),
            true
        );
        bytes32 uid = eas.attest(request); // This should trigger the Attested event

        // Assert that the executing resolver's attest call count is still 0
        assertEq(executingResolver1.attestCallCount(), 0);
        // uid should be set, even if an executing resolver fails (executing resolver reverts are caught and not propagated)
        assertNotEq(uid, bytes32(0));
    }

    function test_OnRevoke_Success() public {
        // First create an attestation that we can revoke
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addValidatingResolver(validatingResolver2);
        pluginResolver.addExecutingResolver(executingResolver1);
        pluginResolver.addExecutingResolver(executingResolver2);

        AttestationRequest memory attestRequest = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true),
                value: 0
            })
        });

        bytes32 uid = eas.attest(attestRequest);

        RevocationRequest memory request = RevocationRequest({
            schema: schemaUid,
            data: RevocationRequestData({uid: uid, value: 0})
        });

        eas.revoke(request);
        assertEq(executingResolver1.revokeCallCount(), 1);
        assertEq(executingResolver2.revokeCallCount(), 1);
        // fetch the attestation to check that it has been revoked
        Attestation memory attestation = eas.getAttestation(uid);
        assertTrue(attestation.revocationTime > 0);

        vm.stopPrank();
    }

    function test_OnRevoke_ValidatorReturnsFalse() public {
        // First create an attestation that we can revoke
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addExecutingResolver(executingResolver1);

        AttestationRequest memory attestRequest = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true),
                value: 0
            })
        });

        bytes32 uid = eas.attest(attestRequest);

        validatingResolver1.setShouldValidate(false);

        RevocationRequest memory request = RevocationRequest({
            schema: schemaUid,
            data: RevocationRequestData({uid: uid, value: 0})
        });

        vm.expectRevert(EAS.InvalidRevocation.selector);
        eas.revoke(request);
        assertEq(executingResolver1.revokeCallCount(), 0);
        // attestation should not be revoked
        Attestation memory attestation = eas.getAttestation(uid);
        assertEq(attestation.revocationTime, 0);

        vm.stopPrank();
    }

    function test_OnRevoke_ExecutorReverts() public {
        // First create an attestation that we can revoke
        vm.startPrank(owner);
        pluginResolver.addValidatingResolver(validatingResolver1);
        pluginResolver.addExecutingResolver(executingResolver1);

        AttestationRequest memory attestRequest = AttestationRequest({
            schema: schemaUid,
            data: AttestationRequestData({
                recipient: address(0),
                expirationTime: 0,
                revocable: true,
                refUID: bytes32(0),
                data: abi.encode(true),
                value: 0
            })
        });

        bytes32 uid = eas.attest(attestRequest);

        executingResolver1.setShouldRevert(true);

        RevocationRequest memory request = RevocationRequest({
            schema: schemaUid,
            data: RevocationRequestData({uid: uid, value: 0})
        });

        // Expect the Attested event to be emitted
        vm.expectEmit(true, true, true, false);
        emit Revoked(address(0), owner, uid, schemaUid);
        // Expect the ExecutingResolverFailed event to be emitted
        vm.expectEmit(true, true, false, true);
        emit ExecutingResolverFailed(
            IExecutingResolver(executingResolver1),
            false
        );

        eas.revoke(request);
        assertEq(executingResolver1.revokeCallCount(), 0);
        // attestation should be revoked, even if an executing resolver fails (executing resolver reverts are caught and not propagated)
        Attestation memory attestation = eas.getAttestation(uid);
        assertTrue(attestation.revocationTime > 0);

        vm.stopPrank();
    }
}
