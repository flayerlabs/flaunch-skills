---
name: flaunch-web2-api
description: Integrate the Flaunch Web2 API to upload images, queue memecoin launches, poll launch status, and create treasury managers on Base and Base Sepolia.
---

# Flaunch Web2 API Skill

Use this skill when the user is integrating with `flaunch-web2-api`.

## What This API Is

This API is a backend wrapper around Flaunch flows. It adds:

- REST endpoints for launch/manager operations
- async queue processing (`jobId`)
- launch status polling
- image upload + moderation + IPFS storage
- creator identity resolution (wallet/email/twitter/farcaster)

It is not a replacement for full SDK flexibility. For low-level transaction orchestration, use the SDK skill.

## Supported Chains

- Base Mainnet route slug: `base` (chainId `8453`)
- Base Sepolia route slug: `base-sepolia` (chainId `84532`)

## Core Endpoints

- `GET /livez`
- `POST /api/v1/upload-image`
- `POST /api/v1/{chain}/launch-memecoin`
- `GET /api/v1/launch-status/{jobId}`
- `POST /api/v1/{chain}/create-revenue-manager`
- `POST /api/v1/{chain}/create-fee-split-manager`

## Fast Integration Workflow

1. `POST /api/v1/upload-image` with `base64Image`
2. Use returned `ipfsHash` as `imageIpfs`
3. `POST /api/v1/{chain}/launch-memecoin`
4. Save `jobId`
5. Poll `GET /api/v1/launch-status/{jobId}` until `state` is `completed` or `failed`
6. On completion, use `transactionHash` and `collectionToken`

## Launch Request Essentials

Required fields:

- `name`
- `symbol`
- `description`
- `imageIpfs`

Creator identity options (pick one):

- `creatorAddress`
- `creatorEmail`
- `creatorTwitterUsername`
- `creatorFarcasterUsername`

Treasury options:

- Do not send conflicting manager options in one request.
- Fee split recipients are validated and resolved to wallet addresses.

## Manager Workflows

### Create Revenue Manager

Route:

- `POST /api/v1/{chain}/create-revenue-manager`

High-signal inputs:

- recipient identity (wallet/email/twitter/farcaster)
- `protocolFee` in basis points (`0` to `10000`)
- optional owner override

### Create Fee Split Manager

Route:

- `POST /api/v1/{chain}/create-fee-split-manager`

High-signal inputs:

- owner identity (wallet/email/twitter/farcaster)
- `recipients` array (wallet/email/twitter/farcaster entries)
- optional `creatorShare` / `ownerShare`
- optional custom recipient `split` values

Fee split constraints:

- max recipients limit applies
- if any recipient has custom `split`, all must
- total recipient splits must equal `10,000,000` (100.00000%)
- duplicate resolved addresses are rejected

## Async Job Semantics (Important)

- Launch is queue-based and asynchronous.
- `launch-memecoin` returns quickly with `jobId`; it does not mean onchain completion.
- Poll status endpoint for final result.
- Failed jobs may still include submitted tx hash context; instruct users to verify onchain.

## Error and Retry Guidance

- Common error envelope: `{ success: false, error: "..." }`
- Expect `429` rate-limiting; implement retry with backoff
- Moderation errors can include detailed NSFW payloads
- Route slug mismatch is common (`base-sepolia` vs SDK `baseSepolia`)

## Do / Don't

Do:

- Store and track `jobId`
- Poll until terminal state
- Validate chain slug explicitly
- Surface `transactionHash` and status to users

Don't:

- Assume synchronous launch completion
- Mix incompatible manager options in one request
- Assume schema file is always up-to-date with route implementation

## Output Expectations

When helping builders, include:

1. exact endpoint path
2. required request fields
3. async status handling using `jobId`
4. one error/retry pattern (`429`, validation, failed job)
5. expected success response fields (`transactionHash`, `collectionToken`, manager addresses when applicable)

## Related Skill

- SDK skill: `../sdk/SKILL.md`
