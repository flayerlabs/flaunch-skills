---
name: flaunch-sdk
description: Integrate @flaunch/sdk in TypeScript apps to read protocol data, launch coins, trade, manage Permit2 approvals, add liquidity, import tokens, and monitor events on Base and Base Sepolia.
---

# Flaunch SDK Skill

Use this skill when the user needs to build, debug, or review app code using `@flaunch/sdk`.

## What the SDK is for

`@flaunch/sdk` is the TypeScript integration layer for Flaunch + Uniswap V4 interactions. It helps builders:

- launch memecoins
- buy and sell memecoins
- read coin, pool, and fair launch data
- use Permit2 for sell flows
- build liquidity and import calls
- watch and parse protocol events
- build calldata for external executors or smart accounts

## Supported chains

- Base Mainnet (`base`) `8453`
- Base Sepolia (`baseSepolia`) `84532`

Always confirm chain before reads and writes.

## Core SDK model

- Read-only SDK requires `publicClient`
- Write-capable SDK requires both `publicClient` and `walletClient`
- `createFlaunch({ publicClient })` -> read workflows
- `createFlaunch({ publicClient, walletClient })` -> read + write workflows

## Task router

| User intent | Minimum inputs | Primary methods |
|---|---|---|
| Read coin metadata / info | `chain`, `publicClient`, `coinAddress` | `createFlaunch`, `getCoinMetadata`, `getCoinInfo` |
| Launch a coin | `chain`, `publicClient`, `walletClient`, launch params, metadata | `flaunchIPFS`, `getPoolCreatedFromTx` |
| Buy a coin | clients, `coinAddress`, amount, slippage | `getBuyQuoteExactInput/Output`, `buyCoin`, `parseSwapTx` |
| Sell a coin | clients, `coinAddress`, `amountIn`, slippage | `getSellQuoteExactInput`, `sellCoin`, `parseSwapTx` |
| Sell with Permit2 | above + permit signature data | `getPermit2TypedData`, `getPermit2AllowanceAndNonce`, `sellCoin` |
| Add liquidity | clients, `coinAddress`, liquidity params | `calculateAddLiquidity*`, `getAddLiquidityCalls` |
| Import token | clients, `coinAddress`, import params | `tokenImporterVerifyMemecoin`, `isMemecoinImported`, `importMemecoin` |
| Import + add liquidity batch | import params + liquidity params | `getImportAndAddLiquidityCalls` |
| Watch launch/swap events | active SDK instance, callback | `watchPoolCreated`, `watchPoolSwap`, `pollPool*Now` |
| Build calldata only | call params | `createFlaunchCalldata`, call-build helpers |

## High-signal rules

- Quote before write for trade and liquidity flows.
- `buyCoin` and `sellCoin` use `slippagePercent`, not `slippageBps`.
- Return parsed outcomes like `memecoin`, `tokenId`, or parsed swap logs, not only `txHash`.
- `sellCoin(...)` Permit2 flow expects both `permitSingle` and `signature`.
- `importMemecoin(...)` takes `coinAddress`, not `memecoin`.
- Include unsubscribe cleanup in watcher examples.

## Common failure modes

- chain mismatch between `publicClient` and `walletClient`
- using Base when the token is on Base Sepolia
- skipping quote/preflight before write
- invalid metadata image encoding for `flaunchIPFS`
- wrong field names such as `coin` instead of `coinAddress`
- Permit2 allowance or nonce not prepared before signing

## Output expectations

When helping builders, include:

1. prerequisites (`chain`, clients, env vars, addresses)
2. minimal working code snippet
3. verification step (read result or parsed event/receipt)
4. common failure mode and fix
5. optional next step (Permit2, liquidity, watchers, calldata mode)
