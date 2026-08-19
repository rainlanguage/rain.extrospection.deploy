// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

// Re-exports the deploy-suite declaration from the pinned `rain-deploy`
// package under this repo's own `src/abstract/` path.
//
// The generated libs under `src/lib/` import
// `../abstract/RainDeploySuitesBase.sol` — `LibRainDeploySnapshot`'s writers
// emit that relative path for every repo, and relative imports never go
// through remappings — so a consumer of the package makes the path resolve by
// re-exporting the shipped file here. A re-export exposes the SAME source
// unit, so the `DeploySuite` a generated lib names is the exact type every
// shipped abstract takes, not a local copy that would fail to unify.
//
// `ExtrospectDeploySuites` imports through this file too, so the one local
// spelling of the package path is here and nowhere else.
import {
    DeployCandidate,
    DeploySuite,
    RainDeploySuitesBase
} from "rain-deploy-0.1.7/src/abstract/RainDeploySuitesBase.sol";
