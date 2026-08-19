// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {Vm} from "forge-std-1.16.2/src/Vm.sol";

/// @title LibReleasedSuitesAggregate
/// @notice Reading a generated released-suites aggregate back: which contracts
/// the committed file actually declares. The list is read off the file rather
/// than restated, because a list restated in a test is another place a
/// contract has to be added to — which is the defect the aggregate exists to
/// remove.
library LibReleasedSuitesAggregate {
    /// The contracts an emitted aggregate declares, in the order it imports
    /// them.
    ///
    /// Split on the import statement's own opening rather than parsed, because
    /// the text is generated: `aggregateImportBlock` emits exactly
    /// `import {Lib<Contract>Released} from ...` on a line of its own, one per
    /// contract, and nothing else in the file opens a line that way. The
    /// `DeploySuite` import does not match — it is not a `Lib` — and the
    /// library block below the imports never starts a line with `import`.
    /// @param vm The Vm instance for string operations.
    /// @param source An emitted aggregate.
    /// @return names The contract names, in the order imported.
    function declaredContractNames(Vm vm, string memory source) internal pure returns (string[] memory names) {
        string[] memory chunks = vm.split(source, "\nimport {Lib");

        names = new string[](chunks.length - 1);
        for (uint256 i = 1; i < chunks.length; i++) {
            names[i - 1] = vm.split(chunks[i], "Released}")[0];
        }
    }
}
