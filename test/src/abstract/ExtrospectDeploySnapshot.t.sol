// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifySnapshot} from "rain-deploy-0.1.7/src/abstract/RainDeployVerifySnapshot.sol";
import {ExtrospectDeploySuites} from "src/abstract/ExtrospectDeploySuites.sol";

/// @title ExtrospectDeploySnapshotTest
/// @notice The deploy-pin assertions for `Extrospect` that need no network:
/// what the alias lib records is what the creation code this repo compiles
/// derives, the candidate is a snapshot of its own source rather than of some
/// other contract, and every release in the frozen `src/generated/<tag>/`
/// record is declared.
///
/// The pins are a pure function of the creation code, which is a pure function
/// of this repo's compiler settings — and the contract, the settings and the
/// pins are all in this repo, so this closes the loop rather than asserting
/// across a boundary.
///
/// All assertions are inherited. There is nothing to write here, which is the
/// point: `ExtrospectDeploySuites` says which suites exist and
/// `RainDeployVerifySnapshot` says what is true of them.
contract ExtrospectDeploySnapshotTest is ExtrospectDeploySuites, RainDeployVerifySnapshot {}
