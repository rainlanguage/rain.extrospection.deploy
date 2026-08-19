// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script, console2} from "forge-std-1.16.2/src/Script.sol";
import {LibExtrospectDeploy} from "../src/lib/LibExtrospectDeploy.sol";

/// @title PrintExtrospectAddress
/// @notice Emits `Extrospect`'s deterministic deploy address — aliased by
/// `LibExtrospectDeploy` from the generated candidate snapshot — so CI can
/// capture the address without hardcoding it in workflow YAML.
contract PrintExtrospectAddress is Script {
    function run() external pure {
        console2.log(LibExtrospectDeploy.EXTROSPECT_DEPLOYED_ADDRESS);
    }
}
