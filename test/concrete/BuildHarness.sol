// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Build, GeneratedContract} from "script/Build.sol";
import {DeployCandidate, DeployDeclaration} from "rain-deploy-0.1.35/src/abstract/RainDeploySuitesBase.sol";

/// @title BuildHarness
/// @notice An external seam onto the two internal declarations `BuildTest`
/// compares, so a test can hold both at once.
///
/// A harness rather than a change to `Build`: `generatedContracts(d)` is the
/// script's own declaration and has no caller outside it, and widening it to
/// `public` to be testable would put a second entry point on a script whose
/// whole surface is `run()` and `cutRelease()`.
contract BuildHarness is Build {
    /// The generator's list over the deploy declaration, unchecked, so the
    /// tests assert its properties themselves.
    /// @return The generated contracts.
    function externalGeneratedContracts() external pure returns (GeneratedContract[] memory) {
        return generatedContracts(declaration());
    }

    /// The names a release cut from this script freezes, from the same inputs
    /// `cutRelease()` passes.
    /// @return The release record names.
    function externalReleaseRecordNames() external view returns (string[] memory) {
        DeployDeclaration memory d = declaration();
        return releaseRecordNames(d, checkedGeneratedContracts(d));
    }

    /// The deploy declaration's list, through the same guarded reader every
    /// other consumer of the declaration uses.
    /// @return The declared candidates.
    function externalCandidateSuites() external pure returns (DeployCandidate[] memory) {
        return checkedCandidateSuites(declaration());
    }
}
