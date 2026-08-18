# rain.extrospection.deploy

The **deployment** half of `rain.extrospection`: the concrete `Extrospect`
contract, its pinned deploy record (`EXTROSPECT_ZOLTU_ADDRESS_V1`,
`EXTROSPECT_RUNTIME_CODEHASH_V1`, `EXTROSPECT_CREATION_BYTECODE_V1`), the
per-function equivalence tests that hold `Extrospect` to the libraries it
forwards to, and the deploy script.

The **library** half — `IExtrospectV1`, `IBeacon`, `IOwnable` and the
`LibExtrospect*` libraries — lives in
[`rain.extrospection`](https://github.com/rainlanguage/rain.extrospection) and
is imported here as the `rain-extrospection` Soldeer package. Consumers that
need only the interfaces or libraries depend on `rain-extrospection`; consumers
that need the deployed address, codehash or creation bytecode depend on
`rain-extrospection-deploy`.

## The deploy record

`src/concrete/Extrospect.sol` carries all three pins as file-level constants.
`ExtrospectConstantsTest` holds each against the compiler and then executes the
pinned creation bytecode through the Zoltu factory's own bytecode, etched
offline, asserting it lands at the pinned address and leaves code hashing to the
pinned codehash. The whole record is a pure function of the creation code, so
that check needs no network.

## Releases

Nothing publishes on merge, and there is no release workflow yet, so pushing a
`sol-v*` tag does nothing. `rainix-tag-release` takes a required
`snapshot-generate-cmd` that regenerates a frozen `src/generated/<tag>/` deploy
record, and the library that generates one — `LibRainDeploySnapshot` in
[`rain.deploy`](https://github.com/rainlanguage/rain.deploy) — is on that repo's
`main` and in no published revision (latest `rain-deploy` is 0.1.5, cut
2026-07-30). Wiring the release lane is part of adopting that record, tracked by
rainlanguage/rain.extrospection#44.

The on-chain deploy is separate and human-dispatched: the `Manual sol artifacts`
workflow runs `script/Deploy.sol` for the `extrospect` suite.

See rainlanguage/rain.extrospection#46 for the split rationale.
