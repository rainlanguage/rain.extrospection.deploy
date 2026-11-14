// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {
    DeployCandidate,
    DeployDeclaration,
    DeployDependency,
    DeploySuite,
    RainDeploySuitesBase
} from "rain-deploy-0.1.32/src/abstract/RainDeploySuitesBase.sol";
import {
    CREATION_CODE as EXTROSPECT_CREATION_CODE_CANDIDATE,
    RUNTIME_CODE as EXTROSPECT_RUNTIME_CODE_CANDIDATE
} from "../generated/candidate/Extrospect.sol";
import {LibRainDeployDeclaration} from "rain-deploy-0.1.32/src/lib/LibRainDeployDeclaration.sol";
import {LibRainDeployZoltuMechanism} from "rain-deploy-0.1.32/src/lib/LibRainDeployZoltuMechanism.sol";
import {LibExtrospectDeploy} from "../lib/LibExtrospectDeploy.sol";
import {LibReleasedSuites} from "../lib/LibReleasedSuites.sol";
import {Extrospect} from "../concrete/Extrospect.sol";

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
    function declaration() internal pure override returns (DeployDeclaration memory) {
        DeployDeclaration memory declared;
        LibRainDeployDeclaration.extend(declared);
        LibRainDeployZoltuMechanism.extend(declared);
        LibRainDeployDeclaration.addReleased(declared, LibReleasedSuites.releasedSuites());
        DeployCandidate[] memory candidates = new DeployCandidate[](1);
        candidates[0] = extrospectCandidate();
        LibRainDeployDeclaration.addCandidates(declared, candidates);
        declared.sourceCreationCode = extrospectSourceCreationCode;
        return declared;
    }

    /// The creation code of the contract `suite` names.
    /// @param suite The suite key.
    /// @return The creation code.
    function extrospectSourceCreationCode(string memory suite) internal pure returns (bytes memory) {
        if (keccak256(bytes(suite)) == keccak256("extrospect")) {
            return type(Extrospect).creationCode;
        }
        revert(string.concat("no source for suite: ", suite));
    }

    /// This repo's rolling `Extrospect` candidate. Named rather than reached
    /// by index into `declaration().candidates`, because `script/Build.sol` emits the
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
                dependencies: new DeployDependency[](0),
                mechanismData: LibRainDeployZoltuMechanism.mechanismData(),
                networks: new string[](0),
                describedByMeta: ""
            }),
            unanchorableReason: ""
        });
    }
}
