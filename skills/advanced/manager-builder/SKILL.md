---
name: flaunch-manager-builder
description: Build and integrate Flaunch treasury managers, launch memecoins with manager params, and validate fee routing, accounting, claims, buybacks, permissions, and custody rules on Base and Base Sepolia.
---

# Flaunch Manager Builder Skill

Use this skill when the user is building, testing, or reviewing treasury manager integrations.

Read `../../core/manager/SKILL.md` for the full source-of-truth manager guidance, including the broader manager workflow and encoding expectations.

## Best use cases

- smart contract manager development
- custom revenue, split, staking, or buyback manager flows
- manager-specific launch params
- `initializeData` and `depositData` encoding
- custody, escrow, claim, and buyback correctness
- manager-focused integration testing

## Manager router

| Goal | Manager |
|---|---|
| fixed recipient split | `AddressFeeSplitManager` |
| dynamic recipient split | `DynamicAddressFeeSplitManager` |
| staking rewards | `StakingManager` |
| buyback routing | `BuyBackManager` |
| creator + protocol split | `RevenueManager` |
| NFT-holder split | `ERC721OwnerFeeSplitManager` |

## Base lifecycle

1. `initialize(owner, data)` sets ownership and manager-specific config
2. `deposit(flaunchToken, creator, data)` validates permissions and escrows the Flaunch NFT into the manager
3. custom manager behavior should primarily live in `_initialize` and `_deposit`

## High-signal notes

- this is the advanced path because it depends on contract-level manager behavior
- fee balances come from registered escrow sources, not ad hoc local balances
- deposited Flaunch NFTs are custodied by the manager contract
- manager tests should prove happy path, failure path, accounting invariants, and no-double-claim behavior
- when manager behavior is nuanced, prefer the public `flaunchgg-contracts` manager docs and tests when they exist; otherwise keep guidance high level and avoid pointing users at private repos

## Related skill

- custom wrapper zap flow: `../manager-zap-wrapper/SKILL.md`
- full manager guidance: `../../core/manager/SKILL.md`
- manager type catalog: `../../core/manager/references/manager-types.md`
