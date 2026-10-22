// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {Vm} from "forge-std-1.17.0/src/Vm.sol";

/// @title LibReleasedSuitesAggregate
/// @notice Reading a generated released-suites aggregate back: which contracts
/// the committed file actually declares. The list is read off the file rather
/// than restated, because a list restated in a test is another place a
/// contract has to be added to — which is the defect the aggregate exists to
/// remove.
library LibReleasedSuitesAggregate {
    /// The contracts an emitted aggregate declares, in the order it imports
    /// them: every `import {Lib<Contract>Released}` line. Other `Lib` imports,
    /// such as `LibDeploySuiteConcat`, are not contracts.
    /// @param vm The Vm instance for string operations.
    /// @param source An emitted aggregate.
    /// @return The contract names, in the order imported.
    function declaredContractNames(Vm vm, string memory source) internal pure returns (string[] memory) {
        string[] memory chunks = vm.split(source, "\nimport {Lib");

        string[] memory found = new string[](chunks.length);
        uint256 count = 0;
        for (uint256 i = 1; i < chunks.length; i++) {
            string[] memory parts = vm.split(vm.split(chunks[i], "}")[0], "Released");
            if (parts.length == 2 && bytes(parts[1]).length == 0) {
                found[count] = parts[0];
                count++;
            }
        }

        string[] memory names = new string[](count);
        for (uint256 i = 0; i < count; i++) {
            names[i] = found[i];
        }
        return names;
    }
}
