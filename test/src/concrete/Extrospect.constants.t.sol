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

/// @dev The address the V1 `Extrospect` deployment is live at. The generated
/// candidate MUST derive this address for as long as the source still
/// compiles to the deployed V1 bytecode — a drift here is a new deployment,
/// not a constant to update.
address constant EXTROSPECT_ZOLTU_ADDRESS_V1 = address(0x1BE878af679C1a0A6AC15108b0F4398de1f94506);

/// @dev The runtime codehash of the V1 deployment.
bytes32 constant EXTROSPECT_RUNTIME_CODEHASH_V1 = 0x6f34c52c30411783d48eb81ac33c9cf7c108e61f86b2c5403ad49c8680cc71cf;

/// @dev `keccak256` of the V1 creation bytecode. Pinned as a hash because the
/// bytes themselves live in the generated snapshot, and a second copy here
/// would be a second source of truth.
bytes32 constant EXTROSPECT_CREATION_KECCAK_V1 = 0x5a56765a85cfcb3d9ca721de9dce9f1eb770ee9c7b873b50bd7727c20a344efd;

/// @title ExtrospectConstantsTest
/// @notice Ties the generated candidate snapshot to the existing V1
/// deployment and to the compiler's current output, so the snapshot cannot
/// drift from either without failing loud.
/// @dev These pin compiler output, not behaviour: they fail for any edit to
/// any source file reachable from `Extrospect`. The `mutation` foundry
/// profile excludes this contract by name.
contract ExtrospectConstantsTest is Test {
    /// The generated candidate IS the V1 deployment, byte for byte: the
    /// recorded creation code hashes to the V1 creation bytecode's hash, the
    /// recorded address is the V1 address and the recorded codehash is the V1
    /// runtime codehash.
    function testGeneratedCandidateIsTheV1Deployment() external pure {
        assertEq(
            keccak256(CREATION_CODE),
            EXTROSPECT_CREATION_KECCAK_V1,
            "generated creation code is not the V1 creation bytecode"
        );
        assertEq(DEPLOYED_ADDRESS, EXTROSPECT_ZOLTU_ADDRESS_V1, "generated address is not the V1 Zoltu address");
        assertEq(BYTECODE_HASH, EXTROSPECT_RUNTIME_CODEHASH_V1, "generated codehash is not the V1 runtime codehash");
    }

    /// The recorded creation code matches the current compiler output, so the
    /// V1 tie above is a statement about the contract this repo compiles and
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
    /// the V1 address and leaves code hashing to the V1 codehash, and that
    /// runtime code is byte for byte both `RUNTIME_CODE` and
    /// `type(Extrospect).runtimeCode`. Deterministic and offline: the factory
    /// is etched from its own pinned bytecode, so no network is involved.
    function testExtrospectDeployRecordReproduces() external {
        LibRainDeploy.etchZoltuFactory(vm);

        address deployed = LibRainDeploy.deployZoltu(CREATION_CODE);

        assertEq(deployed, EXTROSPECT_ZOLTU_ADDRESS_V1, "recorded creation bytecode does not deploy to the V1 address");
        assertEq(
            deployed.codehash, EXTROSPECT_RUNTIME_CODEHASH_V1, "deployed runtime code does not hash to the V1 codehash"
        );
        assertEq(deployed.code, RUNTIME_CODE, "deployed runtime code differs from the recorded runtime code");
        assertEq(deployed.code, type(Extrospect).runtimeCode, "deployed runtime code differs from compiler output");
    }
}
