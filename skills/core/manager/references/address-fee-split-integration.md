# Address Fee Split Integration

Use this reference when the goal is direct fee routing to one or more fixed recipients.

## Best Fit

Choose `AddressFeeSplitManager` when the product wants:

- a vault or treasury to receive fees directly
- deterministic fixed-recipient splits
- simple post-launch fee routing without buyback or staking behavior

Default single-recipient setup:

- `creatorShare = 0`
- `ownerShare = 0`
- `recipientShares = [(recipientContract, 100_00000)]`

## Required Inputs

- target chain: `base` or `baseSepolia`
- recipient contract or wallet address
- whether the recipient will call `claim()` itself or receive passively after an external caller triggers claims
- expected assertion: claimed amount, recipient balance delta, or both

## Example Prompts

- Send all Flaunch fees to a single treasury contract.
- Show the `AddressFeeSplitManager` init payload for one recipient.
- Write the minimum integration test for direct fee routing.

## Reuse-First Rule

Before adding helpers or mocks, check:

- `lib/flaunchgg-contracts/src`
- `lib/flaunchgg-contracts/test`

Prefer existing Flaunch test harnesses and manager contracts over local copies.

## Integration Workflow

1. Set up the Flaunch harness.
2. Deploy the recipient contract.
3. Deploy `AddressFeeSplitManager` and approve it in `TreasuryManagerFactory`.
4. Encode `initializeData`.
5. Launch a memecoin through `FlaunchZap.flaunch(...)` with treasury manager params.
6. Capture the deployed manager address.
7. Wire that manager into the recipient contract if the recipient stores manager state.
8. Send ETH to the manager with a real transfer to simulate accounted fees.
9. Trigger the claim path.
10. Assert the claimed amount and recipient balance changes.

## Initialization Shape

```solidity
AddressFeeSplitManager.RecipientShare[] memory recipientShares =
    new AddressFeeSplitManager.RecipientShare[](1);

recipientShares[0] = AddressFeeSplitManager.RecipientShare({
    recipient: recipientContract,
    share: 100_00000
});

bytes memory initializeData = abi.encode(
    AddressFeeSplitManager.InitializeParams({
        creatorShare: 0,
        ownerShare: 0,
        recipientShares: recipientShares
    })
);
```

## Treasury Manager Params

```solidity
TreasuryManagerParams memory treasuryManagerParams = TreasuryManagerParams({
    manager: approvedManagerImplementation,
    permissions: address(0),
    initializeData: initializeData,
    depositData: ""
});
```

## Test Notes

- Fair launch is deprecated for new integrations. Use `initialTokenFairLaunch = 0` and `fairLaunchDuration = 0`.
- Do not use `vm.deal(manager, amount)` to simulate claimable fees.
- Use a real transfer instead:

```solidity
(bool ok,) = payable(manager).call{value: feeAmount}("");
assertTrue(ok);
```

## Minimum Assertions

- launched memecoin address is nonzero
- deployed manager address is nonzero
- Flaunch token NFT owner is the deployed manager
- `claim()` returns the expected nonzero value when fees accrued
- recipient balance increases by the expected amount
- repeated claim without new fees does not increase payout

## Helper

For quick single-recipient payload encoding, use `../scripts/encode-address-fee-split.sh`.

## Unsupported Fit

Do not use this path when the product requires:

- staking-based rewards
- buyback execution
- creator/protocol-only splits
- NFT-holder-based revenue routing

Route those requests back to the manager router skill.
