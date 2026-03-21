# Dynamic Address Fee Split Integration

Use this reference when fee recipients need to change over time without breaking accrued balances.

## Best Fit

Choose `DynamicAddressFeeSplitManager` when the product wants:

- recipient add, remove, or weight updates after initialization
- accrued fees preserved for removed recipients
- new recipients to earn only from the point they become active
- optional delegated recipient management through a `moderator`

Use `AddressFeeSplitManager` instead when the recipient set is intentionally fixed and immutable.

## Required Inputs

- target chain: `base` or `baseSepolia`
- initial recipient list, if any
- share weights for active recipients
- optional `moderator` address
- creator and owner share policy
- expected behavior when recipients are removed, re-added, or updated

## Example Prompts

- Integrate `DynamicAddressFeeSplitManager` for a changing set of fee recipients.
- Show the init payload and update flow for dynamic fee weights.
- What invariants matter when removing and re-adding recipients?

## Initialization Shape

```solidity
bytes memory initializeData = abi.encode(
    DynamicAddressFeeSplitManager.InitializeParams({
        creatorShare: 20_00000,
        ownerShare: 0,
        moderator: moderator,
        recipientShares: recipientShares
    })
);
```

Recipient share entries are weights, not fixed percentages of `100_00000`.
There is no implied special max in the example below. The only thing that matters is the ratio between active recipients.

```solidity
DynamicAddressFeeSplitManager.RecipientShare[] memory recipientShares =
    new DynamicAddressFeeSplitManager.RecipientShare[](2);

recipientShares[0] = DynamicAddressFeeSplitManager.RecipientShare({
    recipient: treasury,
    share: 1
});

recipientShares[1] = DynamicAddressFeeSplitManager.RecipientShare({
    recipient: ops,
    share: 3
});
```

In that example, `treasury` gets `1 / (1 + 3)` = 25% and `ops` gets `3 / (1 + 3)` = 75% while both are active.

## Integration Workflow

1. Set up the Flaunch harness.
2. Deploy and approve `DynamicAddressFeeSplitManager`.
3. Encode `initializeData`, including `moderator` if the product needs delegated share updates.
4. Launch through `FlaunchZap.flaunch(...)` or deposit after deployment.
5. Accrue fees through a real ETH transfer or the fee-escrow path used by the harness.
6. Update recipients through `updateRecipients(...)`.
7. Claim from recipient, creator, and owner contexts separately if those paths are enabled.
8. Assert that historical accrual and new accrual are separated correctly across membership changes.

## High-Signal Behaviors

The test suite in `flaunch-contracts` establishes these behaviors:

- new recipients do not earn past fees
- removed recipients keep already-accrued fees
- removed recipients do not earn new fees after removal
- re-added recipients keep their frozen unclaimed balance
- fees accrued while no recipients are active remain queued and can become claimable once recipients become active again
- recipient share transfer migrates both active share weight and unclaimed balance
- creator claims can be limited to an explicit subset of creator tokens

## Recipient Updates

Use `updateRecipients(...)` for add, update, and remove flows:

- `share > 0` and recipient inactive: add
- `share > 0` and recipient active: update weight
- `share == 0`: remove

```solidity
DynamicAddressFeeSplitManager.RecipientShare[] memory updates =
    new DynamicAddressFeeSplitManager.RecipientShare[](2);

updates[0] = DynamicAddressFeeSplitManager.RecipientShare({
    recipient: alice,
    share: 200
});

updates[1] = DynamicAddressFeeSplitManager.RecipientShare({
    recipient: bob,
    share: 0
});

dynamicManager.updateRecipients(updates);
```

## Minimum Assertions

- manager deployment and token escrow succeed
- `totalActiveShares` reflects the live active set
- adding a recipient does not allocate historical fees to them
- removing a recipient preserves their snapshot claim balance
- updating a share preserves already-accrued fees
- claiming by one recipient does not alter another recipient's balance
- `moderator` can update recipients when configured, and non-authorized callers cannot
- share transfer moves both live share weight and unclaimed balance

## Guardrails

- do not treat recipient shares as percentages or assume `100_00000` is a target total; these values are relative weights
- test add, remove, update, and re-add separately
- explicitly test the no-active-recipients case if the product may temporarily remove everyone
- if creator share is enabled, test recipient-share claims and creator claims independently

## Reuse-First Rule

Before creating helpers, inspect the public `flaunchgg-contracts` manager docs and tests when they include this manager.
