// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {BuildScript, GeneratedContract} from "rain-deploy-0.1.37/src/abstract/BuildScript.sol";
import {DeployDeclaration} from "rain-deploy-0.1.37/src/abstract/RainDeploySuitesBase.sol";
import {ExtrospectDeploySuites} from "../src/abstract/ExtrospectDeploySuites.sol";
import {LibRainDeploySnapshot} from "rain-deploy-0.1.37/src/lib/LibRainDeploySnapshot.sol";

/// @title Build
/// @notice Generates the deploy pins for every contract this repo deploys.
/// `generatedContracts()` is the only list, read by every hook below.
contract Build is BuildScript, ExtrospectDeploySuites {
    /// @inheritdoc BuildScript
    function generatedContracts(DeployDeclaration memory d)
        internal
        pure
        override
        returns (GeneratedContract[] memory)
    {
        GeneratedContract[] memory contracts = new GeneratedContract[](1);
        contracts[0] = GeneratedContract({
            contractName: "Extrospect",
            constantPrefix: "EXTROSPECT",
            candidate: declaredCandidate(d, extrospectCandidate().snapshot.suite)
        });
        return contracts;
    }

    /// @inheritdoc BuildScript
    function regenerateSnapshots() internal override {
        GeneratedContract[] memory contracts = checkedGeneratedContracts(declaration());
        for (uint256 i = 0; i < contracts.length; i++) {
            LibRainDeploySnapshot.writeSnapshot(
                vm,
                recordRoot(),
                LibRainDeploySnapshot.CANDIDATE,
                contracts[i].contractName,
                vm.getCode(contracts[i].candidate.snapshot.artifactPath),
                contracts[i].candidate.snapshot.dependencies
            );
        }
    }
}
