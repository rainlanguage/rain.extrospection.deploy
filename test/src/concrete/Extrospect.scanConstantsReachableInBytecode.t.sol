// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ExtrospectEquivalence} from "test/concrete/ExtrospectEquivalence.sol";
import {LibExtrospectBytecode} from "rain-extrospection-0.1.31/src/lib/LibExtrospectBytecode.sol";

contract ExtrospectScanConstantsReachableInBytecodeTest is ExtrospectEquivalence {
    /// Oracle: `LibExtrospectBytecode.scanConstantsReachableInBytecode`, re-exposed for a raw self-call.
    function _libScan(bytes memory bytecode) external pure returns (uint256[] memory) {
        return LibExtrospectBytecode.scanConstantsReachableInBytecode(bytecode);
    }

    function assertScanEquivalence(bytes memory bytecode) internal {
        assertEquivalence(
            bytes4(keccak256("scanConstantsReachableInBytecode(bytes)")), this._libScan.selector, abi.encode(bytecode)
        );
    }

    /// Oracle: `LibExtrospectBytecode.scanConstantsReachableInBytecode`.
    function testScanConstantsReachableInBytecodeEquivalenceFuzz(bytes memory bytecode) external {
        assertScanEquivalence(bytecode);
    }

    /// Oracle: `LibExtrospectBytecode.scanConstantsReachableInBytecode`.
    function testScanConstantsReachableInBytecodeEquivalenceEOF() external {
        assertScanEquivalence(hex"EF0000");
    }

    /// Oracle: hand decode of PUSH1 0x01, PUSH2 0xABCD, STOP, PUSH1 0x05.
    function testScanConstantsReachableInBytecodeKnownConstants() external {
        bytes memory bytecode = hex"600161ABCD006005";
        uint256[] memory constants = extrospect.scanConstantsReachableInBytecode(bytecode);
        assertEq(constants.length, 2);
        assertEq(constants[0], 0x01);
        assertEq(constants[1], 0xABCD);
        assertScanEquivalence(bytecode);
    }
}
