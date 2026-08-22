// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.2/src/Test.sol";
import {Extrospect} from "src/concrete/Extrospect.sol";
import {
    BYTECODE_HASH,
    CREATION_CODE,
    DEPENDENCIES,
    DEPLOYED_ADDRESS,
    RUNTIME_CODE
} from "src/generated/candidate/Extrospect.sol";
import {LibRainDeploy} from "rain-deploy-0.1.7/src/lib/LibRainDeploy.sol";

/// @dev The address the V2 `Extrospect` deployment will be live at: the Zoltu
/// address of the current candidate bytecode. Not yet deployed — the next
/// release deploys it. The V1 deployment remains live at
/// 0x1BE878af679C1a0A6AC15108b0F4398de1f94506, recorded in
/// `src/generated/0_1_0/`. The generated candidate MUST derive this address
/// for as long as the source compiles to the V2 bytecode — a drift here is a
/// new deployment, not a constant to update.
address constant EXTROSPECT_ZOLTU_ADDRESS_V2 = address(0x01A8116e07D63348c02818Af858769EaCdaF134A);

/// @dev The runtime codehash of the V2 candidate bytecode.
bytes32 constant EXTROSPECT_RUNTIME_CODEHASH_V2 = 0xd036244004bdb66e7d31e3aa2a7a3306e46fd04ceb85b713bfe8b7547232032d;

/// @dev `keccak256` of the V2 creation bytecode. Pinned as a hash because the
/// bytes themselves live in the generated snapshot, and a second copy here
/// would be a second source of truth.
bytes32 constant EXTROSPECT_CREATION_KECCAK_V2 = 0x24ac88b85bc285f8be255968b680ae632f12f0b78f8d15330e988d0eea498e18;

/// @title ExtrospectConstantsTest
/// @notice Ties the generated candidate snapshot to the pinned V2 deployment
/// and to the compiler's current output, so the snapshot cannot drift from
/// either without failing loud.
/// @dev These pin compiler output, not behaviour: they fail for any edit to
/// any source file reachable from `Extrospect`. The `mutation` foundry
/// profile excludes this contract by name.
contract ExtrospectConstantsTest is Test {
    /// The generated candidate IS the V2 deployment, byte for byte: the
    /// recorded creation code hashes to the V2 creation bytecode's hash, the
    /// recorded address is the V2 address and the recorded codehash is the V2
    /// runtime codehash.
    function testGeneratedCandidateIsTheV2Deployment() external pure {
        assertEq(
            keccak256(CREATION_CODE),
            EXTROSPECT_CREATION_KECCAK_V2,
            "generated creation code is not the V2 creation bytecode"
        );
        assertEq(DEPLOYED_ADDRESS, EXTROSPECT_ZOLTU_ADDRESS_V2, "generated address is not the V2 Zoltu address");
        assertEq(BYTECODE_HASH, EXTROSPECT_RUNTIME_CODEHASH_V2, "generated codehash is not the V2 runtime codehash");
    }

    /// The recorded creation code matches the current compiler output, so the
    /// V2 tie above is a statement about the contract this repo compiles and
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
        assertEq(abi.decode(DEPENDENCIES, (address[])).length, 0, "generated snapshot records a dependency");
    }

    /// The recorded constants describe one deployment, so they must agree
    /// with each other when the recorded creation bytecode is actually
    /// executed. Running it through the real Zoltu factory bytecode lands at
    /// the V2 address and leaves code hashing to the V2 codehash, and that
    /// runtime code is byte for byte both `RUNTIME_CODE` and
    /// `type(Extrospect).runtimeCode`. Deterministic and offline: the factory
    /// is etched from its own pinned bytecode, so no network is involved.
    function testExtrospectDeployRecordReproduces() external {
        LibRainDeploy.etchZoltuFactory(vm);

        address deployed = LibRainDeploy.deployZoltu(CREATION_CODE);

        assertEq(deployed, EXTROSPECT_ZOLTU_ADDRESS_V2, "recorded creation bytecode does not deploy to the V2 address");
        assertEq(
            deployed.codehash, EXTROSPECT_RUNTIME_CODEHASH_V2, "deployed runtime code does not hash to the V2 codehash"
        );
        assertEq(deployed.code, RUNTIME_CODE, "deployed runtime code differs from the recorded runtime code");
        assertEq(deployed.code, type(Extrospect).runtimeCode, "deployed runtime code differs from compiler output");
    }
}
