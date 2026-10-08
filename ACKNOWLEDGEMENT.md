# Acknowledgement

This repository started as the [Speedrun Ethereum stablecoin challenge](https://speedrunethereum.com/challenge/stablecoins) starter, which is built on [Scaffold-ETH 2](https://scaffoldeth.io) by [BuidlGuidl](https://buidlguidl.com). The starter is under the MIT license in `LICENCE`.

It was downloaded with:

```sh
npx create-eth@2.0.23 -e scaffold-eth/se-2-challenges:challenge-stablecoins challenge-stablecoins
```

## What this group changed

- Renamed the tutorial coin **MyUSD** to **USDL** in the contracts, website, tests, and docs.
- Added `WORKLOAD.md`, `WORKLOAD.jpg`, and `WORKLOAD.pdf`, which split the tutorial checkpoints among the group.

## What is still the tutorial starter

The contracts, website, and local-chain setup came from the challenge. `USDLEngine.sol` still has the tutorial's empty functions. Filling those in is this group's remaining work. The other contracts were only renamed.

## AI assistance

Cursor was used to rename MyUSD to USDL, to add the workload chart, and to write this acknowledgement. The commits for that work list Cursor as a co-author.

Cursor was not used to implement the stablecoin rules. `USDLEngine.sol` still has the tutorial's empty functions, and the group will write those.
