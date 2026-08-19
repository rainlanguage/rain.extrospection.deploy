// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifyChain} from "rain-deploy-0.1.7/src/abstract/RainDeployVerifyChain.sol";
import {ExtrospectDeploySuites} from "src/abstract/ExtrospectDeploySuites.sol";

/// @title ExtrospectDeployChainTest
/// @notice Whether every `Extrospect` release this repo has RELEASED is
/// actually live, with the code that release froze, on every supported
/// network.
///
/// The chain group reads `releasedSuites()`, which is empty until the first
/// release is cut, so today it forks nothing and passes with no subject. It
/// gets one the moment a release is frozen, and then fails until every
/// supported network has that release's code — which is why the deploy is
/// dispatched before the tag is pushed. That failure is the check working.
///
/// The assertion is inherited. There is nothing to write here, which is the
/// point: `ExtrospectDeploySuites` says which releases exist and
/// `RainDeployVerifyChain` says what is true of them.
///
/// It is a separate contract from `ExtrospectDeploySnapshotTest` precisely so
/// that it says this and nothing more: a missing deployment or an unreachable
/// endpoint fails here alone, leaving every snapshot assertion to answer for
/// itself.
contract ExtrospectDeployChainTest is ExtrospectDeploySuites, RainDeployVerifyChain {}
