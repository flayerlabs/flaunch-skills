# Flaunch Skills

This directory contains agent-oriented skills for building on Flaunch.

## Skill Groups

### Basic

Use these when the user wants the smallest path to a working outcome.

| Skill | Description |
|---|---|
| [token-creation](./basic/token-creation/) | Fastest path to launching a Flaunch token, usually through the Web2 API |
| [token-launchpad](./basic/token-launchpad/) | Route launchpad requests to the smallest API, SDK, manager, or wrapper path |

### Core

Use these when the request maps directly to a concrete integration surface.

| Skill | Description |
|---|---|
| [api](./core/api/) | Web2 API launches, image upload, launch polling, and manager creation |
| [sdk](./core/sdk/) | `@flaunch/sdk` reads, writes, launches, trades, liquidity, import, and watchers |
| [manager](./core/manager/) | Treasury-manager routing, integration patterns, and testing baselines |

### Advanced

Use these when the user needs contract-level customization.

| Skill | Description |
|---|---|
| [manager-builder](./advanced/manager-builder/) | Build and test manager contracts and manager-bound launch flows |
| [manager-zap-wrapper](./advanced/manager-zap-wrapper/) | Wrap launch flows with project-specific policy or manager behavior |

## Quick Routing

- Need to launch a token with the fewest decisions: use [token-creation](./basic/token-creation/)
- Need to build a launchpad product: use [token-launchpad](./basic/token-launchpad/)
- Need REST endpoints and async launch jobs: use [api](./core/api/)
- Need TypeScript client integration: use [sdk](./core/sdk/)
- Need fee routing or treasury behavior: use [manager](./core/manager/)
- Need a custom manager contract or launch wrapper: use [manager-builder](./advanced/manager-builder/) or [manager-zap-wrapper](./advanced/manager-zap-wrapper/)

## Notes

- This repo prefers small, composable skills over broad tutorial-style skills.
- Routing and guardrails live in the skill entrypoints.
- Concrete payloads, examples, and edge cases live in `references/`.
