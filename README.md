# Flaunch Skills

For a single install target, install the top-level `flaunch` skill from this repository.

Example:

```bash
npx skills add https://github.com/flayerlabs/flaunch-skills --skill flaunch
```

That installs the umbrella router skill at `flaunch/SKILL.md`, which then directs Codex or compatible skill systems to the right deeper Flaunch skill for the task.

If the installer only supports direct folder URLs, use the `flaunch/` folder rather than the repository root.

Flaunch supports two primary outcomes:

- Launch a token
- Build a launchpad

Those outcomes can be delivered through a lightweight integration path or through deeper protocol customization, depending on how much control the product needs over launch flow, treasury behavior, and post-launch value routing.

## What Flaunch Provides

Flaunch infrastructure supports:

- Token creation and launch flows
- Launchpad development on top of the SDK and API
- Trading, liquidity, imports, and app-side integration through the SDK
- Backend-driven launch flows through the Web2 API
- Treasury behavior attached to launched tokens through managers
- Project-specific launch flows through manager-aware wrapper zaps

## Build Paths

### Basic Path

Use the basic path when the goal is to:

- Launch a token with minimal parameters
- Build a standard launchpad on top of the existing API or SDK surfaces
- Ship quickly without custom treasury contracts

This path typically produces:

- A launched token
- A standard launchpad experience
- App integrations for trading, liquidity, and related token flows

### Advanced Path

Use the advanced path when the product needs:

- Custom treasury or revenue behavior after launch
- Buyback, staking, or project-specific payout logic
- Manager-bound launch flows
- Wrapper zaps that enforce manager defaults during launch

This path typically produces:

- A custom manager integration
- A launchpad with project-specific treasury behavior
- A launch flow that cannot be expressed through the standard API or SDK path alone

## What Managers Do

Flaunch managers are treasury-side contracts attached to launched tokens. They define what happens to value after launch.

Managers can be used to:

- Route value to one or more recipients
- Control claim and payout behavior
- Support revenue, staking, or buyback-style flows
- Enforce project-specific treasury behavior after launch

If a product only needs token launch and standard launchpad behavior, the basic path is usually enough. If it needs custom treasury behavior or project-specific launch constraints, it belongs on the advanced path.

## How To Use This Repository

### Direct Skill Install

Start with the smallest skill that matches the task:

- Token creation with minimal inputs: `skills/basic/token-creation/SKILL.md`
- Launchpad scoping and build-path selection: `skills/basic/token-launchpad/SKILL.md`
- Direct API integration: `skills/core/api/SKILL.md`
- Direct SDK integration: `skills/core/sdk/SKILL.md`
- Manager design or integration: `skills/core/manager/SKILL.md`
- Advanced manager implementation: `skills/advanced/manager-builder/SKILL.md`
- Advanced wrapper zap implementation: `skills/advanced/manager-zap-wrapper/SKILL.md`

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

## Source Repositories

These skills are derived from the current Flaunch codebases:

- `flaunch-sdk`
- `flaunch-contracts`
- `flaunch-web2-api`
