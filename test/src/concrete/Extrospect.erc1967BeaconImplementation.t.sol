// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectERC1967BeaconProxy} from "rain-extrospection-0.1.31/src/lib/LibExtrospectERC1967BeaconProxy.sol";
import {MockBeacon} from "test/concrete/MockBeacon.sol";
import {EmptyContract} from "test/concrete/EmptyContract.sol";

contract ExtrospectERC1967BeaconImplementationTest is ExtrospectEquivalence {
    function assertERC1967BeaconImplementationEquivalence(address account) internal view {
        (bool extOk, address extImpl) = extrospect.erc1967BeaconImplementation(account);
        (bool libOk, address libImpl) = LibExtrospectERC1967BeaconProxy.beaconImplementation(account);
        assertEq(extOk, libOk);
        assertEq(extImpl, libImpl);
    }

    /// Oracle: `LibExtrospectERC1967BeaconProxy.beaconImplementation`.
    function testERC1967BeaconImplementationEquivalenceFuzz(address account) external view {
        assertERC1967BeaconImplementationEquivalence(account);
    }

    /// Oracle: the implementation the `MockBeacon` was constructed with.
    function testERC1967BeaconImplementationBeaconReturnsImplementation(address impl) external {
        MockBeacon beacon = new MockBeacon(impl, address(this));
        (bool extOk, address extImpl) = extrospect.erc1967BeaconImplementation(address(beacon));
        assertTrue(extOk);
        assertEq(extImpl, impl);
        assertERC1967BeaconImplementationEquivalence(address(beacon));
    }

    /// Oracle: a codeless account answers `implementation()` with no return data.
    function testERC1967BeaconImplementationCodelessReturnsFalse(address account) external view {
        assumeNotPrecompile(account);
        vm.assume(account.code.length == 0);
        (bool extOk, address extImpl) = extrospect.erc1967BeaconImplementation(account);
        assertFalse(extOk);
        assertEq(extImpl, address(0));
        assertERC1967BeaconImplementationEquivalence(account);
    }

    /// Oracle: `EmptyContract` reverts on `implementation()`.
    function testERC1967BeaconImplementationNonBeaconReturnsFalse() external {
        EmptyContract notBeacon = new EmptyContract();
        (bool extOk, address extImpl) = extrospect.erc1967BeaconImplementation(address(notBeacon));
        assertFalse(extOk);
        assertEq(extImpl, address(0));
        assertERC1967BeaconImplementationEquivalence(address(notBeacon));
    }
}
