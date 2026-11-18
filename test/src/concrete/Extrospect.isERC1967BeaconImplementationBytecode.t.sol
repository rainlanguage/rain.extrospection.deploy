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
}
