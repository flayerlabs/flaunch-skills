---
name: flaunch-manager
description: Route Flaunch treasury-manager work to the right integration pattern and testing reference.
---

# Flaunch Manager

Use this skill when the user needs treasury-side behavior attached to launched Flaunch tokens.

## Example Prompts

- Route all Flaunch fees to a treasury vault.
- Integrate `StakingManager` and write the minimum required tests.
- Build a buyback-based manager integration on Base Sepolia.

## Best Fit

Use this skill for:

- fee routing to vaults or treasuries
- staking-based fee distribution
- buyback routing
- manager-aware launch flows
- manager integration tests

## Required Inputs

Before coding, identify:

- the payout policy
- target chain and environment
- recipient or consumer behavior
- required claim or route action
- the test invariants to prove

## Quick Router

Choose the smallest manager path that matches the job:

- fixed recipient routing: `references/address-fee-split-integration.md`
- staking rewards: `references/staking-integration.md`
- buyback policy: `references/buyback-integration.md`
- custom manager implementation: `../../advanced/manager-builder/SKILL.md`
- manager-bound launch wrapper: `../../advanced/manager-zap-wrapper/SKILL.md`

Default direct-routing choice:

- `AddressFeeSplitManager` with `recipientShares = [(recipientContract, 100_00000)]`

## Common Integration Baseline

Most manager integrations should follow this sequence:

1. Reuse existing Flaunch contracts and tests before adding local helpers.
2. Set up the Flaunch harness.
3. Deploy the consumer or recipient contract if needed.
4. Deploy and approve the manager in `TreasuryManagerFactory`.
5. Encode `initializeData` and `depositData`.
6. Launch through `FlaunchZap.flaunch(...)`.
7. Capture the deployed manager address.
8. Trigger the manager-specific claim or route path.
9. Assert balances, accounting, and NFT ownership invariants.

## Non-Negotiable Rules

- Every manager integration needs at least one happy-path test and one revert-path test.
- Use a real ETH transfer to simulate manager-accounted fees; do not rely on `vm.deal`.
- For new integrations, set `initialTokenFairLaunch = 0` and `fairLaunchDuration = 0`.
- Prefer Flaunch harnesses in `lib/flaunchgg-contracts` over copying large files.
- Use `scripts/encode-address-fee-split.sh` when a single-recipient fee-split payload is needed quickly.

## Out of Scope

This skill should not be the first stop for:

- plain API-driven token launches
- plain SDK-only launchpad work with no custom treasury behavior

Route those to the API or SDK skills.
