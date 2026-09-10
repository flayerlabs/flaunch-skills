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

### Game Mode

Use these when the product is a game attached to a token launch. They are vendored from [flayerlabs/gamemode-sdk](https://github.com/flayerlabs/gamemode-sdk) at a tag; `integrate-game-mode-platform` stays in the SDK because it is for platform owners, not game developers.

| Skill | Description |
|---|---|
| [build-game-mode](./advanced/build-game-mode/) | Build a Game Mode from scratch or change the rules of an existing one |
| [port-game-mode](./advanced/port-game-mode/) | Port an existing open-source browser game into a Game Mode, through to the dashboard upload |
| [run-a-game-server](./advanced/run-a-game-server/) | Connect a game's own authoritative multiplayer server to its gate, `/config`, join tickets and submission |

## Quick Routing

- Need to launch a token with the fewest decisions: use [token-creation](./basic/token-creation/)
- Need to build a launchpad product: use [token-launchpad](./basic/token-launchpad/)
- Need REST endpoints and async launch jobs: use [api](./core/api/)
- Need TypeScript client integration: use [sdk](./core/sdk/)
- Need fee routing or treasury behavior: use [manager](./core/manager/)
- Need a custom manager contract or launch wrapper: use [manager-builder](./advanced/manager-builder/) or [manager-zap-wrapper](./advanced/manager-zap-wrapper/)
- Need to build, port or serve a game attached to a launch: use [build-game-mode](./advanced/build-game-mode/), [port-game-mode](./advanced/port-game-mode/) or [run-a-game-server](./advanced/run-a-game-server/)

## Notes

- This repo prefers small, composable skills over broad tutorial-style skills.
- Routing and guardrails live in the skill entrypoints.
- Concrete payloads, examples, and edge cases live in `references/`.

## Syncing the Game Mode skills

The Game Mode skills carry a `vendored_from:` line naming the `gamemode-sdk` tag they came from. To pick up a new SDK release:

    scripts/sync-gamemode-skills.sh /path/to/gamemode-sdk v0.5.6

It copies `.agents/skills/{build-game-mode,run-a-game-server}` (and `skills/port-game-mode` while the SDK still ships it) into `skills/advanced/`, rewrites the provenance line, and prints a reminder to re-apply the flaunch-skills-only edits shown by `git diff`.
