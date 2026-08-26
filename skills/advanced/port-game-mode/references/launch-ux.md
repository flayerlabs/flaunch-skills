# Launch framing — the mandatory checklist

The SDK surfaces (metadata, chart, buy) are the mechanical half of a port. This checklist is
the half that makes it a *launch*. Every item is required; the QA harness asserts the
`data-gm-*` contract, and a human reviews the screenshots for the rest.

**Corner inventory first:** before parking the coin card, list what the game's own HUD
already owns (roadbooks, minimaps, debug readouts live in corners too). A port that covers
the game's instruments reads as broken; move the card, or retire the instrument it replaces.

**The DOM contract:** each item names required `data-gm-*` attributes. Put them on whatever
elements your design uses — the harness queries attributes, not classes or structure, so the
visual language stays yours. All coin-panel attributes (`data-ticker`, `data-alloc`,
`data-buy`, `data-chart`, `data-hold`, `data-feed`, `data-mcap`, `data-window`) come free
with `templates/coinPanel.js`.

---

## 1. Tutorial

First-run cards (2–4) covering, in this order: the game's loop in its own words, **the
economy sentence with real numbers** ("every basket is $20 of allocation in the $SWISH
launch — the right to buy early, not tokens"), and the BUY beat ("hit BUY before the window
closes"). Persisted (`localStorage`) so it runs once; reopenable from a small button.

- Contract: `data-gm-tutorial` on the card container (visible on a first run,
  i.e. when the persistence key is absent); `data-gm-tutorial-next` on the advance button.
- Accept: a first-time player who reads the cards can say what earns money and when to buy.

## 2. Practice lobby

`opensAt` sits in the future (default 30–60 s; dev param `?practice=` overrides). Play
before it **works** but is framed PRACTICE: score visibly doesn't count, a countdown runs to
tip-off/opening, and the moment it opens is announced. The rules already refuse early claims
(`game.not_open`) — the client's job is to frame the wait so the refusal copy is never the
player's first hint.

**The open is a restart, not a continuation.** A player mid-action when the round opens must
not simply keep going with the counter switched on — at `opensAt` reset the play space to a
clean start state (back to the start line / a fresh board / a standstill grid, rivals
included) and run a short 3-2-1-GO countdown beat into it. Practice progress visibly does not
carry over; the round begins the way the game's own matches begin.

- Contract: `data-gm-practice` on the practice indicator (present before `opensAt`, gone
  after); `data-gm-tipoff` on the countdown element; `data-gm-go` on the 3-2-1-GO beat.
- Accept: before `opensAt` the player sees PRACTICE + countdown; at `opensAt` the game
  resets to its start state and a GO beat launches the round — never a silent continuation.

## 3. Round timer + end screen

A persistent countdown to `closesAt` (mm:ss, in or beside the game's own scoreboard), a
warning beat in the final 30 seconds, and a **hard stop into an end screen** at `closesAt`
(or the game's natural end, whichever comes first — but the end screen always appears by
`closesAt`): final score, allocation earned in dollars, the leaderboard, and a BUY last
call while the books are open.

- Contract: `data-gm-timer` on the countdown; `data-gm-endscreen` on the end screen
  (absent mid-round, present after `closesAt`); `data-gm-summary` on the score/allocation
  summary inside it.
- Accept: at any moment the player can see how long is left; the round *ends somewhere*,
  and that somewhere sells the spend.

## 4. Leaderboard

The launch is a live multiplayer experience across rooms even when this room is solo. Ship
a live standings panel during play and a full leaderboard on the end screen. In-room data
comes from the rules' `publicView.standings`; the racing feel comes from **fixture rivals**
until real cross-room feeds exist (named rivals whose scores tick up on a timer and land in
the feed — see `patterns.md`). Render standings through one function/adapter seam
(`renderStandings(entries)`) so a real cross-room feed drops in without a rewrite.

- Contract: `data-gm-standings` on the live panel; `data-gm-lb` on the end-screen
  leaderboard; the player's own row marked `data-gm-you`.
- Accept: mid-round the player can see their rank move; the end screen ranks everyone.

## 5. Allocation legibility

Every counted scoring event surfaces **"+$X allocation" at the moment it lands** — a
centre-screen or near-score beat plus a feed line, not only a number changing in a corner
panel. A refused claim surfaces its player copy the same way (see `patterns.md` for the
refusal-copy map). The coin panel shows available vs held ("you hold $X of $TICKER").

- Contract: `data-gm-award` on the transient award beat element.
- Accept: score something while looking at the action, and you still know what it paid.

## 6. In-world branding

The launch token's art lives **inside the game world**, somewhere the camera actually
dwells — court floor, sails, billboards, the ball, the background. Read `imageUrl` from
`room.launch` (arrives as a data/blob URL on live launches); when it is null or fails to
load, brand with the procedural coin render (`templates/coinArt.js`) so the world is never
unbranded. Re-dress if launch facts resolve late (`room.launch.subscribe`).

- Contract: none the harness can see — this one is screenshot review only.
- Accept: a mid-round screenshot shows the coin without the HUD.

## 7. Input parity — phones exist

A coin launch page gets phone traffic, so decide the port's device story EXPLICITLY. Either
ship touch controls — a drive stick on one half of the screen writing ANALOG values past the
game's key-ramp shaping, camera drag on the other half, input-conditional tutorial copy — or
declare desktop-only visibly in the game (a copy line at boot), never silently broken. If
touch ships: re-check every HUD corner at phone sizes (the coin card, the speedo and the
stick all fight for the same corners), and verify with emulated touch that a drag actually
drives — pointer-type gates and key-ramp overrides are exactly where it breaks quietly.

- Contract: none new — the existing `data-gm-*` elements must remain visible and
  non-overlapping at 390 px-class viewports when touch controls are on.
- Accept: an emulated-phone run can drive, steer, look around, read the timer and BUY.

## 8. Buy choreography

BUY is sprung at a beat — a reveal, the end screen, a last call — and warned before it
opens a wallet. Render `signing`/`pending` as a visible status, never a blocking modal;
render a declined buy's held allowance as "reserved until…" from the balance's `heldWei` +
`holdExpiresAt`; keep the button single-flight (a second buy while one is in the wallet is
refused with `try-again`).

- Contract: `data-buy` (from the coin panel) and `data-hold` for the confirmed/held line.
- Accept: a buy confirms into "you hold $X"; a nonzero `heldWei` reads as "reserved until…",
  never as a vanished balance.
