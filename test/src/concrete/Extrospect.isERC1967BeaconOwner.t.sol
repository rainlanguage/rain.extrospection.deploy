// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectERC1967BeaconProxy} from "rain-extrospection-0.1.31/src/lib/LibExtrospectERC1967BeaconProxy.sol";
import {MockBeacon} from "test/concrete/MockBeacon.sol";
import {EmptyContract} from "test/concrete/EmptyContract.sol";

contract ExtrospectIsERC1967BeaconOwnerTest is ExtrospectEquivalence {
    function testIsERC1967BeaconOwnerEquivalenceMatch(address owner) external {
        EmptyContract impl = new EmptyContract();
        MockBeacon beacon = new MockBeacon(address(impl), owner);

        assertEq(
            extrospect.isERC1967BeaconOwner(address(beacon), owner),
            LibExtrospectERC1967BeaconProxy.isBeaconOwner(address(beacon), owner)
        );
    }

    function testIsERC1967BeaconOwnerEquivalenceMismatch(address actual, address wrong) external {
        vm.assume(actual != wrong);
        EmptyContract impl = new EmptyContract();
        MockBeacon beacon = new MockBeacon(address(impl), actual);

        assertEq(
            extrospect.isERC1967BeaconOwner(address(beacon), wrong),
            LibExtrospectERC1967BeaconProxy.isBeaconOwner(address(beacon), wrong)
        );
    }
}
