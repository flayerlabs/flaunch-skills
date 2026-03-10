# Flaunch Skills

This repo stores the reusable Flaunch skills in one place so a developer can jump into the Flaunch ecosystem and build everything Flaunch has to offer.

## What Flaunch Infra Can Do

At a high level, Flaunch gives builders infrastructure for:

- launching tokens
- building launchpads
- routing value after launch
- attaching treasury behavior to launched tokens
- integrating trading, liquidity, imports, and app UX through the SDK
- integrating faster backend-driven launch flows through the Web2 API

Most builders come to Flaunch for one of two outcomes:

1. launch a token
2. build a launchpad

## What Flaunch Managers Are

Flaunch managers are treasury-side contracts attached to launched tokens.

At a high level, managers let a builder define how launched-token value behaves after launch, for example:

- route value to one or more recipients
- control claim behavior
- support staking-style or treasury-style flows
- support buyback-oriented behavior
- enforce project-specific post-launch value routing

Builders do not need to know every manager name to understand the model. The important distinction is:

- if you just want to launch tokens, stay on the basic path
- if you want custom treasury or revenue behavior, you are in manager territory and should use the advanced path

## Layout

The repo is organized into three groups:

- `skills/core/api`, `skills/core/sdk`, `skills/core/manager`
  - source-of-truth product-surface skills
  - these hold the core guidance for each major Flaunch integration surface
- `skills/basic`
  - the lowest-parameter paths to a finished state
  - mostly API and SDK-driven builder flows
- `skills/advanced`
  - manager-heavy or contract-heavy integrations
  - anything that depends on treasury manager internals or custom wrapper zap behavior

There is no standalone root skill file. This README is the index.

## Basic Skills

- `skills/basic/token-creation/SKILL.md`
  - Smallest path to create a token.
  - Defaults to the Web2 API fast path and includes the required IPFS/image step.
- `skills/basic/token-launchpad/SKILL.md`
  - Build a token launchpad on top of Flaunch.
  - Decides whether the builder needs a basic launchpad or an advanced launchpad.

## Advanced Skills

- `skills/advanced/manager-builder/SKILL.md`
  - Treasury manager integration skill for Flaunch contracts.
  - Covers manager selection, `initializeData` / `depositData`, custody, claims, buybacks, and test invariants.
- `skills/advanced/manager-zap-wrapper/SKILL.md`
  - Focused skill for custom manager wrapper zaps.
  - Covers forcing manager defaults through `FlaunchZap`, binding launches to the intended manager, and the required test coverage.

## How To Use It

Pick the smallest skill that matches the task:

- core Web2 API surface -> `skills/core/api/SKILL.md`
- core SDK surface -> `skills/core/sdk/SKILL.md`
- core manager surface -> `skills/core/manager/SKILL.md`
- fastest token launch with minimal params -> `skills/basic/token-creation/SKILL.md`
- deciding what kind of launchpad to build -> `skills/basic/token-launchpad/SKILL.md`
- treasury manager building or review -> `skills/advanced/manager-builder/SKILL.md`
- project-specific wrapper zap around a manager -> `skills/advanced/manager-zap-wrapper/SKILL.md`

## Source Mapping

These skills are derived from the existing Flaunch repos:

- SDK source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-sdk`
- Contracts manager source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-contracts`
- Web2 API source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-web2-api`
