// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectMetamorphic} from "rain-extrospection-0.1.31/src/lib/LibExtrospectMetamorphic.sol";

contract ExtrospectScanMetamorphicRiskTest is ExtrospectEquivalence {
    /// External re-exposure of the library function so it can be reached via a
    /// raw self-call and its returndata captured alongside the concrete's.
    function _libScan(bytes memory bytecode) external pure returns (uint256) {
        return LibExtrospectMetamorphic.scanMetamorphicRisk(bytecode);
    }

    function _libScanAccount(address account) external view returns (uint256) {
        return LibExtrospectMetamorphic.scanMetamorphicRisk(account);
    }

    function assertScanEquivalence(bytes memory bytecode) internal {
        assertEquivalence(bytes4(keccak256("scanMetamorphicRisk(bytes)")), this._libScan.selector, abi.encode(bytecode));
    }

    function assertScanAccountEquivalence(address account) internal {
        assertEquivalence(
            bytes4(keccak256("scanMetamorphicRisk(address)")), this._libScanAccount.selector, abi.encode(account)
        );
    }

    /// Concrete and library agree byte-for-byte on the success path: both
    /// return the same encoded metamorphic-risk bitmap, and on the EOF revert
    /// path both emit the byte-identical `EOFBytecodeNotSupported` payload.
    function testScanMetamorphicRiskEquivalenceFuzz(bytes memory bytecode) external {
        assertScanEquivalence(bytecode);
    }

    /// Concrete and library return the byte-identical metamorphic-risk bitmap
    /// for bytecode containing a reachable DELEGATECALL.
    function testScanMetamorphicRiskEquivalenceWithDelegatecall() external {
        assertScanEquivalence(hex"60006000600060006000F4");
    }

    /// Concrete and library revert with the byte-identical
    /// `EOFBytecodeNotSupported` payload for EOF-prefixed bytecode.
    function testScanMetamorphicRiskEquivalenceEOF() external {
        assertScanEquivalence(hex"EF0000");
    }

    /// Account overload: byte-identical bitmap for account code with a reachable DELEGATECALL.
    function testScanMetamorphicRiskAccountEquivalenceWithDelegatecall() external {
        vm.etch(address(0xbeef), hex"60006000600060006000F4");
        assertScanAccountEquivalence(address(0xbeef));
    }

    /// Account overload: byte-identical `1 << 0xEF` bitmap for `0xEF`-led account code.
    function testScanMetamorphicRiskAccountEquivalenceEOF() external {
        vm.etch(address(0xbeef), hex"EF0000");
        assertScanAccountEquivalence(address(0xbeef));
    }

    /// Account overload: byte-identical `CodelessAccount` payload for any codeless account.
    function testScanMetamorphicRiskAccountEquivalenceCodeless(address account) external {
        vm.assume(account.code.length == 0);
        assertScanAccountEquivalence(account);
    }
}
