// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifyDeclaration} from "rain-deploy-0.1.33/src/abstract/RainDeployVerifyDeclaration.sol";
import {ExtrospectDeploySuites} from "src/abstract/ExtrospectDeploySuites.sol";

/// @title ExtrospectDeployDeclarationTest
/// @notice The `Extrospect` suite fields only a dispatch, a verifier or a broadcast reads.
contract ExtrospectDeployDeclarationTest is ExtrospectDeploySuites, RainDeployVerifyDeclaration {}
