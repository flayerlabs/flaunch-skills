---
name: flaunch-web2-api
description: Integrate the Flaunch Web2 API to upload images, queue memecoin launches, poll launch status, and create treasury managers on Base and Base Sepolia.
---

# Flaunch Web2 API Skill

Use this skill when the user is integrating with `flaunch-web2-api`.

## What this API is

This API is a backend wrapper around Flaunch flows. It adds:

- REST endpoints for launch and manager operations
- async queue processing via `jobId`
- launch status polling
- image upload, moderation, and IPFS storage
- creator identity resolution via wallet, email, Twitter, or Farcaster

It is not a replacement for full SDK flexibility. For low-level transaction orchestration, use the SDK skill instead.

## Supported chains

- Base Mainnet route slug: `base` (`8453`)
- Base Sepolia route slug: `base-sepolia` (`84532`)

## Core endpoints

- `GET /livez`
- `POST /api/v1/upload-image`
- `POST /api/v1/{chain}/launch-memecoin`
- `GET /api/v1/launch-status/{jobId}`
- `POST /api/v1/{chain}/create-revenue-manager`
- `POST /api/v1/{chain}/create-fee-split-manager`

## Fast integration workflow

1. `POST /api/v1/upload-image` with `base64Image`
2. Use returned `ipfsHash` as `imageIpfs`
3. `POST /api/v1/{chain}/launch-memecoin`
4. Save `jobId`
5. Poll `GET /api/v1/launch-status/{jobId}` until `state` is `completed` or `failed`
6. On completion, use `transactionHash` and `collectionToken`

## High-signal launch rules

- Required launch fields: `name`, `symbol`, `description`, `imageIpfs`
- Creator identity must be supplied through one identity path such as `creatorAddress`, `creatorEmail`, `creatorTwitterUsername`, or `creatorFarcasterUsername`
- Do not send conflicting manager options in one request
- Fee split recipients are validated and resolved to wallet addresses

## Manager creation notes

### Revenue manager

- Route: `POST /api/v1/{chain}/create-revenue-manager`
- high-signal inputs: recipient identity, `protocolFee` in basis points, optional owner override

### Fee split manager

- Route: `POST /api/v1/{chain}/create-fee-split-manager`
- high-signal inputs: owner identity, `recipients`, optional `creatorShare`, optional `ownerShare`, optional custom `split`
- fee split constraints:
  - max recipient limit applies
  - if any recipient has custom `split`, all must
  - total recipient splits must equal `10,000,000`
  - duplicate resolved addresses are rejected

## Async semantics

- `launch-memecoin` is queue-based and asynchronous
- a `jobId` means the launch was accepted, not completed onchain
- poll the status endpoint for final result
- failed jobs may still include submitted tx context, so instruct users to verify onchain

## Common failure modes

- `429` rate limiting: retry with backoff
- moderation errors from image checks
- route slug mismatch (`base-sepolia` here vs `baseSepolia` in SDK flows)
- assuming the schema snapshot is more current than route implementation

## Output expectations

When helping builders, include:

1. exact endpoint path
2. required request fields
3. async handling via `jobId`
4. one retry or failure pattern
5. expected success fields such as `transactionHash`, `collectionToken`, and manager addresses when relevant
