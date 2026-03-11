---
name: flaunch
description: Build with Flaunch. Use when the user wants to launch a token, build a launchpad, integrate the SDK or Web2 API, design a treasury manager, or create a manager-bound wrapper zap.
---

# Flaunch

Use this as the top-level Flaunch router skill.

This skill exists so the repository has a single install target. It should quickly route to the smallest Flaunch skill that matches the user's task.

## Route By Task

### Token creation

If the user wants the fastest path to launch a token with minimal decisions, use:

- `../skills/basic/token-creation/SKILL.md`

Default to this path for "launch a coin", "create a token", or similar requests.

### Launchpad build

If the user wants to build a launchpad and needs help choosing the right integration path, use:

- `../skills/basic/token-launchpad/SKILL.md`

Use this first when the product scope is unclear.

### Direct API integration

If the user needs a backend-driven launch flow, async job polling, image upload, or manager creation through HTTP endpoints, use:

- `../skills/core/api/SKILL.md`

### Direct SDK integration

If the user is building in TypeScript, needs direct reads/writes, trade flows, liquidity flows, import flows, or event watchers, use:

- `../skills/core/sdk/SKILL.md`

### Manager design or integration

If the user needs treasury-side behavior attached to launched tokens, use:

- `../skills/core/manager/SKILL.md`

### Advanced manager implementation

If the user needs a custom manager contract or deeper protocol behavior, use:

- `../skills/advanced/manager-builder/SKILL.md`

### Manager-bound wrapper zap

If the user needs a launch flow that forces manager defaults through a wrapper zap, use:

- `../skills/advanced/manager-zap-wrapper/SKILL.md`

## Routing Rules

- Start with the smallest skill that can finish the task.
- Use the basic skills first when the user wants speed and minimal decisions.
- Switch to the core skills when the user needs direct API, SDK, or manager details.
- Use the advanced skills only when the product requires custom treasury behavior or manager-bound launch constraints.

## Install Shape

This folder is the public install target for the repository.

After this skill is installed, it can route into the existing Flaunch skill set without requiring users to install each sub-skill individually first.
