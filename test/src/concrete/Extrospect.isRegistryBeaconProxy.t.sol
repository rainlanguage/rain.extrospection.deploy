// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {
    LibExtrospectRegistryBeaconProxy,
    REGISTRY_BEACON_PROXY_PREFIX,
    REGISTRY_BEACON_PROXY_SUFFIX,
    REGISTRY_BEACON_PROXY_LENGTH
} from "rain-extrospection-0.1.31/src/lib/LibExtrospectRegistryBeaconProxy.sol";

contract ExtrospectIsRegistryBeaconProxyTest is ExtrospectEquivalence {
    function assertIsRegistryBeaconProxyEquivalence(bytes memory bytecode) internal view {
        (bool extIsProxy, address extBeacon) = extrospect.isRegistryBeaconProxy(bytecode);
        (bool libIsProxy, address libBeacon) = LibExtrospectRegistryBeaconProxy.isRegistryBeaconProxy(bytecode);
        assertEq(extIsProxy, libIsProxy);
        assertEq(extBeacon, libBeacon);
    }

    /// Concrete and library return the same verdict and beacon for any bytecode.
    function testIsRegistryBeaconProxyEquivalenceFuzz(bytes memory bytecode) external view {
        assertIsRegistryBeaconProxyEquivalence(bytecode);
    }

    /// Concrete and library return the same verdict and beacon for proxy bytecode with any beacon word.
    function testIsRegistryBeaconProxyEquivalenceBeaconWordFuzz(bytes32 beaconWord) external view {
        assertIsRegistryBeaconProxyEquivalence(
            abi.encodePacked(REGISTRY_BEACON_PROXY_PREFIX, beaconWord, REGISTRY_BEACON_PROXY_SUFFIX)
        );
    }

    /// Concrete and library return the same verdict and beacon for empty bytecode.
    function testIsRegistryBeaconProxyEquivalenceEmpty() external view {
        assertIsRegistryBeaconProxyEquivalence(hex"");
    }

    /// The concrete returns the beacon embedded in a well-formed proxy, not just the verdict.
    function testIsRegistryBeaconProxyConcreteBeaconAddress(address beacon) external view {
        vm.assume(beacon != address(0));
        bytes memory proxy =
            abi.encodePacked(REGISTRY_BEACON_PROXY_PREFIX, uint256(uint160(beacon)), REGISTRY_BEACON_PROXY_SUFFIX);
        assertEq(proxy.length, REGISTRY_BEACON_PROXY_LENGTH);
        (bool extIsProxy, address extBeacon) = extrospect.isRegistryBeaconProxy(proxy);
        assertTrue(extIsProxy);
        assertEq(extBeacon, beacon);
    }

    /// EOF bytecode of exactly the proxy length returns `(false, address(0))` on both sides.
    function testIsRegistryBeaconProxyEquivalenceEOF() external view {
        bytes memory bytecode = abi.encodePacked(hex"EF00", new bytes(REGISTRY_BEACON_PROXY_LENGTH - 2));
        (bool extIsProxy, address extBeacon) = extrospect.isRegistryBeaconProxy(bytecode);
        assertFalse(extIsProxy);
        assertEq(extBeacon, address(0));
        assertIsRegistryBeaconProxyEquivalence(bytecode);
    }
}
