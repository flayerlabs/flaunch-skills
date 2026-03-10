---
name: flaunch-token-creation
description: Create a Flaunch token using the smallest path to finished state. Prefer the Web2 API fast path with image upload to IPFS, and use the SDK path when the user needs direct client-side or script control.
---

# Flaunch Token Creation Skill

Use this skill when the user wants to create a token as quickly as possible.

This is a task shortcut. Read `../../core/api/SKILL.md` for the full API surface when using the fast path, and read `../../core/sdk/SKILL.md` when the user needs the full direct-SDK launch path.

## Default path

Default to the Web2 API path because it requires fewer decisions and fewer parameters to reach a finished launch:

1. upload image to IPFS with `POST /api/v1/upload-image`
2. launch token with `POST /api/v1/{chain}/launch-memecoin`
3. poll `GET /api/v1/launch-status/{jobId}`

## Why this is the default

- lowest-parameter path
- handles image upload and IPFS handoff
- async launch queue simplifies the launch flow
- good for “just get a coin launched” tasks

## Required launch inputs

- `name`
- `symbol`
- `description`
- image source that can become `imageIpfs`
- one creator identity path if creator attribution matters

## IPFS requirement

Token creation needs image metadata:

- API fast path: upload `base64Image`, then use returned `ipfsHash` as `imageIpfs`
- SDK path: use `flaunchIPFS(...)` with `metadata.base64Image`

## When to switch to SDK instead

Use the SDK path when the user needs:

- direct wallet-controlled launch transactions
- a TypeScript app or script
- launchpad logic inside their own product
- more direct control over the launch method and result parsing

## Related source skills

- Full API guidance: `../../core/api/SKILL.md`
- Full SDK guidance: `../../core/sdk/SKILL.md`
