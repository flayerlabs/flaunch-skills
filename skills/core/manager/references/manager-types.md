# Manager Types

Use this reference when the user needs to choose a treasury manager or encode manager-specific initialization data.

This is a capability catalog, not a deployment-address registry. Prefer current deployment config or source-of-truth contract references when exact addresses matter.

## Share Conventions

Managers derived from `FeeSplitManager` use 5 decimal places:

- `100_00000` = 100%
- `10_00000` = 10%
- `5_00000` = 5%

`RevenueManager` is the exception. Its `protocolFee` uses 2 decimal places:

- `10_00` = 10%

## AddressFeeSplitManager

Best fit:

- fixed treasury or vault routing
- deterministic revenue sharing
- simple multi-recipient splits

Initialize shape:

```solidity
struct InitializeParams {
    uint creatorShare;
    uint ownerShare;
    RecipientShare[] recipientShares;
}

struct RecipientShare {
    address recipient;
    uint share;
}
```

Example:

```solidity
AddressFeeSplitManager.RecipientShare[] memory recipientShares =
    new AddressFeeSplitManager.RecipientShare[](2);

recipientShares[0] = AddressFeeSplitManager.RecipientShare({
    recipient: treasury,
    share: 50_00000
});

recipientShares[1] = AddressFeeSplitManager.RecipientShare({
    recipient: marketing,
    share: 50_00000
});

bytes memory initializeData = abi.encode(
    AddressFeeSplitManager.InitializeParams({
        creatorShare: 10_00000,
        ownerShare: 5_00000,
        recipientShares: recipientShares
    })
);
```

High-signal behavior:

- recipient shares are fixed at initialization
- recipient share totals must equal `100_00000`
- individual recipients can transfer their full share allocation to another address

## DynamicAddressFeeSplitManager

Best fit:

- evolving recipient membership
- changing fee weights over time
- operator-managed fee routing with optional moderator access

Initialize shape:

```solidity
struct InitializeParams {
    uint creatorShare;
    uint ownerShare;
    address moderator;
    RecipientShare[] recipientShares;
}

struct RecipientShare {
    address recipient;
    uint share;
}
```

Example:

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

bytes memory initializeData = abi.encode(
    DynamicAddressFeeSplitManager.InitializeParams({
        creatorShare: 20_00000,
        ownerShare: 0,
        moderator: moderator,
        recipientShares: recipientShares
    })
);
```

High-signal behavior:

- recipient `share` values are weights, not percentages out of `100_00000`
- the example `1` and `3` values are just a simple ratio example; they mean `1 / (1 + 3)` and `3 / (1 + 3)`
- recipients can be added, removed, and updated after initialization
- removed recipients keep already-accrued fees
- newly added recipients do not inherit historical fees
- queued fees can accrue while no recipients are active and become claimable later when recipients are added back

## StakingManager

Best fit:

- holder incentives
- staking-based fee sharing
- escrowed reward distribution

Initialize shape:

```solidity
struct InitializeParams {
    address stakingToken;
    uint minEscrowDuration;
    uint minStakeDuration;
    uint creatorShare;
    uint ownerShare;
}
```

Example:

```solidity
bytes memory initializeData = abi.encode(
    StakingManager.InitializeParams({
        stakingToken: tokenAddress,
        minEscrowDuration: 30 days,
        minStakeDuration: 7 days,
        creatorShare: 10_00000,
        ownerShare: 5_00000
    })
);
```

High-signal behavior:

1. users stake the configured ERC20
2. fees accrue proportionally to stake
3. claims depend on manager accounting, not arbitrary local balances
4. unstake timing depends on configured durations

## BuyBackManager

Best fit:

- deflationary tokenomics
- routing fees into buybacks
- price-support mechanics tied to a target pool

Initialize shape:

```solidity
struct InitializeParams {
    uint creatorShare;
    uint ownerShare;
    PoolKey buyBackPoolKey;
}
```

Example:

```solidity
bytes memory initializeData = abi.encode(
    BuyBackManager.InitializeParams({
        creatorShare: 10_00000,
        ownerShare: 0,
        buyBackPoolKey: poolKey
    })
);
```

## RevenueManager

Best fit:

- simple creator plus protocol fee splits
- external protocol monetization with minimal manager logic

Initialize shape:

```solidity
struct InitializeParams {
    address payable protocolRecipient;
    uint protocolFee;
}
```

Example:

```solidity
bytes memory initializeData = abi.encode(
    RevenueManager.InitializeParams({
        protocolRecipient: payable(protocolWallet),
        protocolFee: 10_00
    })
);
```

Important:

- this manager does not use the `FeeSplitManager` share model
- do not treat `protocolFee` as a 5-decimal percentage
- creators can claim all deposited creator tokens or an explicit subset

## ERC721OwnerFeeSplitManager

Best fit:

- NFT-holder rewards
- cross-collection fee sharing
- claim flows based on ERC721 ownership

Initialize shape:

```solidity
struct InitializeParams {
    uint creatorShare;
    uint ownerShare;
    ERC721Share[] shares;
}

struct ERC721Share {
    address erc721;
    uint share;
    uint totalSupply;
}
```

Example:

```solidity
ERC721OwnerFeeSplitManager.ERC721Share[] memory shares =
    new ERC721OwnerFeeSplitManager.ERC721Share[](2);

shares[0] = ERC721OwnerFeeSplitManager.ERC721Share({
    erc721: nftCollectionA,
    share: 60_00000,
    totalSupply: 10_000
});

shares[1] = ERC721OwnerFeeSplitManager.ERC721Share({
    erc721: nftCollectionB,
    share: 40_00000,
    totalSupply: 5_000
});
```

High-signal behavior:

- claims require ownership proof at claim time
- each collection splits its allocated share across its configured supply model
- invalid `totalSupply`, zero share, or zero collection address should be treated as invalid initialization

## Selection Guide

| Goal | Manager |
|---|---|
| fixed recipient routing | `AddressFeeSplitManager` |
| dynamic membership or adjustable share weights | `DynamicAddressFeeSplitManager` |
| staker rewards | `StakingManager` |
| automated buybacks | `BuyBackManager` |
| creator + protocol revenue split | `RevenueManager` |
| NFT-holder fee sharing | `ERC721OwnerFeeSplitManager` |

## Related References

- `address-fee-split-integration.md`
- `dynamic-address-fee-split-integration.md`
- `staking-integration.md`
- `buyback-integration.md`
- `revenue-manager-integration.md`
- `erc721-owner-fee-split-integration.md`
- `../../advanced/manager-builder/SKILL.md`
