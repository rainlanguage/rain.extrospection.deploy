# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## Project

rain.extrospection.deploy is the **deployment** half of `rain.extrospection`:
the concrete `Extrospect` contract plus its pinned deterministic-deploy record.
`Extrospect` implements `IExtrospectV1` by forwarding each function to the
`LibExtrospect*` library of the same name. Those interfaces and libraries are
NOT in this repo — they arrive as the `rain-extrospection` Soldeer package and
are read under `dependencies/rain-extrospection-<version>/src/`.

License: LicenseRef-DCL-1.0 (DecentraLicense). All source files carry SPDX
headers.

## Build & Test

Nix + Foundry, in the rainix `sol-shell` CI uses. `dependencies/` is gitignored,
so install before the first build.

```bash
nix develop -c forge soldeer install
nix develop -c forge build
nix develop -c forge test
nix develop -c forge test --match-test testExtrospectDeployRecordReproduces
nix develop -c forge fmt
nix develop -c slither .
nix develop -c reuse lint
```

Mutation and coverage campaigns: see `.claude/rules/mutation-profile.md`.

## Layout

- `src/concrete/Extrospect.sol` — the deployed contract, and the three deploy
  pins (`EXTROSPECT_ZOLTU_ADDRESS_V1`, `EXTROSPECT_RUNTIME_CODEHASH_V1`,
  `EXTROSPECT_CREATION_BYTECODE_V1`) as file-level constants.
- `script/Deploy.sol` — the Zoltu deploy script for the `extrospect` suite.
- `script/PrintExtrospectAddress.sol` — emits the pinned address for CI.
- `test/src/concrete/` — mirrors `src/` by subject path; files are named
  `Extrospect.<functionName>.t.sol`.
- `test/concrete/` — test-only fixtures. `MockBeacon`, `EmptyContract` and
  `SolidityCBORFixture` also exist in `rain.extrospection`, which needs them for
  its library tests.

## Conventions

- Concrete contracts, scripts and tests pin `=0.8.25`; libraries float
  `^0.8.25`.
- Cancun, optimizer on at 100,000 runs, no CBOR metadata. The pins are a pure
  function of these, so they are exact and match `rain.extrospection`'s.
- One contract per `.sol` file. No `@custom:` NatSpec. No skipped tests.
- Comments describe current behaviour only.
- Soldeer deps carry the version in the import path, e.g.
  `rain-extrospection-0.1.6/src/lib/LibExtrospectBytecode.sol`. `recursive_deps`
  is off, so every package an import resolves through is declared in
  `foundry.toml`.

## Deployment and releases

Deployed via the Zoltu deployer, so the address is a pure function of the
bytecode. A deploy is a human-dispatched run of `Manual sol artifacts`, never a
merge. There is no release workflow yet and nothing is published: see README.md.
