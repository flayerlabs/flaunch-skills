# Path Selection

Use this reference to choose the right launchpad build path before writing code.

## Decision Rule

Ask one question first:

Does the launchpad need custom treasury behavior at launch?

- If no, use the basic path.
- If yes, use the advanced path.

## Example Prompts

- My launchpad just needs standard launches and trading. Which Flaunch path fits?
- I need every launch to bind a treasury manager. Is this an advanced path?
- Help me choose between the API, SDK, and manager routes for a launchpad.

## Basic Path

Choose this when the launchpad wants:

- standard token launches
- SDK-controlled app UX
- Web2 API-assisted backend flow
- no custom treasury contract work

Route to:

- `../../core/sdk/SKILL.md`
- `../../core/api/SKILL.md`

## Advanced Path

Choose this when the launchpad wants:

- a custom manager
- forced treasury defaults at launch
- a wrapper zap around `FlaunchZap`
- project-specific fee, staking, or buyback behavior

Route to:

- `../../core/manager/SKILL.md`
- `../../advanced/manager-builder/SKILL.md`
- `../../advanced/manager-zap-wrapper/SKILL.md`

## Quick Heuristics

Use the Web2 API when:

- speed matters most
- backend-assisted launch is acceptable
- async job polling is acceptable

Use the SDK when:

- the app needs direct launch control
- the product also needs trade, liquidity, import, or event flows

Use advanced manager paths when:

- the launch itself must enforce treasury policy
- post-launch value routing is part of the product, not an add-on
