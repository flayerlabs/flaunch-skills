# Revenue Manager Integration

Use this reference when the product needs a creator-plus-protocol split rather than a general recipient-share manager.

## Best Fit

Choose `RevenueManager` when the product wants:

- protocol monetization on top of Flaunch
- a protocol fee recipient separate from creators
- claims based on creator-owned deposited tokens
- optional claims against all creator tokens or an explicit subset

Do not use this path when the product needs arbitrary recipient arrays or dynamic membership. Route those requests to the fee-split managers instead.

## Required Inputs

- target chain: `base` or `baseSepolia`
- `protocolRecipient`
- `protocolFee` with 2 decimal places
- creator assignment policy for deposited tokens
- expected creator claim flow and protocol claim flow

## Initialization Shape

```solidity
bytes memory initializeData = abi.encode(
    RevenueManager.InitializeParams({
        protocolRecipient: payable(protocolWallet),
        protocolFee: 5_00
    })
);
```

`protocolFee` is 2-decimal precision:

- `5_00` = 5%
- `100_00` = 100%

## Integration Workflow

1. Set up the Flaunch harness.
2. Deploy and approve `RevenueManager`.
3. Initialize with `protocolRecipient` and `protocolFee`.
4. Deposit one or more Flaunch NFTs into the manager, providing a nonzero creator address for each.
5. Accrue fees to the deposited tokens through the standard fee path.
6. Claim as the protocol recipient and as creators separately.
7. If needed, test explicit creator-token subset claims.
8. Assert per-token, per-creator, and protocol accounting independently.

## High-Signal Behaviors

The public manager tests and docs in `flaunchgg-contracts` should be treated as the source of truth when they include this manager.

- multiple deposited tokens can map to different creators
- `balances(recipient)` includes creator allocations across the recipient's deposited tokens
- the protocol recipient can claim protocol fees separately
- creators can claim all creator tokens with `claim()`
- creators can claim a subset with `claim(FlaunchToken[])`
- token-level and creator-level totals are tracked independently

## Minimum Assertions

- manager initializes with the intended protocol recipient and fee
- deposit fails for unowned or invalid tokens
- deposited token creator mapping is correct
- creator claim amount equals pool fee allocation minus protocol fee
- protocol claim amount equals the configured protocol fee slice
- claiming one creator token does not consume balances for another creator token
- repeated claims without new fees do not increase payout

## Guardrails

- do not treat `protocolFee` as a 5-decimal share
- creator address cannot be zero on deposit
- test protocol claims and creator claims as distinct flows
- when a creator holds multiple deposited tokens, test both full claim and subset claim behavior

## Reuse-First Rule

Before writing helpers, inspect:

- `flaunchgg-contracts/src/contracts/treasury/managers/RevenueManager.sol`
- `flaunchgg-contracts/test/treasury/managers/RevenueManager.t.sol`
