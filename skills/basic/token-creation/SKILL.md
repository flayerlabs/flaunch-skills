---
name: flaunch-token-creation
description: Create a Flaunch token using the smallest path to finished state. Prefer the Web2 API fast path with image upload to IPFS, and use the SDK path when the user needs direct client-side or script control.
---

# Flaunch Token Creation Skill

Use this skill when the user wants to create a token as quickly as possible.

This is a task shortcut. Use `references/api-fast-path.md` for the default execution route. Read `../../core/api/SKILL.md` for the full API surface and `../../core/sdk/SKILL.md` when the user needs direct SDK control.

## Example Prompts

- Launch a memecoin on Base with the fewest decisions possible.
- Show me the fastest Flaunch token creation flow.
- What do I need to create a token through the API?

## Default path

Default to the Web2 API path because it requires fewer decisions and fewer parameters to reach a finished launch:

1. follow `references/api-fast-path.md`
2. switch to the SDK skill only if the user needs direct launch control

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

- API fast path: `references/api-fast-path.md`
- Full API guidance: `../../core/api/SKILL.md`
- Full SDK guidance: `../../core/sdk/SKILL.md`
