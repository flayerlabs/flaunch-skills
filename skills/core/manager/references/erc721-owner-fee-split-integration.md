# ERC721 Owner Fee Split Integration

Use this reference when fee claims should follow ERC721 ownership rather than fixed recipient addresses.

## Best Fit

Choose `ERC721OwnerFeeSplitManager` when the product wants:

- NFT-holder rewards
- collection-based fee sharing
- cross-collection allocation with separate share weights
- claim-time ownership checks against specific token IDs

This path is stronger than a static address split when recipient identity should track NFT ownership over time.

## Required Inputs

- target chain: `base` or `baseSepolia`
- collection addresses to include
- collection share weights
- `totalSupply` values for each configured collection
- creator and owner share policy
- claim payload shape for ERC721 addresses and token IDs

## Initialization Shape

```solidity
bytes memory initializeData = abi.encode(
    ERC721OwnerFeeSplitManager.InitializeParams({
        creatorShare: 20_00000,
        ownerShare: 10_00000,
        shares: shares
    })
);
```

```solidity
ERC721OwnerFeeSplitManager.ERC721Share[] memory shares =
    new ERC721OwnerFeeSplitManager.ERC721Share[](2);

shares[0] = ERC721OwnerFeeSplitManager.ERC721Share({
    erc721: address(collectionA),
    share: 60_00000,
    totalSupply: 10000
});

shares[1] = ERC721OwnerFeeSplitManager.ERC721Share({
    erc721: address(collectionB),
    share: 40_00000,
    totalSupply: 5000
});
```

## Claim Shape

Claims are driven by encoded `ClaimParams` containing collection addresses and token ID arrays.

```solidity
bytes memory claimData = abi.encode(
    ERC721OwnerFeeSplitManager.ClaimParams({
        erc721: claimCollections,
        tokenIds: claimTokenIds,
        creatorTokens: new ITreasuryManager.FlaunchToken[](0)
    })
);
```

## Integration Workflow

1. Set up the Flaunch harness.
2. Deploy mock or real ERC721 collections needed for the product flow.
3. Deploy and approve `ERC721OwnerFeeSplitManager`.
4. Encode collection shares and initialize the manager.
5. Deposit or launch the Flaunch NFT into the manager.
6. Accrue fees through the real fee path.
7. Mint or prepare ERC721 ownership for the claiming address.
8. Build `ClaimParams` and call `claim(...)`.
9. Assert per-token claimed amounts plus any creator and owner components.

## High-Signal Behaviors

The public manager tests and docs in `flaunchgg-contracts` should be treated as the source of truth when they include this manager.

- collection share totals must equal `100_00000`
- each configured collection needs a nonzero address, nonzero share, and nonzero `totalSupply`
- claim validity depends on token ownership at claim time
- claims are tracked at the ERC721 token ID level
- creator and owner allocations can coexist with NFT-holder claims

## Minimum Assertions

- initialization rejects invalid collection config
- manager stores the intended collection shares
- claim-time ownership checks reject invalid token ownership
- claimed amount for each token ID matches collection share and total supply
- repeated claims against the same token IDs do not overpay
- creator and owner balances remain separate from NFT-holder allocations

## Guardrails

- `totalSupply` is part of accounting; if configured incorrectly, distribution math will be wrong
- test at least one repeated-claim scenario on already-claimed token IDs
- test mixed claims across multiple collections if the product uses them
- do not assume address-based recipient logic; this manager is token-ID driven

## Reuse-First Rule

Before building helpers, inspect:

- `flaunchgg-contracts/src/contracts/treasury/managers/ERC721OwnerFeeSplitManager.sol`
- `flaunchgg-contracts/test/treasury/managers/ERC721OwnerFeeSplitManager.t.sol`
