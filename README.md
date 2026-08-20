# rain.extrospection.deploy

The **deployment** half of `rain.extrospection`: the concrete `Extrospect`
contract, its generated deploy record (`src/generated/candidate/Extrospect.sol`
and the `LibExtrospectDeploy` alias lib), the per-function equivalence tests
that hold `Extrospect` to the libraries it forwards to, and the deploy script.

The **library** half — `IExtrospectV1`, `IBeacon`, `IOwnable` and the
`LibExtrospect*` libraries — lives in
[`rain.extrospection`](https://github.com/rainlanguage/rain.extrospection) and
is imported here as the `rain-extrospection` Soldeer package. Consumers that
need only the interfaces or libraries depend on `rain-extrospection`; consumers
that need the deployed address, codehash or creation bytecode depend on
`rain-extrospection-deploy`.

## The deploy record

This repo carries the
[`rain.deploy`](https://github.com/rainlanguage/rain.deploy) deploy standard,
generated rather than hand-written:

- `src/abstract/ExtrospectDeploySuites.sol` declares everything this repo
  deploys, ONCE: the rolling `extrospect` candidate anchored to
  `type(Extrospect).creationCode`, and the released suites read from the
  generated `LibReleasedSuites` — empty until the first release is cut.
- `src/generated/candidate/Extrospect.sol` is the rolling snapshot
  `script/Build.sol` regenerates from current source: deterministic Zoltu
  address, codehash, creation bytecode, runtime bytecode and dependency list.
  `src/lib/LibExtrospectDeploy.sol` aliases its pins under a stable import path.
- `script/Deploy.sol` is the declaration plus `RainDeployBroadcast`, nothing
  else; `script/Build.sol` is the declaration plus `BuildScript`.

`ExtrospectDeploySnapshotTest` inherits every no-network assertion from
`RainDeployVerifySnapshot`: the record derives from its own creation code, the
candidate is a snapshot of this repo's source, and every frozen
`src/generated/<tag>/` record is declared. `ExtrospectDeployChainTest` inherits
`RainDeployVerifyChain`, which holds every RELEASED suite live on every
supported network — with no release cut it has no subject and forks nothing.
`ExtrospectConstantsTest` ties the generated candidate to the live V1 deployment
(`0x1BE878af679C1a0A6AC15108b0F4398de1f94506`) byte for byte, and executes the
recorded creation bytecode through the Zoltu factory's own bytecode, etched
offline. The whole record is a pure function of the creation code, so none of
that needs a network.

## Releases

Releases are manual `sol-v*` tags, never merges. Tagging runs
`rainix-tag-release`, which never broadcasts; its mechanics live in rainix.

The on-chain deploy is separate and human-dispatched, run BEFORE tagging: the
`Manual sol artifacts` workflow runs `script/Deploy.sol` for the `extrospect`
suite.

See rainlanguage/rain.extrospection#46 for the split rationale.
