// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectERC1967BeaconProxy} from "rain-extrospection-0.1.30/src/lib/LibExtrospectERC1967BeaconProxy.sol";
import {MockBeacon} from "test/concrete/MockBeacon.sol";
import {EmptyContract} from "test/concrete/EmptyContract.sol";

contract ExtrospectBeaconImplementationTest is ExtrospectEquivalence {
    function assertBeaconImplementationEquivalence(address account) internal view {
        (bool extOk, address extImpl) = extrospect.beaconImplementation(account);
        (bool libOk, address libImpl) = LibExtrospectERC1967BeaconProxy.beaconImplementation(account);
        assertEq(extOk, libOk);
        assertEq(extImpl, libImpl);
    }

    /// Oracle: `LibExtrospectERC1967BeaconProxy.beaconImplementation`.
    function testBeaconImplementationEquivalenceFuzz(address account) external view {
        assertBeaconImplementationEquivalence(account);
    }

    /// Oracle: the implementation the `MockBeacon` was constructed with.
    function testBeaconImplementationBeaconReturnsImplementation(address impl) external {
        MockBeacon beacon = new MockBeacon(impl, address(this));
        (bool extOk, address extImpl) = extrospect.beaconImplementation(address(beacon));
        assertTrue(extOk);
        assertEq(extImpl, impl);
        assertBeaconImplementationEquivalence(address(beacon));
    }

    /// Oracle: a codeless account answers `implementation()` with no return data.
    function testBeaconImplementationCodelessReturnsFalse(address account) external view {
        assumeNotPrecompile(account);
        vm.assume(account.code.length == 0);
        (bool extOk, address extImpl) = extrospect.beaconImplementation(account);
        assertFalse(extOk);
        assertEq(extImpl, address(0));
        assertBeaconImplementationEquivalence(account);
    }

    /// Oracle: `EmptyContract` reverts on `implementation()`.
    function testBeaconImplementationNonBeaconReturnsFalse() external {
        EmptyContract notBeacon = new EmptyContract();
        (bool extOk, address extImpl) = extrospect.beaconImplementation(address(notBeacon));
        assertFalse(extOk);
        assertEq(extImpl, address(0));
        assertBeaconImplementationEquivalence(address(notBeacon));
    }
}
