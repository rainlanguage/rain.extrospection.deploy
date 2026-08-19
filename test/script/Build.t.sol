// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.2/src/Test.sol";
import {GeneratedContract} from "script/Build.sol";
import {DeployCandidate} from "src/abstract/RainDeploySuitesBase.sol";
import {LibRainDeploySnapshot} from "rain-deploy-0.1.7/src/lib/LibRainDeploySnapshot.sol";
import {LibReleasedSuitesAggregate} from "test/lib/LibReleasedSuitesAggregate.sol";
import {BuildHarness} from "test/concrete/BuildHarness.sol";
import {LibStringSet} from "test/lib/LibStringSet.sol";

/// @title BuildTest
/// @notice `script/Build.sol`'s own declaration. `generatedContracts()` is
/// one list for every reader INSIDE `Build`, but what this repo deploys is
/// declared in `ExtrospectDeploySuites.candidateSuites()`, and the
/// generator's list is a second hard-coded array in a second file.
///
/// A candidate dropped from `generatedContracts()` by a refactor or a merge
/// still compiles, because its committed snapshot is still there and still
/// imported — and every release cut after that permanently omits it, with
/// nothing downstream able to see the hole: `testEveryFrozenSnapshotIsReleased`
/// walks record -> declaration, so a record entry never written is invisible
/// to it, and `ExtrospectDeployChainTest` is never handed the omitted suite.
/// So the agreement of the two lists is asserted here, along with the
/// properties of the generator's own entries that decide which file each
/// contract's pins are written into.
///
/// Deliberately nothing here calls `run()` or `cutRelease()`. Both rewrite the
/// committed `src/generated/` snapshots and `src/lib/` libs that other test
/// contracts read, and forge runs test contracts in parallel — a contract
/// rewriting what another one is reading is a race, not a check. Nothing below
/// writes anything.
contract BuildTest is Test {
    /// The harness the two declarations are read through.
    BuildHarness internal sBuild;

    function setUp() external {
        sBuild = new BuildHarness();
    }

    /// PROPERTY: the generator's list and the deploy declaration are the SAME
    /// SET of contracts, matched both ways — by the suite key rather than by
    /// index, because a positional pass would go green on a reordered list
    /// that had silently swapped two contracts.
    function testGeneratedContractsAreExactlyTheDeclaredCandidates() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        DeployCandidate[] memory candidates = sBuild.externalCandidateSuites();

        assertEq(
            generated.length, candidates.length, "a candidate is not generated, or a generated contract is not declared"
        );

        for (uint256 i = 0; i < generated.length; i++) {
            bool found = false;
            for (uint256 j = 0; j < candidates.length; j++) {
                if (
                    keccak256(bytes(generated[i].candidate.snapshot.suite))
                        == keccak256(bytes(candidates[j].snapshot.suite))
                ) {
                    assertEq(
                        keccak256(generated[i].candidate.snapshot.creationCode),
                        keccak256(candidates[j].snapshot.creationCode),
                        "generated entry carries another contract's creation code"
                    );
                    found = true;
                    break;
                }
            }
            assertTrue(
                found, string.concat("generated contract is not a declared candidate: ", generated[i].contractName)
            );
        }

        for (uint256 j = 0; j < candidates.length; j++) {
            bool found = false;
            for (uint256 i = 0; i < generated.length; i++) {
                if (
                    keccak256(bytes(generated[i].candidate.snapshot.suite))
                        == keccak256(bytes(candidates[j].snapshot.suite))
                ) {
                    found = true;
                    break;
                }
            }
            assertTrue(found, string.concat("declared candidate is not generated: ", candidates[j].snapshot.suite));
        }
    }

    /// PROPERTY: the names a release freezes are EXACTLY the generator's
    /// contracts. A generated contract missing from `snapshotContractNames()`
    /// is regenerated on every push and then absent from the frozen tag.
    function testSnapshotContractNamesAreTheGeneratedContracts() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        string[] memory names = sBuild.externalSnapshotContractNames();

        assertEq(
            names.length, generated.length, "a generated contract is not frozen, or a frozen name is not generated"
        );
        for (uint256 i = 0; i < generated.length; i++) {
            assertTrue(
                LibStringSet.holds(names, generated[i].contractName),
                string.concat("generated contract is not frozen by a release: ", generated[i].contractName)
            );
        }
    }

    /// PROPERTY: `contractName` is the name the snapshot path and both
    /// generated libs are built from, and it MUST be the contract the
    /// candidate's artifact path names. A disagreement writes one contract's
    /// pins into another contract's file, which every downstream check then
    /// reads as self-consistent.
    function testGeneratedContractNameMatchesTheArtifactPath() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        for (uint256 i = 0; i < generated.length; i++) {
            string[] memory components = vm.split(generated[i].candidate.snapshot.artifactPath, ":");
            assertEq(
                components[components.length - 1],
                generated[i].contractName,
                "generated name is not the artifact's contract"
            );
        }
    }

    /// PROPERTY: no two entries name one contract. Two entries sharing a
    /// `contractName` write one snapshot file twice and freeze one file for two
    /// declarations, so the second silently replaces the first.
    function testGeneratedContractNamesAreUnique() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        for (uint256 i = 0; i < generated.length; i++) {
            for (uint256 j = i + 1; j < generated.length; j++) {
                assertNotEq(
                    generated[i].contractName, generated[j].contractName, "two generated entries name one contract"
                );
            }
        }
    }

    /// PROPERTY: the constant prefix is non-empty and distinct per contract. It
    /// names every constant both generated libs export, so a shared prefix is
    /// two libs exporting colliding names.
    function testConstantPrefixesAreNonEmptyAndUnique() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        for (uint256 i = 0; i < generated.length; i++) {
            assertGt(bytes(generated[i].constantPrefix).length, 0, "empty constant prefix");
            for (uint256 j = i + 1; j < generated.length; j++) {
                assertNotEq(
                    generated[i].constantPrefix, generated[j].constantPrefix, "two entries share a constant prefix"
                );
            }
        }
    }

    /// PROPERTY: the committed aggregate imports the generated contracts in
    /// `generatedContracts()`'s ORDER, not merely as a set.
    ///
    /// Declaration order is claimed twice — the emitted library documents its
    /// entries as being "in declaration order" and `snapshotContractNames()`
    /// documents itself as giving "the order the aggregate emits its entries
    /// in" — and nothing else pins it: no other test in this repo reads the
    /// committed aggregate at all. So the imports and the per-contract locals
    /// can be permuted in the committed file — byte-exactly what the generator
    /// emits for the reordered list — and the whole suite stays green while
    /// the aggregate returns the releases in an order the declaration does not
    /// give, which is the order `suiteNames()` reports them in.
    ///
    /// Positional, because the SET is already matched by
    /// `testGeneratedContractsAreExactlyTheDeclaredCandidates` and the order is
    /// the whole of what is left.
    function testTheCommittedAggregateIsInDeclarationOrder() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        string[] memory imported = LibReleasedSuitesAggregate.declaredContractNames(
            vm, vm.readFile(LibRainDeploySnapshot.pathForLib(LibRainDeploySnapshot.RELEASED_SUITES_LIBRARY))
        );

        assertEq(
            imported.length,
            generated.length,
            "the committed aggregate imports a different number of contracts than the generator names"
        );

        for (uint256 i = 0; i < generated.length; i++) {
            assertEq(
                imported[i],
                generated[i].contractName,
                "the committed aggregate is not in the generator's declaration order"
            );
        }
    }

    /// PROPERTY: `snapshotContractNames()` is every `generatedContracts()`
    /// entry's `contractName`, positionally. The freeze and the aggregate
    /// reach it only through `forge script`, so a name list shorter than the
    /// declaration freezes one contract fewer while every other assertion
    /// here stays green: the tests above read `generatedContracts()` and the
    /// committed file, neither of which this list passes through.
    function testSnapshotContractNamesAreTheDeclarationInOrder() external view {
        GeneratedContract[] memory generated = sBuild.externalGeneratedContracts();
        string[] memory names = sBuild.externalSnapshotContractNames();

        assertEq(names.length, generated.length, "a different number of names than generated contracts");

        for (uint256 i = 0; i < generated.length; i++) {
            assertEq(names[i], generated[i].contractName, "the names are not the declaration in order");
        }
    }
}
