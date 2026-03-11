# Token Launch Flow

Use this reference for the standard Web2 API launch path.

## Best Fit

Choose the Web2 API when the builder wants:

- the fastest backend-assisted launch flow
- image upload handled through an API
- async launch jobs rather than direct wallet orchestration

Use the SDK instead when the builder needs client-side transaction control or deeper TypeScript integration.

## Supported Chains

- `base`
- `base-sepolia`

## Required Inputs

- chain route slug
- `name`
- `symbol`
- `description`
- image source that can be turned into `base64Image`
- creator identity if attribution matters

## Example Prompts

- Launch a token on Base through `flaunch-web2-api`.
- Show the exact request flow for `launch-memecoin`.
- Explain how `jobId` polling works for a Flaunch API launch.

## Unsupported Requests

This path is a poor fit when the builder needs:

- direct wallet-driven launch transactions
- frontend trade or liquidity flows
- event watchers
- low-level SDK control over launch result parsing

Route those requests to the SDK skill.

## Execution Route

1. Upload the token image to `POST /api/v1/upload-image`.
2. Save the returned `ipfsHash` and pass it as `imageIpfs`.
3. Submit the launch to `POST /api/v1/{chain}/launch-memecoin`.
4. Store the returned `jobId`.
5. Poll `GET /api/v1/launch-status/{jobId}` until terminal state.
6. Return `transactionHash`, `collectionToken`, and any manager addresses included in the result.

## Request Checklist

- validate the chain slug exactly
- include only one creator identity path unless the API explicitly supports more
- do not mix incompatible treasury-manager options in one request
- expect async semantics; submission is not final onchain success

## Output Requirements

A complete answer should include:

- the exact endpoint path
- required request fields
- the `jobId` polling loop
- terminal success fields to capture
- one failure mode and retry path

## Failure Modes

- `429` rate limiting: retry with backoff
- moderation rejection on image upload
- chain slug mismatch
- failed async job after submission

## Success Shape

Treat these as the high-signal outputs:

- `jobId` after submission
- `state` during polling
- `transactionHash` on completion
- `collectionToken` on completion
