---
name: run-a-game-server
description: Connects a game with its own authoritative multiplayer server to Flaunch Game Mode with @flayerlabs/gamemode-gate. Use when a game runs its own realtime server or region fleet (custom netcode, Colyseus, Socket.IO, raw WebSockets) and needs the gate, /config, join tickets, awards and the platform submission to line up. Do not use for rules-based games with no server — $build-game-mode covers those.
---

# Run a game server behind a Game Mode gate

You have a game whose gameplay lives on your own server. The platform never hosts or relays your
realtime traffic: you run the server and the gate, and the platform gives your hosted game a strict
policy that only reaches what you declared. This skill exists because that declaration lives in
three places that must agree, and because the launch form refuses a gate that does not announce
itself. Work through the sections in order; each ends with a check you can run.

## Know the three services and who hosts them

1. Your game bundle: static files you zip and submit. The platform hosts these on Moongate and
   serves them from `https://<deploy-id>.games.moongate.com`. The deploy id is derived from the
   bundle's content, so every re-upload changes the hostname. Never hardcode it; never expect it
   to be stable.
2. Your gate: one process you deploy (`createGameServerGate()` from `@flayerlabs/gamemode-gate`).
   It owns wallet sessions, the points ledger, spend authorisations and settlement. One process
   serves one chain.
3. Your game server(s): your realtime processes, up to four public HTTPS origins. Gameplay,
   scoring decisions and anti-abuse are yours; points move only through the gate's award route.

## Declare the same origins in all three places

The reviewed game-server origins must match exactly — same scheme, same host, no path — in:

1. The platform submission form's game server addresses field (one per line). This becomes your
   hosted game's `connect-src`: the browser can only reach origins listed here or your gate.
2. `gameServerOrigins` in your `createGameServerGate()` options. This puts each origin into the
   set of valid join-ticket audiences.
3. The `joinTicket(origin)` call in your game client and the `audience` your server verifies.

A mismatch fails at a different layer each time: missing from (1) and the fetch dies on CSP with
"Refused to connect"; missing from (2) and the fetch succeeds but the ticket does not verify;
wrong in (3) and verification rejects every player. At most four origins, exact HTTPS only —
wildcards, paths and plain HTTP are refused. Rotating regions? Put them behind stable hostnames;
the list is not meant to churn.

## Serve /config, or the launch form refuses your gate

The launch page reads `GET /config` from your gate before it lets anyone launch a coin through
your game. `startGate()` serves it automatically; `createGameServerGate()` serves it only when
you pass `announce`. Without it the form reports your server "isn't answering — it may be offline,
or built before the current Game Mode SDK". Pass it:

```ts
const app = createGameServerGate({
  // ...pool, sessions, claims, discovery, settlement, gameId, awardToken...
  gameServerOrigins: ['https://us.game.example.com', 'https://eu.game.example.com'],
  announce: () => ({
    chainId: 84532,
    contracts: {
      positionManager: '0x4E7cB1e6800a7B297B38BddcecAF9Ca5b6616FDC',
      spendGatedCalculator: '0x8cbbE6b4cFA5Ccf68399Dbf1429d91A21097ebA5',
    },
    signer: SIGNER_ADDRESS, // the address of your gate's signing key
    settler: SIGNER_ADDRESS,
    walletCapWei: '25000000000000000',
    roundDurationMs: 90_000,
    minLobbyLeadMs: 60_000,
    gateEndsAtGraceS: 10,
    flaunchVariant: 'legacy11',
    requiresEoa: false,
    accepting: true,
    publicLaunchesOpen: true,
    privateLaunches: false,
  }),
})
```

The addresses above are Base Sepolia (chain 84532), read back from the chain. `signer` is what a
launch writes into its pool as the trusted signer — announce an address you do not hold and every
coin launched through your game is unplayable. `walletCapWei` must cover a flawless round
(`maxPointsPerPlayer` times the wei value of a point) or boot refuses.

Check: `curl https://<your-gate>/config` returns JSON with your `chainId` and `signer`, and
`curl https://<your-gate>/health` returns `{"ok":true}`.

## Point the gate's environment at the right origins

The two origin settings developers most often get backwards:

- Allowed origins (browser CORS and the WebSocket `Origin` check) must name BOTH browser callers:
  your game, served from its Moongate origin, and the flaunch page itself, which calls the gate
  directly — `POST /rounds/adopt` comes from the coin page, not from your iframe. Because the
  Moongate hostname changes per upload, use the single-label wildcard for the first:
  `https://*.games.moongate.com,https://flaunch.gg` (plus any preview page origin you test on).
  If your bootstrap follows the single-origin example, split the list:
  `allowedOrigins: required('GAME_ORIGIN').split(',').map((o) => o.trim())`. Missing the page
  origin fails as a CORS preflight error on `/rounds/adopt` the moment a coin page loads.
- The sign-in domain names the page the player is looking at — the flaunch site embedding your
  game — not your game and not your gate.

Generate the signing key, session secret (32+ characters) and award token (32+ characters,
`openssl rand -hex 32`) fresh per environment. The award token lives on the gate and your game
server only; it never reaches a browser or a zip.

## Wire the ticket handshake

Browser, after `joinEconomy()`:

```ts
const gameServerOrigin = 'https://us.game.example.com' // one reviewed origin, chosen by you
const { ticket } = await gameMode.joinTicket(gameServerOrigin)
socket.send(JSON.stringify({ type: 'join', ticket })) // first message; never in the URL
```

Your server, before accepting any gameplay frame:

```ts
const playerJoin = verifyPlayerJoinTicket(message.ticket, {
  awardToken,
  gameId,
  roundId,
  audience: gameServerOrigin, // the exact origin the browser connected to
})
if (!playerJoin || usedTicketIds.has(playerJoin.jti)) return socket.close(4401, 'invalid join ticket')
usedTicketIds.add(playerJoin.jti)
```

Also check the WebSocket `Origin` header against the Moongate wildcard, keep one live connection
per wallet, and treat every later frame as hostile input. Award points only through
`POST /internal/rounds/:id/awards` with the award token — see the gate README for the routes.

## Strip development fallbacks from the production bundle

A production zip that pings `localhost` ports, probes a region list on boot, or falls back to a
dev wallet endpoint will emit CSP errors on every load and can hang the game on a spinner when the
fallback wins a race. Gate development-only network paths behind a build flag so the submitted
bundle contains none of them.

## Submit, then verify against the real policy

Submit the zip with the gate option on (your gate origin) and the game server addresses filled in.
The form live-probes your gate's `/health` at submission, so deploy the gate first. Localhost
cannot rehearse the deployed CSP: after hosting, open the deployed game and confirm every declared
origin connects and an undeclared one is blocked. Then launch a fresh test coin through the room
link — a coin launched before a registration change stays bound to what it was launched with.
