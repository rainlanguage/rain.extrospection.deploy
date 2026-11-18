// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectBytecode} from "rain-extrospection-0.1.30/src/lib/LibExtrospectBytecode.sol";
import {LibExtrospectTestEtch} from "rain-extrospection-0.1.30/test/lib/LibExtrospectTestEtch.sol";

contract ExtrospectScanEVMOpcodesReachableInBytecodeTest is ExtrospectEquivalence {
    /// External re-exposure of the library function so it can be reached via a
    /// raw self-call and its returndata captured alongside the concrete's.
    function _libScan(bytes memory bytecode) external pure returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesReachableInBytecode(bytecode);
    }

    function _libScanAccount(address account) external view returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesReachableInBytecode(account);
    }

    function assertScanEquivalence(bytes memory bytecode) internal {
        assertEquivalence(
            bytes4(keccak256("scanEVMOpcodesReachableInBytecode(bytes)")), this._libScan.selector, abi.encode(bytecode)
        );
    }

    function assertScanAccountEquivalence(address account) internal {
        assertEquivalence(
            bytes4(keccak256("scanEVMOpcodesReachableInBytecode(address)")),
            this._libScanAccount.selector,
            abi.encode(account)
        );
    }

    /// Concrete and library agree byte-for-byte on the success path: both
    /// return the same encoded reachable-opcode bitmap, and on the EOF revert
    /// path both emit the byte-identical `EOFBytecodeNotSupported` payload.
    function testScanEVMOpcodesReachableInBytecodeEquivalenceFuzz(bytes memory bytecode) external {
        assertScanEquivalence(bytecode);
    }

    /// Concrete and library return the byte-identical reachable-opcode bitmap
    /// for a concrete success-path input.
    function testScanEVMOpcodesReachableInBytecodeEquivalenceConcrete() external {
        // PUSH1 0x01 PUSH1 0x02 RETURN
        assertScanEquivalence(hex"60016002F3");
    }

    /// Concrete and library revert with the byte-identical
    /// `EOFBytecodeNotSupported` payload for EOF-prefixed bytecode.
    function testScanEVMOpcodesReachableInBytecodeEquivalenceEOF() external {
        assertScanEquivalence(hex"EF0000");
    }

    /// `hex"00F0"` is STOP followed by CREATE, so only STOP is reachable. The
    /// concrete must report the REACHABLE bitmap, which a delegation to the
    /// present scan would pollute with the CREATE bit.
    function testScanEVMOpcodesReachableInBytecodeUnreachableCreateNotCounted() external view {
        //forge-lint: disable-next-line(incorrect-shift)
        uint256 expected = uint256(1);
        assertEq(extrospect.scanEVMOpcodesReachableInBytecode(hex"00F0"), expected);
    }

    /// Account overload: same success flag and byte-identical returndata for any etched code.
    function testScanEVMOpcodesReachableInBytecodeAccountEquivalenceFuzz(bytes memory code) external {
        LibExtrospectTestEtch.assumeEtch(vm, address(0xbeef), code);
        assertScanAccountEquivalence(address(0xbeef));
    }

    /// Account overload: byte-identical reachable-opcode bitmap for concrete account code.
    function testScanEVMOpcodesReachableInBytecodeAccountEquivalenceConcrete() external {
        vm.etch(address(0xbeef), hex"60016002F3");
        assertScanAccountEquivalence(address(0xbeef));
    }

    /// Account overload: byte-identical `EOFBytecodeNotSupported` payload for EOF account code.
    function testScanEVMOpcodesReachableInBytecodeAccountEquivalenceEOF() external {
        vm.etch(address(0xbeef), hex"EF0000");
        assertScanAccountEquivalence(address(0xbeef));
    }

    /// Account overload: byte-identical `CodelessAccount` payload for any codeless account.
    function testScanEVMOpcodesReachableInBytecodeAccountEquivalenceCodeless(address account) external {
        vm.assume(account.code.length == 0);
        assertScanAccountEquivalence(account);
    }

    /// Account overload: STOP then CREATE reports only the reachable STOP bit.
    function testScanEVMOpcodesReachableInBytecodeAccountUnreachableCreateNotCounted() external {
        vm.etch(address(0xbeef), hex"00F0");
        assertEq(extrospect.scanEVMOpcodesReachableInBytecode(address(0xbeef)), uint256(1));
    }
}
