---
name: port-game-mode
description: Ports an existing open-source browser game into a Flaunch Game Mode with @flayerlabs/gamemode-spec and @flayerlabs/gamemode-client — rules trust boundary, coin metadata/chart/buy surfaces, launch framing (tutorial, practice lobby, round timer + end screen, leaderboard, allocation beats), QA harness, and the uploadable zip. Use when porting, retrofitting or game-mode-enabling a game repo. For building a game from scratch or changing rules in an existing Game Mode, use $build-game-mode instead.
---
<!-- vendored_from: flayerlabs/gamemode-sdk@v0.5.5 skills/port-game-mode (dashboard facts applied 2026-09-10) -->

# Port an open-source game to a Game Mode

You are turning an existing browser game into a **Game Mode**: a game attached to a token
launch on Flaunch, where playing earns a capped, time-boxed permission to buy the coin.

Written against `@flayerlabs/gamemode-*` **0.5.5** — the developer dashboard refuses builds
below `@flayerlabs/gamemode-client` 0.5.5 (it reads the version marker in the built JS).
Install in the target repo:

```bash
npm install @flayerlabs/gamemode-client @flayerlabs/gamemode-spec
npm install --save-dev @flayerlabs/gamemode-cli
```

**Read `references/AGENTS.md` in full before touching anything.** It is the contract; this
skill is the porting procedure on top of it. The two most common porting failures are (a)
trusting the client with points and (b) shipping the SDK surfaces without the *launch
framing* — a port without a tutorial, practice lobby, round timer ending in a score summary,
leaderboard and visible points→allocation is not done, no matter how good the chart looks.
`references/launch-ux.md` is that checklist and it is mandatory.

## The gates, in order

Do not proceed past a failed gate. Say plainly why the port stops.

1. **License.** The repo carries an OSI-approved permissive license: MIT, Apache-2.0,
   BSD-2/3-Clause, ISC, Zlib, or Unlicense/CC0. GPL/AGPL/LGPL, "source-available",
   no-license, and any asset pack with unclear rights are all stops. Keep `LICENSE` and
   write/extend `THIRD_PARTY_NOTICES.md` in the port.
2. **Size.** Repo ≤ 50 MB (measure the checkout without `.git` and `node_modules`).
3. **Shape.** Browser-only JS/TS, playable without a server (a dev server for bundling is
   fine). A game that needs its own authoritative server is not a port — that is
   `$run-a-game-server`. No paid APIs, no login walls.
4. **Provenance.** Before any code changes, write `port.json` at the repo root — the
   platform reads this file for attribution and compliance, and a port without it will not
   be accepted:

   ```json
   {
     "name": "<game name>",
     "upstream": {
       "repo": "https://github.com/<owner>/<repo>",
       "author": "<github owner>",
       "commit": "<hash of the commit you ported from>",
       "license": "MIT"
     },
     "portedAt": "<ISO date>",
     "sdk": "<gamemode pack version, e.g. 0.5.5>"
   }
   ```

   Fill `upstream` from the actual origin repo, never from whoever asked for the port.

## The procedure

### 1. Scout

Play the game (`npm/pnpm install && dev`). Then read the code to find:

- **The scoring seam** — the one place the game itself decides "you scored". You will hook
  exactly there, never in input handling or rendering.
- **The shape** — continuous scoring (endless runner, arcade), match-to-target (first to N),
  or turn-based rounds. This picks your rules template and window length.
- **Session length** — how long one honest play session runs. The launch window should fit
  1–2 sessions plus buying time (a 5-minute match → an 8–10 minute window).
- **The stack** — vite / webpack / plain HTML. Prefer keeping the game's own tooling; add
  vite only if there is none.

### 2. Design the economy

The game's physics run in the browser and cannot be trusted, so **the rules bound claims,
they never re-simulate**. Design three numbers and write them down before coding:

- **Dollars per scoring event** — map native scoring to allocation (`pointsPerX` in config;
  the mock's rate is 1 rules point = $1; the client reads `unitsPerPoint` off the economy
  balance rather than hardcoding it).
- **The ceiling** — `rewardBounds` derived from the game's *own* caps (a game to 11 capped
  at 15 → 15 × rate). Never invent a cap the game doesn't have; never under-declare.
- **The claim rhythm** — the minimum real time between scoring events in honest play
  (a basketball possession ≈ 4 s; a completed puzzle ≈ 20 s). That becomes the per-action
  cooldown in `decide`. A cheater with a console can claim, but never faster than the game
  can actually be played, never above the ceiling.

Award immediately when the score is public the moment it lands (a basket, a landed arrow);
defer when there is a reveal beat.

### 3. Write the rules module

Start from `templates/rules.ts` (TypeScript even in a JS repo — vite compiles it
transparently). Rules authoring — purity, `parseAction`/`decide`/`evolve`, deferred awards,
phases, wakes, `rewardBounds` — is owned by `$build-game-mode`; follow it. `npx gamemode check
src/game/rules.ts` green is a gate. Refusal codes are stable machine codes (`claim.too_fast`,
`claim.cap_reached`, `game.not_open`, `game.round_over`); player copy lives in the client.

### 4. Wire the room

Start from `templates/room.js`: `createMockRoom` running your real rules, a `replayMarket`
fixture scaled to your window length, and launch metadata. **Everything reads from
`room.launch`** — name, symbol, art — so a live launch drops in with no code change; the
mock's coin is data, not a hardcode. Support the dev URL params the template ships
(`?practice=` and `?round=` in seconds) — the QA harness depends on them.

Hook the scoring seam with a callback the game exposes (e.g. `game.onUserScore = (pts) =>
room.send({ claim: pts })`) so the game module never imports the room.

### 5. Launch framing — the mandatory checklist

Work through `references/launch-ux.md` item by item: tutorial, practice lobby, round timer
+ end screen with score summary, leaderboard (in-round standings + fixture rivals, behind
an adapter-shaped seam), "+$X allocation" beats, in-world coin branding (paint the token
art into the game world where the camera lives — `templates/coinArt.js` is the fallback
render), and buy choreography. Each item has acceptance criteria and a required `data-gm-*`
DOM contract that the QA harness asserts against. `templates/coinPanel.js` is the coin card
(metadata, chart, allocation, BUY, standings) already speaking that contract — restyle it to
the game's visual language; keep the data attributes.

### 6. QA

Run `templates/qa.mjs` (copy it into the port as `tools/qa-gamemode.mjs`, set the two
config lines at the top). It boots the game headless and asserts the full loop: tutorial on
first run, practice gating before `opensAt`, a claim awarding, a too-fast claim refusing,
chart pixels, BUY confirming with the hold line, the end screen with summary + leaderboard
at `closesAt`, zero console errors — and saves lobby / mid-round / end-screen screenshots.
**Look at the screenshots.** The harness proves the mechanics; your eyes prove the framing
reads. "It ran" is not evidence; the harness green plus reviewed screenshots is.

Also confirm the held-allowance copy: a nonzero `held` on the economy balance must
render as "reserved until…" from `holdExpiresAt`, never as a silently smaller balance.

### 7. Bundle

- `base: './'` in vite config (the zip host mounts under a content-addressed prefix).
- Zero external requests: bundle all assets; images as data/blob URLs (host CSP is
  `img-src 'self' data: blob:`). No CDN scripts, no web fonts, no analytics.
- Copy `references/AGENTS.md` into the port's root as `AGENTS.md`.
- Build, then `cd dist && zip -qr ../<name>.zip . -x "*.map"` (never ship sourcemaps). The
  platform's hard cap is 100 MB; stay well under it, and treat anything over ~20 MB as a
  prompt to check what's shipping (an asset library can justify it, sourcemaps cannot).

### 8. Ship

A port is playable from its zip alone, but **launchable only with a gate** — the round server
running this port's own rules module. The platform never provides one.

- Add `src/gate.ts` calling `startGate(rules, config)` from `@flayerlabs/gamemode-gate` (a
  `gamemode new` project already carries it, with `.env.example` and `railpack.json`; the
  environment contract is in the gate package's DEPLOY.md). Deploy it, smoke-test `GET /health`
  and `GET /config`, and note the `signer` — that is what a launch writes into its pool.
- Upload the zip at the developer dashboard, `https://flaunch.gg/game-mode/dashboard`, and
  declare **one gate per chain**: Base Sepolia (84532) is required for testing; Base (8453) and
  Robinhood (4663) are production. The hosting policy permits only gates declared there — a
  gate entered only at launch time leaves the game unable to reach any round server.
- The dashboard refuses a gate whose `GET /config` reports a `gateVersion` below 0.5.5, so
  deploy from the current SDK. Tick "supports practice mode" (step 4 makes the build run on
  `createMockRoom`) and mark it mobile-friendly if it is.
- Run the Base Sepolia test launch from the dashboard before relying on a production gate.
- Submitting without a gate is a real choice, not a mistake: the game is playable in the
  directory as a demo, and no coin can be launched through it until a gate is added.

## Acceptance

A port is done when all of these hold, and not before:

- [ ] `port.json` present with true upstream provenance; LICENSE + THIRD_PARTY_NOTICES intact
- [ ] `gamemode check` green on the rules module
- [ ] Every item in `references/launch-ux.md` checked, with its `data-gm-*` contract met
- [ ] `qa-gamemode.mjs` green; screenshots reviewed by a human (or reported for review)
- [ ] Held allowance (`held` + `holdExpiresAt`) renders as reserved, not vanished
- [ ] Zip built from relative base, no sourcemaps, ≤ 100 MB (platform cap), zero external requests
- [ ] Shipped deliberately: gate deployed, smoke-tested, declared per chain in the dashboard and
      test-launched on Base Sepolia — or the port explicitly declared a demo, with no gate

If the game genuinely cannot satisfy the interface (has no bounded scoring rhythm, can't run
headless), stop and say so explicitly — a clear "not portable because X" beats a hacked port.
