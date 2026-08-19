// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.2/src/Test.sol";
import {DeployCandidate} from "src/abstract/RainDeploySuitesBase.sol";
import {ExtrospectDeploySuites} from "src/abstract/ExtrospectDeploySuites.sol";

/// @title ExtrospectDeploySuitesTest
/// @notice The three fields of the `extrospect` candidate that the verify
/// groups do not constrain, because they derive everything they check from
/// the candidate's own bytecode: the suite key, the artifact path and the
/// dependency list. Each is pinned here against the thing outside the
/// declaration that gives it meaning.
contract ExtrospectDeploySuitesTest is ExtrospectDeploySuites, Test {
    /// The suite key is the key the `Manual sol artifacts` workflow
    /// dispatches as `DEPLOYMENT_SUITE`. The workflow file is outside the
    /// EVM, so the agreement is pinned by restating the key, not by reading
    /// it.
    function testExtrospectSuiteKeyIsTheDispatchedSuite() external pure {
        DeployCandidate memory candidate = extrospectCandidate();
        assertEq(candidate.snapshot.suite, "extrospect", "suite key is not what the deploy workflow dispatches");
    }

    /// The artifact path names the contract the candidate is a candidate OF:
    /// the artifact it compiles to is byte-for-byte the declaration's
    /// `sourceCreationCode`. A path naming a missing artifact fails to
    /// resolve, and one naming some other contract compiles to other bytes —
    /// so both halves of the path are checked, the file and the name.
    function testExtrospectArtifactPathIsTheCandidateContract() external view {
        DeployCandidate memory candidate = extrospectCandidate();
        assertEq(
            keccak256(vm.getCode(candidate.snapshot.artifactPath)),
            keccak256(candidate.sourceCreationCode),
            "artifact path does not compile to the candidate's source creation code"
        );
    }

    /// `Extrospect` reads nothing and calls nothing at construction, so it
    /// has no dependency that must already be on chain.
    function testExtrospectCandidateHasNoDependencies() external pure {
        DeployCandidate memory candidate = extrospectCandidate();
        assertEq(candidate.snapshot.dependencies.length, 0, "candidate declares a construction dependency");
    }
}
