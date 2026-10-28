// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {RainDeployVerifyDeclaration} from "rain-deploy-0.1.26/src/abstract/RainDeployVerifyDeclaration.sol";
import {ExternalDeployment} from "rain-deploy-0.1.26/src/abstract/RainDeployDeclarationChecks.sol";
import {ExtrospectDeploySuites} from "src/abstract/ExtrospectDeploySuites.sol";
import {Extrospect} from "src/concrete/Extrospect.sol";

/// @title ExtrospectDeployDeclarationTest
/// @notice The `Extrospect` suite fields only a dispatch, a verifier or a broadcast reads.
contract ExtrospectDeployDeclarationTest is ExtrospectDeploySuites, RainDeployVerifyDeclaration {
    function sourceCreationCode(string memory suite) internal pure override returns (bytes memory) {
        if (keccak256(bytes(suite)) == keccak256("extrospect")) {
            return type(Extrospect).creationCode;
        }
        revert(string.concat("no source for suite: ", suite));
    }

    function externalDeployments() internal pure override returns (ExternalDeployment[] memory) {
        return new ExternalDeployment[](0);
    }
}
