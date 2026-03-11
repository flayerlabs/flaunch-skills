# Buyback Integration

Use this reference when the treasury policy requires buyback routing.

## Best Fit

Choose `BuyBackManager` when the product explicitly requires:

- buyback execution as part of treasury policy
- creator and owner claim logic separated from buyback routing
- pool-aware routing into a supported buyback path

If the goal is only direct fee routing to a vault or treasury, use `AddressFeeSplitManager` instead.

## Required Inputs

- target chain: `base` or `baseSepolia`
- `buyBackPoolKey`
- desired `creatorShare`
- desired `ownerShare`
- expected route assertion for `routeBuyBack()`

## Example Prompts

- Integrate `BuyBackManager` on Base Sepolia.
- Show the minimum test plan for `routeBuyBack()`.
- How should I separate creator claims from buyback assertions?

## Reuse-First Rule

Before building helpers, inspect:

- `lib/flaunchgg-contracts/src`
- `lib/flaunchgg-contracts/test`

Prefer existing manager contracts, pool helpers, and harnesses.

## Integration Workflow

1. Set up the Flaunch harness and pool dependencies.
2. Deploy and approve `BuyBackManager` in `TreasuryManagerFactory`.
3. Encode `initializeData` with the chosen shares and `buyBackPoolKey`.
4. Launch the token through `FlaunchZap.flaunch(...)`.
5. Capture the deployed manager address.
6. Accrue fees with a real ETH transfer into the manager.
7. Test creator and owner claim paths separately if enabled.
8. Call `routeBuyBack()`.
9. Assert routed amount, route success, and accounting separation.

## Initialization Shape

```solidity
bytes memory initializeData = abi.encode(
    BuyBackManager.InitializeParams({
        creatorShare: 20_00000,
        ownerShare: 0,
        buyBackPoolKey: buyBackPoolKey
    })
);
```

## Minimum Assertions

- manager deployment and token launch both succeed
- manager owns the launched Flaunch NFT
- creator and owner claims behave correctly when enabled
- `routeBuyBack()` returns a nonzero routed amount after fees accrue
- buyback routing does not silently consume creator or owner balances
- invalid route configuration or unauthorized route attempts revert

## Guardrails

- validate the buyback pool before assuming it is safe
- keep buyback routing assertions separate from creator and owner claim assertions
- isolate route failures from fee-accrual failures in tests
- use a real transfer to simulate fees; do not use `vm.deal`

## Unsupported Fit

Do not choose this path if buyback is only optional or speculative. In that case:

- test direct fee routing separately first
- add buyback only if product policy truly requires it
