// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {IExtrospectV2} from "rain-extrospection-0.1.19/src/interface/IExtrospectV2.sol";
import {LibExtrospectBytecode} from "rain-extrospection-0.1.19/src/lib/LibExtrospectBytecode.sol";
import {LibExtrospectMetamorphic} from "rain-extrospection-0.1.19/src/lib/LibExtrospectMetamorphic.sol";
import {LibExtrospectERC1167Proxy} from "rain-extrospection-0.1.19/src/lib/LibExtrospectERC1167Proxy.sol";
import {LibExtrospectERC1967BeaconProxy} from "rain-extrospection-0.1.19/src/lib/LibExtrospectERC1967BeaconProxy.sol";
import {LibExtrospectRegistryBeaconProxy} from
    "rain-extrospection-0.1.19/src/lib/LibExtrospectRegistryBeaconProxy.sol";

/// @title Extrospect
/// @notice Concrete implementation of `IExtrospectV2`. Parameterless
/// constructor for deterministic Zoltu deployment across EVM networks.
/// Consumers should depend on `IExtrospectV2` rather than importing this
/// contract directly.
contract Extrospect is IExtrospectV2 {
    /// @inheritdoc IExtrospectV2
    function checkCBORTrimmedBytecodeHash(address account, bytes32 expected) external view {
        LibExtrospectBytecode.checkCBORTrimmedBytecodeHash(account, expected);
    }

    /// @inheritdoc IExtrospectV2
    function checkNoSolidityCBORMetadata(address account) external view {
        LibExtrospectBytecode.checkNoSolidityCBORMetadata(account);
    }

    /// @inheritdoc IExtrospectV2
    function checkNotEOFBytecode(bytes memory bytecode) external pure {
        LibExtrospectBytecode.checkNotEOFBytecode(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function checkNotMetamorphic(bytes memory bytecode) external pure {
        LibExtrospectMetamorphic.checkNotMetamorphic(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function checkNotMetamorphic(address account) external view {
        LibExtrospectMetamorphic.checkNotMetamorphic(account);
    }

    /// @inheritdoc IExtrospectV2
    function isBeaconImplementationBytecode(address beacon, bytes32 expectedRuntimeHash) external view returns (bool) {
        return LibExtrospectERC1967BeaconProxy.isBeaconImplementationBytecode(beacon, expectedRuntimeHash);
    }

    /// @inheritdoc IExtrospectV2
    function isBeaconOwner(address beacon, address expectedOwner) external view returns (bool) {
        return LibExtrospectERC1967BeaconProxy.isBeaconOwner(beacon, expectedOwner);
    }

    /// @inheritdoc IExtrospectV2
    function isEOFBytecode(bytes memory bytecode) external pure returns (bool) {
        return LibExtrospectBytecode.isEOFBytecode(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function isERC1167Proxy(bytes memory bytecode) external pure returns (bool, address) {
        // False positive: tuple pass-through — both components re-emitted as this
        // function's own return, nothing discarded.
        // slither-disable-next-line unused-return
        return LibExtrospectERC1167Proxy.isERC1167Proxy(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function isRegistryBeaconProxy(bytes memory bytecode) external pure returns (bool, address) {
        return LibExtrospectRegistryBeaconProxy.isRegistryBeaconProxy(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function scanEVMOpcodesPresentInBytecode(bytes memory bytecode) external pure returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesPresentInBytecode(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function scanEVMOpcodesPresentInBytecode(address account) external view returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesPresentInBytecode(account);
    }

    /// @inheritdoc IExtrospectV2
    function scanEVMOpcodesReachableInBytecode(bytes memory bytecode) external pure returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesReachableInBytecode(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function scanEVMOpcodesReachableInBytecode(address account) external view returns (uint256) {
        return LibExtrospectBytecode.scanEVMOpcodesReachableInBytecode(account);
    }

    /// @inheritdoc IExtrospectV2
    function scanMetamorphicRisk(bytes memory bytecode) external pure returns (uint256) {
        return LibExtrospectMetamorphic.scanMetamorphicRisk(bytecode);
    }

    /// @inheritdoc IExtrospectV2
    function scanMetamorphicRisk(address account) external view returns (uint256) {
        return LibExtrospectMetamorphic.scanMetamorphicRisk(account);
    }

    /// @inheritdoc IExtrospectV2
    function tryTrimSolidityCBORMetadata(bytes memory bytecode)
        external
        pure
        returns (bool didTrim, bytes memory trimmedBytecode)
    {
        didTrim = LibExtrospectBytecode.tryTrimSolidityCBORMetadata(bytecode);
        return (didTrim, bytecode);
    }
}
