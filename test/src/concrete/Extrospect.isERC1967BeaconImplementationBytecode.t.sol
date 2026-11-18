// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectERC1967BeaconProxy} from "rain-extrospection-0.1.31/src/lib/LibExtrospectERC1967BeaconProxy.sol";
import {MockBeacon} from "test/concrete/MockBeacon.sol";
import {EmptyContract} from "test/concrete/EmptyContract.sol";

contract ExtrospectIsERC1967BeaconImplementationBytecodeTest is ExtrospectEquivalence {
    function testIsERC1967BeaconImplementationBytecodeEquivalenceMatch() external {
        EmptyContract impl = new EmptyContract();
        MockBeacon beacon = new MockBeacon(address(impl), address(this));
        bytes32 expected = keccak256(address(impl).code);

        assertEq(
            extrospect.isERC1967BeaconImplementationBytecode(address(beacon), expected),
            LibExtrospectERC1967BeaconProxy.isBeaconImplementationBytecode(address(beacon), expected)
        );
    }

    function testIsERC1967BeaconImplementationBytecodeEquivalenceMismatch(bytes32 wrong) external {
        EmptyContract impl = new EmptyContract();
        MockBeacon beacon = new MockBeacon(address(impl), address(this));
        vm.assume(wrong != keccak256(address(impl).code));

        assertEq(
            extrospect.isERC1967BeaconImplementationBytecode(address(beacon), wrong),
            LibExtrospectERC1967BeaconProxy.isBeaconImplementationBytecode(address(beacon), wrong)
        );
    }

    /// Oracle: a codeless implementation's code is empty, so it hashes to `keccak256("")`.
    function testIsERC1967BeaconImplementationBytecodeCodelessImplementationMatchesEmptyHash(address impl) external {
        vm.assume(impl.code.length == 0);
        MockBeacon beacon = new MockBeacon(impl, address(this));

        assertTrue(extrospect.isERC1967BeaconImplementationBytecode(address(beacon), keccak256("")));
    }

    /// Oracle: `EmptyContract` reverts on `implementation()`, which fails the check.
    function testIsERC1967BeaconImplementationBytecodeNonBeaconIsFalse() external {
        EmptyContract notBeacon = new EmptyContract();

        assertFalse(extrospect.isERC1967BeaconImplementationBytecode(address(notBeacon), keccak256("")));
    }

    /// Oracle: a codeless account answers `implementation()` with no return data, which fails the check.
    function testIsERC1967BeaconImplementationBytecodeCodelessTargetIsFalse(address account) external view {
        assumeNotPrecompile(account);
        vm.assume(account.code.length == 0);

        assertFalse(extrospect.isERC1967BeaconImplementationBytecode(account, keccak256("")));
    }
}
