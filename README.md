# Flaunch Skills

This repository contains the reusable skill files for developers building with Flaunch.

Flaunch supports two primary outcomes:

- launch a token
- build a launchpad

Those outcomes can be delivered through a lightweight integration path or through deeper protocol customization, depending on how much control the product needs over launch flow, treasury behavior, and post-launch value routing.

## What Flaunch Provides

Flaunch infrastructure supports:

- token creation and launch flows
- launchpad development on top of the SDK and API
- trading, liquidity, imports, and app-side integration through the SDK
- backend-driven launch flows through the Web2 API
- treasury behavior attached to launched tokens through managers
- project-specific launch flows through manager-aware wrapper zaps

## What Managers Do

Flaunch managers are treasury-side contracts attached to launched tokens. They define what happens to value after launch.

Managers can be used to:

- route value to one or more recipients
- control claim and payout behavior
- support revenue, staking, or buyback-style flows
- enforce project-specific treasury behavior after launch

If a product only needs token launch and standard launchpad behavior, the basic path is usually enough. If it needs custom treasury behavior or project-specific launch constraints, it belongs on the advanced path.

## Repository Layout

This repository is organized into three groups:

| Path | Purpose | Use when... |
|------|---------|-------------|
| `skills/core` | Source-of-truth skills for the API, SDK, and manager surfaces. | You need full guidance for a specific Flaunch integration surface. |
| `skills/basic` | Task-focused shortcuts for the fastest path to a finished build. | You want to launch tokens or build a standard launchpad with minimal decisions. |
| `skills/advanced` | Task-focused skills for custom contract behavior. | You need custom managers, wrapper zaps, or deeper protocol control. |

This README is the index. There is no standalone root skill file.

## Skill Index

### Core

| File | Purpose | Read when... |
|------|---------|--------------|
| `skills/core/api/SKILL.md` | Source-of-truth Web2 API skill. | You are building with backend-driven launch flows or need the API surface directly. |
| `skills/core/sdk/SKILL.md` | Source-of-truth SDK skill. | You are building an app, launchpad, or integration on top of the SDK. |
| `skills/core/manager/SKILL.md` | Source-of-truth manager skill. | You are building or reviewing treasury manager integrations and related contract behavior. |

### Basic

| File | Purpose | Read when... |
|------|---------|--------------|
| `skills/basic/token-creation/SKILL.md` | Fastest path to create a token. | You want the smallest set of steps and parameters to get a token launched, including the required image/IPFS flow. |
| `skills/basic/token-launchpad/SKILL.md` | Launchpad decision skill. | You want to build a launchpad and need to determine whether a standard SDK/API build is sufficient or whether the product requires the advanced path. |

### Advanced

| File | Purpose | Read when... |
|------|---------|--------------|
| `skills/advanced/manager-builder/SKILL.md` | Custom treasury manager build skill. | You need to design, integrate, or test manager-driven treasury behavior. |
| `skills/advanced/manager-zap-wrapper/SKILL.md` | Custom wrapper zap skill for manager-based launches. | You need a launch flow that forces manager defaults through `FlaunchZap` or binds launches to a project-specific manager path. |

## Build Paths

### Basic Path

Use the basic path when the goal is to:

- launch a token with minimal parameters
- build a standard launchpad on top of the existing API or SDK surfaces
- ship quickly without custom treasury contracts

This path typically produces:

- a launched token
- a standard launchpad experience
- app integrations for trading, liquidity, and related token flows

### Advanced Path

Use the advanced path when the product needs:

- custom treasury or revenue behavior after launch
- buyback, staking, or project-specific payout logic
- manager-bound launch flows
- wrapper zaps that enforce manager defaults during launch

This path typically produces:

- a custom manager integration
- a launchpad with project-specific treasury behavior
- a launch flow that cannot be expressed through the standard API or SDK path alone

## How To Use This Repository

Start with the smallest skill that matches the task:

- token creation with minimal inputs: `skills/basic/token-creation/SKILL.md`
- launchpad scoping and build-path selection: `skills/basic/token-launchpad/SKILL.md`
- direct API integration: `skills/core/api/SKILL.md`
- direct SDK integration: `skills/core/sdk/SKILL.md`
- manager design or integration: `skills/core/manager/SKILL.md`
- advanced manager implementation: `skills/advanced/manager-builder/SKILL.md`
- advanced wrapper zap implementation: `skills/advanced/manager-zap-wrapper/SKILL.md`

## Source Repositories

These skills are derived from the current Flaunch codebases:

- SDK source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-sdk`
- contracts source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-contracts`
- Web2 API source: `/Users/raphaelnembhard/Projects/flayerlabs/flaunch-web2-api`
