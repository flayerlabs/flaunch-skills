# Staking Integration

Use this reference when fees should accrue to stakers rather than fixed recipients.

## Best Fit

Choose `StakingManager` when the product wants:

- ERC-20 staking rewards
- optional creator or owner shares alongside staking rewards
- explicit stake, accrue, and claim behavior

## Required Inputs

- target chain: `base` or `baseSepolia`
- staking token address
- minimum escrow duration
- minimum stake duration
- creator and owner share policy
- expected staker claim assertions

## Example Prompts

- Integrate `StakingManager` with one happy-path and one revert-path test.
- Show the init payload for a staking-based fee manager.
- What assertions matter for stake, accrue, and claim?

## Reuse-First Rule

Before creating local scaffolding, search:

- `lib/flaunchgg-contracts/src`
- `lib/flaunchgg-contracts/test`

Prefer Flaunch harnesses and staking manager tests over fresh mocks.

## Integration Workflow

1. Set up the Flaunch harness.
2. Deploy or configure the staking token and staking participants.
3. Deploy and approve `StakingManager`.
4. Encode `initializeData`.
5. Launch the memecoin with treasury manager params.
6. Capture the deployed manager address.
7. Stake tokens into the manager.
8. Accrue fees through a real ETH transfer.
9. Trigger claim paths from staker, creator, and owner contexts as needed.
10. Assert rewards and timing restrictions.

## Initialization Shape

```solidity
bytes memory initializeData = abi.encode(
    StakingManager.InitializeParams({
        stakingToken: address(stakingToken),
        minEscrowDuration: 30 days,
        minStakeDuration: 7 days,
        creatorShare: 10_00000,
        ownerShare: 0
    })
);
```

## Minimum Assertions

- launch succeeds and manager owns the launched NFT
- staking succeeds with the intended token
- staker rewards accrue after fees arrive
- claim paths return expected nonzero amounts after accrual
- pre-maturity unstake or claim restrictions revert when expected
- repeated claim without new accrual does not increase payout

## Guardrails

- timing boundaries are part of the feature, not optional tests
- keep staker accounting separate from creator and owner accounting
- confirm reward entitlement changes only through intended stake and fee events
- use real ETH transfers to simulate manager-accounted fees

## Unsupported Fit

Do not use this path when the product only needs direct treasury routing or buyback execution. Route those requests to the appropriate manager reference.
