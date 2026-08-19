// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployBroadcast} from "rain-deploy-0.1.7/src/abstract/RainDeployBroadcast.sol";
import {ExtrospectDeploySuites} from "../src/abstract/ExtrospectDeploySuites.sol";

/// @title Deploy
/// @notice The on-chain deploy. Broadcasts whichever suite `DEPLOYMENT_SUITE`
/// names, through the Zoltu factory, to every supported network. One suite per
/// dispatch; the `Manual sol artifacts` workflow dispatches the `extrospect`
/// suite.
///
/// Empty on purpose. The suite comes from `ExtrospectDeploySuites`, which is
/// the same declaration the verification tests inherit, and the dispatch, the
/// key handling and the broadcast come from `RainDeployBroadcast`. A deploy
/// repo writes its declaration and this pair of base contracts, and nothing
/// else — no per-suite branch, no per-network list.
///
/// Deploying is idempotent by construction. `deployToNetworks` checks the
/// recorded address against the creation code before it forks anything, then
/// skips any network that already has code there, so a partial run — five
/// chains of seven, one RPC down — is fixed by running it again rather than by
/// unpicking anything.
contract Deploy is ExtrospectDeploySuites, RainDeployBroadcast {}
