// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {DeployCandidate, DeploySuite, RainDeploySuitesBase} from "./RainDeploySuitesBase.sol";
import {Extrospect} from "../concrete/Extrospect.sol";
import {
    CREATION_CODE as EXTROSPECT_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as EXTROSPECT_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/Extrospect.sol";
import {LibExtrospectDeploy} from "../lib/LibExtrospectDeploy.sol";
import {LibReleasedSuites} from "../lib/LibReleasedSuites.sol";

/// @title ExtrospectDeploySuites
/// @notice Everything this repo deploys, declared ONCE: the hand-written
/// `extrospect` candidate below, and the released side read from the
/// generated `LibReleasedSuites`, which `script/Build.sol` emits from the
/// frozen record.
///
/// It lives in `src/` rather than `test/` because `.soldeerignore` excludes
/// `test/` from the published package, and in a deploy repo the deployment
/// process is the product.
abstract contract ExtrospectDeploySuites is RainDeploySuitesBase {
    /// @inheritdoc RainDeploySuitesBase
    function releasedSuites() internal pure override returns (DeploySuite[] memory) {
        return LibReleasedSuites.releasedSuites();
    }

    /// @inheritdoc RainDeploySuitesBase
    function candidateSuites() internal pure override returns (DeployCandidate[] memory) {
        DeployCandidate[] memory candidates = new DeployCandidate[](1);
        candidates[0] = extrospectCandidate();
        return candidates;
    }

    /// This repo's rolling `Extrospect` candidate. Named rather than reached
    /// by index into `candidateSuites`, because `script/Build.sol` emits the
    /// released-suites lib from THIS candidate specifically, and naming it
    /// keeps the suite key, the artifact path and the dependency list spelled
    /// once.
    ///
    /// `Extrospect` reads nothing and calls nothing at construction, so it has
    /// no dependency that must already be on chain.
    /// @return The candidate.
    function extrospectCandidate() internal pure returns (DeployCandidate memory) {
        return DeployCandidate({
            snapshot: DeploySuite({
                suite: "extrospect",
                creationCode: EXTROSPECT_CREATION_CODE_CANDIDATE,
                storedDeployedAddress: LibExtrospectDeploy.EXTROSPECT_DEPLOYED_ADDRESS,
                storedBytecodeHash: LibExtrospectDeploy.EXTROSPECT_DEPLOYED_CODEHASH,
                storedRuntimeCode: EXTROSPECT_RUNTIME_CODE_CANDIDATE,
                artifactPath: "src/concrete/Extrospect.sol:Extrospect",
                dependencies: new address[](0)
            }),
            sourceCreationCode: type(Extrospect).creationCode
        });
    }
}
