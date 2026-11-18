// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.17.0/src/Test.sol";
import {Extrospect} from "src/concrete/Extrospect.sol";
import {
    BYTECODE_HASH,
    CREATION_CODE,
    DEPENDENCIES,
    DEPLOYED_ADDRESS,
    RUNTIME_CODE
} from "src/generated/candidate/Extrospect.sol";
import {DeployDependency, LibRainDeploy} from "rain-deploy-0.1.35/src/lib/LibRainDeploy.sol";

/// @dev Deterministic Zoltu address recorded for the current V5 candidate
/// bytecode. The V4 deployment remains live at
/// 0xC471E8D1A964aac348d36a4B607B605C2F44C8Ea, recorded in
/// `src/generated/0_1_4/`. The generated candidate MUST derive this address
/// for as long as the source compiles to the V5 bytecode — a drift here is a
/// new deployment, not a constant to update.
address constant EXTROSPECT_ZOLTU_ADDRESS_V5 = address(0xaF322b466D76c7260E99F9288a3aBD5e14C3f718);

/// @dev The runtime codehash of the V5 candidate bytecode.
bytes32 constant EXTROSPECT_RUNTIME_CODEHASH_V5 = 0x7df6ad923663b28c60c84d9f9cbfbaecafb55dd63b622d8b70c400b173ad886f;

/// @dev `keccak256` of the V5 creation bytecode. Pinned as a hash because the
/// bytes themselves live in the generated snapshot, and a second copy here
/// would be a second source of truth.
bytes32 constant EXTROSPECT_CREATION_KECCAK_V5 = 0xca495e28c246b5337bc41ad83135aeeb30f407ba57b49a95d97dfd3fb105d916;

/// @title ExtrospectConstantsTest
/// @notice Ties the generated candidate snapshot to the pinned V5 deployment
/// and to the compiler's current output, so the snapshot cannot drift from
/// either without failing loud.
/// @dev These pin compiler output, not behaviour: they fail for any edit to
/// any source file reachable from `Extrospect`. The `mutation` foundry
/// profile excludes this contract by name.
contract ExtrospectConstantsTest is Test {
    /// The generated candidate IS the V5 deployment, byte for byte: the
    /// recorded creation code hashes to the V5 creation bytecode's hash, the
    /// recorded address is the V5 address and the recorded codehash is the V5
    /// runtime codehash.
    function testGeneratedCandidateIsTheV5Deployment() external pure {
        assertEq(
            keccak256(CREATION_CODE),
            EXTROSPECT_CREATION_KECCAK_V5,
            "generated creation code is not the V5 creation bytecode"
        );
        assertEq(DEPLOYED_ADDRESS, EXTROSPECT_ZOLTU_ADDRESS_V5, "generated address is not the V5 Zoltu address");
        assertEq(BYTECODE_HASH, EXTROSPECT_RUNTIME_CODEHASH_V5, "generated codehash is not the V5 runtime codehash");
    }

    /// The recorded creation code matches the current compiler output, so the
    /// V5 tie above is a statement about the contract this repo compiles and
    /// not about a stale snapshot.
    function testExtrospectCreationBytecode() external pure {
        assertEq(
            keccak256(CREATION_CODE),
            keccak256(type(Extrospect).creationCode),
            "generated creation code drifted from compiler output"
        );
    }

    /// The recorded runtime code matches the current compiler output and
    /// hashes to the recorded codehash.
    function testExtrospectRuntimeCodehash() external pure {
        assertEq(
            keccak256(RUNTIME_CODE),
            keccak256(type(Extrospect).runtimeCode),
            "generated runtime code drifted from compiler output"
        );
        assertEq(keccak256(RUNTIME_CODE), BYTECODE_HASH, "generated codehash drifted from generated runtime code");
    }

    /// Deterministic CREATE2 address derived from the recorded creation
    /// bytecode plus Zoltu factory + salt(0) equals the recorded address.
    function testExtrospectZoltuAddress() external pure {
        assertEq(
            LibRainDeploy.zoltuAddress(CREATION_CODE),
            DEPLOYED_ADDRESS,
            "generated address drifted from generated creation bytecode"
        );
    }

    /// `Extrospect` reads nothing and calls nothing at construction, so the
    /// snapshot records no dependency that must already be on chain.
    function testExtrospectDependenciesEmpty() external pure {
        assertEq(abi.decode(DEPENDENCIES, (DeployDependency[])).length, 0, "generated snapshot records a dependency");
    }

    /// The recorded constants describe one deployment, so they must agree
    /// with each other when the recorded creation bytecode is actually
    /// executed. Running it through the real Zoltu factory bytecode lands at
    /// the V5 address and leaves code hashing to the V5 codehash, and that
    /// runtime code is byte for byte both `RUNTIME_CODE` and
    /// `type(Extrospect).runtimeCode`. Deterministic and offline: the factory
    /// is etched from its own pinned bytecode, so no network is involved.
    function testExtrospectDeployRecordReproduces() external {
        LibRainDeploy.etchZoltuFactory(vm);

        address deployed = LibRainDeploy.deployZoltu(CREATION_CODE);

        assertEq(deployed, EXTROSPECT_ZOLTU_ADDRESS_V5, "recorded creation bytecode does not deploy to the V5 address");
        assertEq(
            deployed.codehash, EXTROSPECT_RUNTIME_CODEHASH_V5, "deployed runtime code does not hash to the V5 codehash"
        );
        assertEq(deployed.code, RUNTIME_CODE, "deployed runtime code differs from the recorded runtime code");
        assertEq(deployed.code, type(Extrospect).runtimeCode, "deployed runtime code differs from compiler output");
    }
}
