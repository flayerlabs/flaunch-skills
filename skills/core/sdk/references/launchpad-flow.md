# Launchpad Flow

Use this reference when building a product on top of `@flaunch/sdk`.

## Best Fit

Choose the SDK when the builder needs:

- TypeScript integration
- direct reads and writes
- wallet-controlled launch transactions
- quote, trade, liquidity, import, or watcher flows around a launch

## Required Inputs

- target chain: `base` or `baseSepolia`
- `publicClient`
- `walletClient` for write flows
- launch or trade intent
- exact Flaunch object or coin address inputs for the selected flow

## Example Prompts

- Build a launchpad flow in `@flaunch/sdk` on Base.
- Show the minimum SDK setup for a write-enabled launch flow.
- I need launch, trade, and liquidity support in one app. Is the SDK the right path?

## Unsupported Fit

Do not use this path as the default when the builder only wants the fastest backend-assisted token launch. Route that case to the Web2 API fast path.

## Execution Route

1. Confirm the target chain first.
2. Create a read-only or read-write SDK instance with `createFlaunch(...)`.
3. Verify `walletClient` and `publicClient` are on the same chain for any write flow.
4. Choose the smallest workflow that satisfies the request:
   - launch
   - manager-aware launch
   - trade
   - Permit2 sell
   - liquidity
   - import
   - events
   - calldata-only
5. Run preflight methods before writes.
6. Parse receipts or emitted results rather than stopping at transaction submission.

## Launch Checklist

- use `flaunchIPFS(...)` for the common launch path
- use `flaunchIPFSWithRevenueManager(...)` when launching directly into a revenue manager instance
- use `flaunchIPFSWithSplitManager(...)` for a static address-split launch path
- use `flaunchIPFSWithDynamicSplitManager(...)` when recipient membership or share weights must stay mutable after launch
- provide valid metadata including a base64 image
- parse the launch result with `getPoolCreatedFromTx(...)`
- if parsing is delayed, fall back to `pollPoolCreatedNow(...)`

## Manager-Aware SDK Flows

Use these when the launch should be manager-bound but the builder still wants an SDK-first TypeScript path:

- deploy revenue manager: `deployRevenueManager(...)`
- launch into a revenue manager instance: `flaunchWithRevenueManager(...)` or `flaunchIPFSWithRevenueManager(...)`
- launch with static split manager: `flaunchWithSplitManager(...)` or `flaunchIPFSWithSplitManager(...)`
- launch with dynamic split manager: `flaunchWithDynamicSplitManager(...)` or `flaunchIPFSWithDynamicSplitManager(...)`
- inspect or update dynamic split state: `ReadDynamicAddressFeeSplitManager` / `ReadWriteDynamicAddressFeeSplitManager`

High-signal distinction:

- static split manager uses recipient percentages that the SDK converts into 5-decimal shares
- dynamic split manager uses raw recipient weights and keeps those weights mutable after deployment

## Launchpad Guardrails

- do not mix Base and Base Sepolia clients
- do not create a write flow without a `walletClient`
- quote before trade or liquidity writes
- use exact SDK field names such as `coinAddress` and `slippagePercent`
- return parsed launch or swap results, not only `txHash`

## Output Requirements

A complete answer should include:

- required clients
- exact SDK methods to use
- preflight or quote step if applicable
- parsed success output
- one likely failure point for the chosen flow
