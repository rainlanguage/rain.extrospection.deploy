// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @title LibStringSet
/// @notice Membership over a `string[]`, for tests that assert about a set
/// whose order they do not fix.
library LibStringSet {
    /// Whether `haystack` holds `needle`.
    /// @param haystack The strings to search.
    /// @param needle The string to find.
    /// @return Whether it is present.
    function holds(string[] memory haystack, string memory needle) internal pure returns (bool) {
        for (uint256 i = 0; i < haystack.length; i++) {
            if (keccak256(bytes(haystack[i])) == keccak256(bytes(needle))) {
                return true;
            }
        }
        return false;
    }
}
