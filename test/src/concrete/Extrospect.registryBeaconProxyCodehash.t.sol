// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {
    LibExtrospectRegistryBeaconProxy,
    REGISTRY_BEACON_PROXY_PREFIX,
    REGISTRY_BEACON_PROXY_SUFFIX
} from "rain-extrospection-0.1.31/src/lib/LibExtrospectRegistryBeaconProxy.sol";

contract ExtrospectRegistryBeaconProxyCodehashTest is ExtrospectEquivalence {
    /// Oracle: `LibExtrospectRegistryBeaconProxy.codehash`.
    function testRegistryBeaconProxyCodehashEquivalenceFuzz(address beacon) external view {
        assertEq(extrospect.registryBeaconProxyCodehash(beacon), LibExtrospectRegistryBeaconProxy.codehash(beacon));
    }

    /// Oracle: `extcodehash` of registry beacon proxy runtime bytecode holding `beacon`.
    function testRegistryBeaconProxyCodehashMatchesRegistryBeaconProxyExtcodehash(address beacon) external {
        bytes memory proxy =
            abi.encodePacked(REGISTRY_BEACON_PROXY_PREFIX, uint256(uint160(beacon)), REGISTRY_BEACON_PROXY_SUFFIX);
        vm.etch(address(0xbeef), proxy);
        assertEq(extrospect.registryBeaconProxyCodehash(beacon), address(0xbeef).codehash);
    }
}
