---
name: flaunch-token-launchpad
description: Decide what kind of Flaunch launchpad to build. Use the basic path for direct SDK or API launches, and use the advanced path when the launchpad needs custom manager behavior or a wrapper zap.
---

# Flaunch Token Launchpad Skill

Use this skill when the user is building a launchpad product on top of Flaunch.

This is a task shortcut. Read `../../core/sdk/SKILL.md` for the full SDK surface, read `../../core/api/SKILL.md` for the hosted Web2 API flow, and read `../../core/manager/SKILL.md` when the launchpad needs custom treasury behavior.

## First question: what kind of launchpad is this?

Classify it before building.

### Basic launchpad

Use the basic launchpad path when the builder wants to launch tokens with existing Flaunch launch surfaces.

This can produce:

- a standard token launch flow
- a launchpad that launches through the SDK
- a launchpad that uses the Web2 API for the fastest backend-assisted flow
- a launchpad that uses existing launch methods such as direct launch, split-manager launch, or revenue-manager launch

Use:

- `../../core/sdk/SKILL.md`
- `../../core/api/SKILL.md`

### Advanced launchpad

Use the advanced launchpad path when the launchpad itself needs custom onchain launch policy.

This can produce:

- a launchpad that forces a custom treasury behavior at launch
- a launchpad that depends on a custom manager
- a launchpad that wraps `FlaunchZap` so all launches go through a project-specific policy

Use:

- `../../core/manager/SKILL.md`
- `../../advanced/manager-builder/SKILL.md`
- `../../advanced/manager-zap-wrapper/SKILL.md`

## When SDK is enough

The SDK is enough when the user wants:

- app-controlled UX
- direct reads and writes
- launch result parsing
- trade, liquidity, or import flows around the launch
- a launchpad that does not need custom manager contracts

## When the Web2 API is enough

If the user wants a simpler backend-driven launchpad with fewer parameters and no low-level transaction orchestration, use the Web2 API launch flow:

1. upload image
2. submit launch job
3. poll status

## IPFS and metadata

- SDK path: use `metadata.base64Image` with `flaunchIPFS(...)`
- API path: upload image first and pass returned `imageIpfs`

## Related skills

- fast token creation: `../token-creation/SKILL.md`
- full SDK guidance: `../../core/sdk/SKILL.md`
- full API guidance: `../../core/api/SKILL.md`
- full manager guidance: `../../core/manager/SKILL.md`
- advanced manager builder: `../../advanced/manager-builder/SKILL.md`
- advanced wrapper zap: `../../advanced/manager-zap-wrapper/SKILL.md`
