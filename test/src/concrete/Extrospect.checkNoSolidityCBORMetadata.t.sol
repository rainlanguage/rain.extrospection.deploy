// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {SOLIDITY_CBOR_RUNTIME_FIXTURE} from "test/concrete/SolidityCBORFixture.sol";
import {LibExtrospectBytecode} from "rain-extrospection-0.1.13/src/lib/LibExtrospectBytecode.sol";

contract ExtrospectCheckNoSolidityCBORMetadataTest is ExtrospectEquivalence {
    //forge-lint: disable-next-line(mixed-case-function)
    function libCheckNoSolidityCBORMetadataExternal(address account) external view {
        LibExtrospectBytecode.checkNoSolidityCBORMetadata(account);
    }

    function testCheckNoSolidityCBORMetadataEquivalencePass() external view {
        // Account with code and no metadata passes both. `Extrospect`
        // itself compiles with `cbor_metadata = false`, so its own
        // runtime bytecode is the fixture.
        extrospect.checkNoSolidityCBORMetadata(address(extrospect));
        LibExtrospectBytecode.checkNoSolidityCBORMetadata(address(extrospect));
    }

    function testCheckNoSolidityCBORMetadataEquivalenceCodeless() external {
        // Account with no code reverts both with `CodelessAccount`:
        // absence of code is not absence of metadata risk, so the
        // check refuses to vouch for it.
        address codeless = address(0xdead);
        vm.expectRevert(abi.encodeWithSelector(LibExtrospectBytecode.CodelessAccount.selector, codeless));
        extrospect.checkNoSolidityCBORMetadata(codeless);
        vm.expectRevert(abi.encodeWithSelector(LibExtrospectBytecode.CodelessAccount.selector, codeless));
        this.libCheckNoSolidityCBORMetadataExternal(codeless);
    }

    function testCheckNoSolidityCBORMetadataEquivalenceRevert() external {
        bytes memory withMeta = SOLIDITY_CBOR_RUNTIME_FIXTURE;
        address deployed = address(0xbeef);
        vm.etch(deployed, withMeta);

        vm.expectRevert(LibExtrospectBytecode.UnexpectedMetadata.selector);
        extrospect.checkNoSolidityCBORMetadata(deployed);
        vm.expectRevert(LibExtrospectBytecode.UnexpectedMetadata.selector);
        this.libCheckNoSolidityCBORMetadataExternal(deployed);
    }
}
