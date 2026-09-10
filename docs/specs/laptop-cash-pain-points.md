# Spec: laptop.cash pain points for the Flaunch launchpad and game skills

Date: 2026-09-10. Source launch: laptop.cash on Base, LAPTOP-paired coins, optional Laptop Hunter game rounds. Eight Claude Code sessions, 29 commits on `feat/laptop-cash` (2026-09-08 to 09-10), plus two follow-up PRs on `main`.

This document merges two earlier specs written from different evidence (transcripts, commits and code comments in one; a review thread and deploy records in the other). It is input for two skills in this repository, not a skill itself and not a tutorial. It lists only what went wrong, cost retries, or needed a workaround.

## How to read it

Each entry carries:

- **Consumer tag.** `[launchpad]`, `[game]`, or both. Says which skill must absorb the entry.
- **Evidence label.** *Observed* (encountered or reproduced in a session), *Repository* (documented by code, tests or commit messages), *Outstanding* (not resolved or verified in the last recorded state; never convert it into a claim of success).
- **Symptom**, **root cause**, **fix applied**, **skill rule**, **required evidence** (what a future build must demonstrate before calling the item handled).

Contract addresses, SDK versions, allowance budgets, hosting commands and regional policy here are examples from one launch, not defaults for every launchpad. Version-dependent SDK gaps and provider behaviour must be re-verified when the skill is applied.

---

## 1. Failures that looked like success

Give these the highest prominence in both skills. Each one produced a green signal while the user's flow was broken.

### 1.1 Wallet reported an error after broadcasting a successful launch `[launchpad]` — Repository, Observed

- **Symptom.** "on creation I got 'An unknown RPC error occurred.' is our receipt detection busted?" The coin had launched. The form lost the hash and showed an error, inviting a dangerous retry.
- **Root cause.** MetaMask smart accounts wrap the call in `redeemDelegations(bytes[],bytes32[],bytes[])` (selector `0xcef6d209`) and can answer with a non-standard RPC error after broadcasting. viem labels it "An unknown RPC error occurred." and hides `error.details`.
- **Fix.** Capture `getBlockNumber()` before `writeContract`. On any send error that is not a `UserRejectedRequestError`, poll `getLogs` for ERC721 `Transfer` on the Flaunch NFT with `to = manager ?? creator` from the pre-send block, confirm `getTransaction(hash).from === creator`, for 60 seconds at 3 second intervals. Surface `error.details` when `shortMessage` is the generic label.
- **Skill rule.** Treat an ambiguous send error as unknown outcome, never as permission to resubmit. Record enough pre-submission context to recover the exact transaction from chain events correlated to the sender.
- **Required evidence.** Broadcast-then-error recovery; explicit rejection with no recovery attempt; recovery timeout; an unrelated nearby launch is not adopted.
- **Anchors.** `a51a599`; `src/features/create/receipt.ts`, `CreateTokenForm.tsx`.

### 1.2 A launched coin was excluded from its own launchpad `[launchpad]` — Observed, Repository

- **Symptom.** Discovery was scoped to the revenue manager. A coin launched from the site never appeared and its page 404'd. "Our coin lanuch did not lanuch into our revenue manager." The model doubted the launch came from the site; the user: "it did origintae from this site."
- **Root cause.** The launch used the SDK's plain `flaunchPairedToken`, which leaves the creator NFT with the creator. Discovery required manager membership. Server and browser also read different manager variables (see 4.3).
- **Fix.** See 2.1 for the atomic manager-aware launch. Membership invariant now holds by construction; approve-and-deposit kept as fallback.
- **Skill rule.** Specify the discovery membership invariant before choosing the launch call. Keep launch configuration and discovery scope consistent, with explicit handling for manager-disabled mode and invalid configuration.
- **Required evidence.** A real launch's creator NFT ends up in the configured manager and the coin becomes discoverable after indexing. Test browser-only and server-only manager variable configurations.
- **Anchors.** `1b700a4`, `af54b09`, `00bf54f`; `next.config.ts`, `src/features/create/launch.ts`, `managerDeposit.ts`.

### 1.3 Login did not survive refresh `[launchpad]` — Observed, **Outstanding**

- **Symptom.** Login through Privy succeeded, refresh returned to Connect Wallet, no persistent Privy session cookie. Reproduced locally and by the user on production.
- **Root cause (identified, not verified).** The shared Privy app used the custom cookie/API domain `privy.flaunch.gg`. A site on another origin cannot use those first-party HttpOnly cookies. The supported route is a site-specific Privy client with HttpOnly cookies disabled so the SDK manages persistence itself.
- **Status.** `NEXT_PUBLIC_PRIVY_CLIENT_ID` support merged in PR #2, but no compatible client ID was configured. Repo and Vercel access did not include Privy admin access. Must remain explicitly unresolved until the browser round trip is verified.
- **Skill rule.** Treat session persistence as a deployment requirement. Check site origin, Privy app, client configuration and cookie domain before implementation. Do not invent token storage, copy cookies between domains, or mark users authenticated from a remembered address.
- **Required evidence.** Real wallet login, refresh, still authenticated, wallet available, on the intended production origin. Also a new tab, genuine sign-out, and expiry behaviour where testable. Never put tokens in logs.

### 1.4 The correct domain was configured on the wrong Privy app `[launchpad]` — Observed

- **Symptom.** Connect Wallet greyed out. laptop.cash was whitelisted, but production used a different Privy app ID. Chrome received a `frame-ancestors` policy that omitted laptop.cash and blocked the embedded-wallet frame.
- **Fix.** App ID replaced in production env.
- **Skill rule.** Diagnose the deployed app and client IDs, the app-config response, iframe policy and browser errors before interpreting a disabled button. Check configuration against the exact production origin, not a dashboard setting presumed to belong to this deployment.
- **Required evidence.** The deployed bundle requests the intended app; the actual origin is allowed; the login dialog opens in a fresh browser. An env-var update alone is insufficient.

### 1.5 "Merged the fix" meant configuration support, not a working fix `[launchpad]` `[game]` — Observed

- **Symptom.** PR #2 added a client-ID prop but did not supply the required Privy client configuration. The user still disconnected after refresh. Repeated explanations of the missing setting did not complete the launch.
- **Skill rule.** Identify external configuration and access dependencies at the start. Separate code complete, configuration complete, deployed, and user-flow verified. If a service setting is inaccessible, state the exact outstanding action and owner. Complete independent work but never describe the dependent problem as fixed.
- **Required evidence.** Every claimed resolution includes deployed configuration and a behaviour check. An unresolved dependency survives handoffs, PR descriptions and final reports.

### 1.6 Feature on the branch, not in production `[launchpad]` — Observed

- **Symptom.** Automatic quoting existed on `feat/laptop-cash` and had not reached `main`. Production still required "Review trade" while the working branch did not. PR #3 later brought it to production.
- **Skill rule.** Compare working branch, PR head, production branch, deployed commit and domain alias. Test the deployed page rather than using local feature presence as evidence of release.
- **Required evidence.** On the production coin page, typing an amount while signed out requests pricing and fills the receive field without a click.

### 1.7 Green tests while the actual flow failed `[launchpad]` `[game]` — Observed

- **Symptom.** Auth tests passed without proving persistent sessions. A quote feature passed tests while production still needed a manual action. A successful build did not validate wallet login. A push landed before failing route tests were caught because a grep matched output and let the command chain continue.
- **Skill rule.** Tie completion criteria to the user's exact sequence on the deployed origin. Keep mock-based edge-case tests but label them as such. Require login then refresh, and type amount then receive estimate, as separate launch checks. Run the full suite, not a grep, before pushing.
- **Required evidence.** Browser results identify environment and commit, real versus mocked services, and untested steps. A region-blocked browser is a testing limitation, not a pass.

### 1.8 Game embed silently missing after a correct launch `[game]` — Observed

- **Symptom.** "launched … but no game mode? I had it enabled. why is the game embed not showing." On-chain params were correct. Gate rankings answered `that coin has no game`.
- **Root cause.** Gate CORS: `OPTIONS /rounds/adopt` from `http://localhost:3000` returned no `access-control-allow-origin`. The browser POST failed as a network error; the room component treated it as retryable, polled silently for 90 seconds, then fell back to the chart. The round expired unadopted.
- **Fix.** Origins added to the gate's `ALLOWED_ORIGINS` (user ran the Railway command; the auto-mode classifier blocked it). UI gained an "Opening the game room…" state and surfaces adoption failure for launches this browser remembers.
- **Skill rule.** Distinguish a network failure from a gate "no". List every external allowlist the launchpad depends on (gate CORS, Privy origins, RPC CORS, game CSP) and verify each for localhost, preview and production before the first test launch.
- **Required evidence.** Adoption from a non-allowlisted origin fails loudly in the UI within seconds. Gate returns 404, not 503, when its indexer lags; the client must not mistake that for a permanent "no" on a coin it just launched.

---

## 2. Flaunch SDK: launch path `[launchpad]`

### 2.1 The SDK does not type the deployed manager-aware zap overload — Repository, Observed

- **Symptom.** See 1.2. The model built a two-extra-transaction fallback (ERC721 `approve` to the manager, then `RevenueManagerV1_3.deposit`), costing two wallet confirmations and leaving a window where a failed deposit made the coin invisible. The user had to steer: "read docs.flaunch.gg we just need to specify the manager address in the launch call" and "look at rstr-launch repo because we had it working there."
- **Root cause.** `@flaunch/sdk` 0.13 types only `flaunch(params, signer, maxPremineCost)` on the v1_3 paired-token zap. The deployed zap also exposes `flaunch(FlaunchParams, TreasuryManagerParams, address signer) payable returns (address memecoin, uint256 ethSpent, address deployedManager)`.
- **Fix.** Hand-written ABI via `parseAbi` with `struct TreasuryManagerParams {address manager; address permissions; bytes initializeData; bytes depositData;}`, called with `writeContract` against `FlaunchZapV1_3Address[chainId]`, `permissions: zeroAddress, initializeData: "0x", depositData: "0x"`. Verified against the Base deployment on 2026-09-09.
- **Skill rule.** A missing SDK method is not proof the contract lacks the operation. Check installed SDK types against the target chain's deployed interface when an essential operation is missing. Verify version, address, overload, encoding and receipt events; isolate the adapter and document why it exists.
- **Required evidence.** The intended overload is simulated and its decoded result checked. Do not teach this launch's ABI gap as timeless platform behaviour.
- **Anchors.** `00bf54f`; `MANAGER_ZAP_ABI` in `src/features/create/launch.ts`.

### 2.2 Locate the creator NFT by its last transfer, not its mint — Repository

- With the atomic overload, mint and hand-off happen in one receipt. Scanning for the ERC721 `Transfer` from zero to the creator wrongly triggers a redundant deposit. Use the final transfer (`flaunchTokenHeldBy(logs, manager)`). The old docblock in `managerDeposit.ts` still says the zap "cannot" deposit at launch and must be corrected.

### 2.3 Paired token not approved on the registry at build time — Observed

- `isApproved(LAPTOP)` on the Base v1_3 `PairedTokenRegistry` was false in the morning and true by afternoon. A `NEXT_PUBLIC_PAIRED_TOKEN` env switch between flETH and LAPTOP was added, removed, then re-planned the same day ("hot swapping the token pairing from LAPTOP to ETH").
- **Skill rule.** Verify `createFlaunch({publicClient}).isPairedTokenApproved(token)` first and keep the check in the launch path. Do not build an env-switchable pairing unless the product needs it; build-time public vars require a redeploy per flip. flETH (`0x000000000D564D5be76f7f0d28fE52605afC7Cf8`) is what an "ETH-paired" pool holds and what the API reports; `isEthPairing` must accept flETH and the zero address.

### 2.4 Receipt watching, timeouts and replacements — Repository

- **Symptoms.** viem's `waitForTransactionReceipt` block watching missed mined receipts; timeouts rendered like failures; `onReplaced` classification was lost when a timed-out wait was rechecked; a revert wiped the form and forced re-uploading metadata.
- **Fix.** Race the watcher (kept for `onReplaced`) against an independent 2 second `getTransactionReceipt` poll with a 90 second deadline. Distinct `unknown` status with an explicit "Check transaction" action. Persist `replaced ||= reason !== "repriced"` on the pending record. Mark the launch confirmed before decoding events or running post-launch setup. Memoise uploaded metadata on `{imageHash, fieldsKey}`.
- **Skill rule.** Distinguish pending, confirmed, reverted, replaced, cancelled and unknown. Timeout is not revert. Receipt success is final even if post-processing fails. Make the persistence boundary explicit if pending state is page-local.
- **Required evidence.** Mined receipt with watcher failure; replacement then timeout then retry; cancellation; no duplicate launch or swap; navigating away during a pending operation.
- **Anchors.** `5dddaa1`, `016dab8`.

### 2.5 Metadata and upload work delayed the critical path — Repository

- Uploads could hang; 429s and moderation rejections ("Content flagged: Suggestive content") surfaced as generic failures; 10-character tickers were rejected upstream; the user asked for eager upload on file pick.
- **Fix.** Direct `fetch` to `https://web2-api.flaunch.gg/api/v1/upload-image` and `upload-metadata` with a 30 second `AbortController`; surface the API `error` body; specific 429 copy (4 image uploads per minute per IP); ticker regex `^[A-Z0-9]{1,8}$`; upload on selection.
- **Skill rule.** Validate provider constraints early, upload artwork when selected, retain upload results across preparation failures, report upload versus wallet versus chain failure separately. Bound network work before asking for a signature. Eager upload can hit the per-minute limit when a user cycles images.
- **Required evidence.** Slow upload, 429, malformed response, replacing an image mid-upload, metadata failure and retry without losing the form.
- **Anchors.** `5dddaa1`, `546b2f1`; `create/upload.ts`.

### 2.6 Fee quote and launch parameters — Repository

- `calculatePairedTokenFlaunchFee({flaunchParams, slippageBps: 100n})`; validate `pairedPremineCost === 0n` when no prebuy is intended and `ethRequired` is a non-negative bigint. `initialPriceParams` is `abi.encode(uint256)` of USD with 6 decimals. Quote TTL 60 seconds, re-checked before simulation and again after the wallet prompt.
- Economics changed mid-build (market cap 10,000 to 4,000 USD, creator fee 80% to 100%) and the README drifted. Keep economics in one constants file; the README points at it.

---

## 3. Trading: Flaunch pool and aggregator `[launchpad]`

### 3.1 Pool liquidity existed before the aggregator could route it — Observed, Repository

- **Symptom.** "after the game ended we couldn't get a quote to sell - how long would it take until selling opens up?" Model misdiagnosed as wallet or 0x lag. User: "I thought we used the flaunch sdk for sells btw?"
- **Root cause.** The SDK was used for launches and in-game buys but never for widget sells; all widget trades went to 0x, which routes a custom-hook pool only after indexing it. A 0x `SWAP_VALIDATION_FAILED` for a zero-balance taker was also masked as "route not available".
- **Fix.** `createFlaunch({publicClient}).planPairedTokenSwap({coinAddress, pairedToken, amountIn, slippageBps, sender, direction: "sell"})` mapped into the 0x quote shape (`plan.swap.to/data/value`, `expectedAmountOut`, `amountOutMin`, `approve?.spender`, `tokenOut`) and executed by the same path, with 0x as `.catch` fallback. Sanity checks: `tokenOut === pairedToken`, `swap.value === 0n`.
- **Skill rule.** Distinguish pool existence, trading or gate status, indexer availability and aggregator routing. Route on the coin's own pool first; keep an aggregator as fallback, never as the only path. Do not collapse distinct aggregator error names into one message.
- **Required evidence.** Fresh pool buy and sell; paired-token route; unsupported cross-token route; post-round sell before aggregator indexing; fallback behaviour; correct spender and router. One successful swap does not prove all directions.
- **Anchors.** `fe81e81`, `115dc4d`; `poolSwap.ts`, swap API route.

### 3.2 No ETH or USDC aggregator route into paired-token pools — Repository

- 0x routes the paired token into the pool as a single hop but finds no path through it from ETH or USDC. Buys returned `liquidityAvailable: false`, shown as generic no-liquidity.
- **Fix.** Default the widget currency to the paired token in both directions; 422 with a currency-specific hint. An inline ETH to LAPTOP quick-buy widget was built and deleted hours later in favour of a Uniswap link-out, leaving `/api/pricing` orphaned.
- **Skill rule.** Confirm each currency route with a real `/price` call before exposing it in the UI. Do not build inline cross-token buys until a route is confirmed.

### 3.3 Approvals and balances — Observed, Repository

- Every buy was approve plus swap; in-game buys were two transactions. "just make the first approval for $1000 of LAPTOP so it's only a 1-time tx." Players with no LAPTOP signed an approve and then the swap simulation reverted with no explanation.
- **Fix.** `approvalAmount = max(sellAmount, budgetUsd / sellTokenUsd)` for the paired token only, price fetched best-effort so a missing price degrades to an exact approval. Game host passes `approvalAllowance` to `buyCoinPairedToken`. `balanceOf` read before letting the SDK request an approval. Lobby readiness overlay pre-approves the router from `poolSwapForHook(chainId, positionManager)`.
- **Skill rule.** Check balance before approval. Make any reusable approval budget deliberate and price-aware, with an exact-amount fallback; do not adopt this launch's $1,000 as a general default. Only 0x's fixed `AllowanceHolder` (`0x0000000000001fF3684f28c67538d4D072C22734` on Base) may be an approval spender; reject any other `issues.allowance.spender`.
- **Anchors.** `7a35358`, `482198d`, `d1e5698`.

### 3.4 Quote lifetime — Repository

- `expiresAt` was computed server-side with `Date.now()`; clock skew and slow requests extended quotes. Fix: server returns `expiresInMs`; browser computes `performance.now()` at request start plus TTL, and re-checks expiry after the wallet prompt and immediately before `sendTransaction`.
- **Skill rule.** TTL on the browser's monotonic clock from request start. Re-check every time-sensitive precondition after every await that involves the user.

### 3.5 Unsigned price previews coupled to authentication — Observed

- The widget refused to quote without an address; later it could request an unsigned price but still needed a manual action.
- **Skill rule.** Use the pricing endpoint without a taker when supported; require a taker for executable quotes. Invalidate previews when a wallet connects or changes. Never execute an indicative price. Suppress wallet-specific balance and simulation errors on previews.
- **Required evidence.** Signed-out and auth-loading quote requests; no login prompt merely for pricing; new executable quote after connection; explicit execution guard against price previews.
- **Anchors.** PR #2, PR #3; `src/app/api/swap/route.ts`, `swap.ts`, `useSwap.ts`.

### 3.6 Automatic quoting rules — Observed implementation work

- Debounce valid input (300 ms used); keep editing available during pricing; bind responses to the exact trade and account key; discard stale outcomes; refresh expired quotes only while `document.visibilityState === "visible"`; no retry loop after failure; re-quote after approval. Never auto-submit the trade.
- **Required evidence.** Rapid edits, invalid input, old request failing after new input, account switch, expired quote, hidden tab, failed route retry, approval followed by a fresh quote.
- **Anchors.** `5dddaa1`, `c0c0853`, PR #3.

### 3.7 Token-sized numbers and swap interactions needed three passes — Observed

- "6 decimals again", "the swap card overflows its number input", "remove the ','", "it just needs to quote inline", "full amount needs to be shown when clicking into the input."
- **Fixes.** `DISPLAY_DECIMALS = 6` with truncation, never rounding up, so max-fill cannot exceed balance; `<0.000001` for dust; no digit grouping; strip pasted commas; `min-w-0` on the `fieldset` (browsers give fieldsets `min-inline-size: min-content`); smaller font with horizontal scroll; direction change resets the form.
- **Skill rule.** Ship these defaults on day one and test with realistic magnitudes, dust, long symbols and a narrow viewport.
- **Anchors.** `1c3cea9`, `d1e5698`, `c0c0853`, `9948fd8`.

---

## 4. Pricing, discovery and indexing `[launchpad]`

### 4.1 Custom-paired USD metrics used stale per-pool conversion rates — Observed, Repository

- **Symptom.** "market caps are wrong here … please debug and fix." Caps inflated up to 18x and the ranking scrambled as LAPTOP moved about 10x in an hour.
- **Root cause.** Flaunch's market API values a paired-token pool in "ETH" at the ETH-to-paired rate of that pool's last swap, then applies today's ETH price.
- **Fix.** Read `Pool { sqrtPriceX96, pairedDecimals }`, `PairedToken { lastEthToPairedRate, decimals }`, `Bundle { ethPriceUSD }` from Envio and reprice server-side. `sqrtPriceX96` is sqrt(token1 per token0); token0 is the lower address, so invert when the coin sorts above the paired token. Liquidity is not indexed per pool and is rescaled by the same correction. Charts, volume, 24h change and trade values remain Flaunch's trade-time figures.
- **Skill rule.** Establish units and valuation timestamp for every metric. Derive current valuations from current pool state and one consistent paired-token USD rate. Distinguish current from historical valuation and leave unavailable prices unknown.
- **Required evidence.** Different pool swap ages; paired-token price moving without a coin swap; both token orderings; non-18 decimals; absent rates; market cap consistent with supply.
- **Anchor.** `6e4ca0d`; `src/lib/server/pricing.ts`.

### 4.2 Chain confirmation mistaken for indexer availability — Observed, Repository

- "the API 404s for ages … new coins should sit in a clean loading state", then "now getting tons of 404s and the site isn't loading."
- **Fix.** Typed `ApiError` with `.status`; launched addresses remembered in `localStorage` for 24 hours and awaited indefinitely; 3 minute grace for other unknown addresses; states `loading | indexing | missing | failed | ready`. `useSyncExternalStore` with a `null` server snapshot so hydration agrees.
- **Skill rule.** Model chain-confirmed, manager-eligible, indexed, market-ready and game-adopted as separate milestones. Keep confirmed hashes visible while bounded polling catches up. Preserve not-found versus upstream-failure semantics. No second launch because discovery is late.
- **Anchors.** `e19b132`, `016dab8`.

### 4.3 Manager variable split between server and browser — Observed

- "still showing all LAPTOP paired coins not ones just in our revenue manager." The browser deposited into `NEXT_PUBLIC_REVENUE_MANAGER_ADDRESS`; the server scoped by `REVENUE_MANAGER_ADDRESS` only. A refactor silently dropped a fallback added elsewhere.
- **Fix.** Server reads the server var then the public one; `next.config.ts` `env` bridges the server var into the bundle.
- **Skill rule.** One manager address, read from one helper, bridged into the client bundle. Both sides must agree or launches become invisible.

### 4.4 Framework fetch cache collides across GraphQL scopes — Repository

- Next caches by URL, method, body and headers. Membership pages whose variables omit the pairing served cross-scope results. Fix: synthetic `X-Laptop-Scope: {managerId|all}:{pairedTokenId}` header; `cacheSeconds = 0` means `no-store` for live pages. Never cache market or eligibility responses at the CDN.

### 4.5 Public index contains coins the market API no longer serves — Repository

- Confirmed not-found from Flaunch for an Envio-listed coin is skipped when unscoped; a manager-scoped catalog stays strict. Cross-source guard throws when Flaunch and Envio disagree on pairing. Upstream paired-token filter supports `sort=new` only; some coin queries require `addresses` (`FST_ERR_VALIDATION`).

### 4.6 Live feed and origin rules — Observed, Repository

- WebSocket backfill is 50 global events per chain; an empty strip can mean no relevant events. Client-side filtering by chain and coin allowlist is mandatory. Only the origin of the API URL is shared with the browser. Feed WebSocket 403s were seen alongside auth failures and must be diagnosed independently; that 403 resolution was not established.
- **Skill rule.** Diagnose HTTP, iframe and WebSocket errors separately rather than treating a global reconnecting label as an auth diagnosis.

---

## 5. Game gate and launchpad host `[game]`

Everything here is conditional on a game-enabled launchpad. The creator-side game skill owns 5.1 to 5.4 and 5.9; the launchpad host parts (5.5 to 5.8) are shared with the launchpad skill.

### 5.1 Gate CORS and origins — Observed

- See 1.8. Origins must be declared identically in three places: registration `gateOrigin` and `gameServerOrigins`, gate `allowedOrigins`, and the platform submission. The parser accepts exact HTTPS origins and rejects wildcards, paths and credentials. Add localhost and every preview origin before testing.

### 5.2 Game artifact CSP and gate target — Observed

- The game build's CSP `frame-ancestors` listed only moongate.com, flaunch.gg and two reflaunch previews; `connect-src` pointed at the Sepolia gate. Not fixable in the launchpad repo. Needed a new game ZIP and a new play URL; the play URL changed three times in one day.
- **Skill rule.** The game artifact's CSP and gate origin are a deploy prerequisite owned by the game. Confirm both name the launchpad origins and the mainnet gate before wiring the embed. New ZIP means new play URL.

### 5.3 Gate config announced the wrong chain and generation — Observed, Repository

- At the start the gate `/config` announced `chainId 84532`, a Sepolia position manager, `flaunchVariant: legacy11`, and MUSD as the only spend token. The model planned an env-switchable Sepolia mode, then rewrote it when told to assume mainnet.
- **Fix.** `fetchGateConfig` fails closed on `chainId !== 8453`, `flaunchVariant !== "v1_3"`, position-manager mismatch against `FlaunchPositionManagerV1_3Address[chainId]`, `accepting === false`, duplicate `spendTokens`, a cap the gate never priced. Config is read on toggle and again immediately before the fee quote because the signer is written on chain.
- **Skill rule.** A launch written against a stale or foreign gate is a coin nobody can play, and the chain will not undo it. Vet chain, variant, position manager, signer, settler, calculator, cap units, start time and lead time. Fail closed. Re-read right before quoting.
- **Required evidence.** Incompatible gate fails before an irreversible launch; expiring start time invalidates the quote; ordinary launches continue independently.
- **Anchors.** `546b2f1`, `482198d`; `game/gate.ts`, `create/gameLaunch.ts`.

### 5.4 Package discovery — Observed

- Guessed npm names `@flaunch/game-sdk`, `@flaunch/game-mode`, `@flaunch/game` all 404'd. Real packages: `@flayerlabs/gamemode-spec` (`isCanonicalSpendHookData`, `embed`), `@flayerlabs/gamemode-client` (`attachGameHost`, `connectHost`, `joinEconomy`), `@flayerlabs/gamemode-gate` (`createGate`, `createGameServerGate`). docs.flaunch.gg game-mode pages 404'd via fetch; the model read SDK source in `node_modules` and sibling repos instead. Test fixtures failed `isCanonicalSpendHookData` six times before matching the canonical hook payload (zero referrer, then signed fields). Installed SDK was 0.12.0 while 0.13.0 had shipped the day before with a changed paired-swap API that fails closed on legacy routers.
- **Skill rule.** Name the packages and their key exports explicitly. Point at SDK source and repo guides, not docs URLs that may not exist. Check the installed SDK version against the latest on the day.

### 5.5 Router override — Repository

- The gate's announced `poolSwap` may be a legacy deployment the SDK refuses. Never pass a `router` override to `buyCoinPairedToken`; `poolSwapForHook` is authoritative. If the gate disagrees, skip pre-approval rather than approving the wrong spender.

### 5.6 Spend-gate encoding and timing — Repository

- `feeCalculatorParams = abi.encode(keccak256("flaunch.dispatcher.route.v1"), calculator, abi.encode(keccak256("flaunch.spendGate.params"), true, walletCap, signer, settler, endsAt))`. A wrong byte yields a launched coin nobody can trade. `gateEndsAt = startsAt + roundDuration + grace`, 30 day ceiling. Fixed 180 second start delay; `isRoundTooSoon` and quote expiry re-checked before simulation and again before `writeContract`. README still described a 5/15/60 minute picker; the user asked twice to confirm the 3 minutes.

### 5.7 Adoption and discovery contract — Repository

- `POST /rounds/adopt` is unauthenticated by design and idempotent; the chain decides. Status contract: 404/403 means permanent no, 503/429 means retryable, anything else non-retryable. Bounded retry (90 seconds at 6 second intervals) only for fresh coins or coins this browser launched. Discovery must never adopt rounds or create seats as a side effect; use `GET /coins/:coin/rankings`. The gate reports `opensAt: 0` for ended rounds; a strict schema turned the whole upcoming list into a 502. Reconstruct as `closesAt - roundDurationMs`.
- **Required evidence.** Upcoming, live, ended and ordinary-coin responses in one list, including the zero timestamp.
- **Anchor.** `115dc4d`.

### 5.8 Host trust boundary and readiness — Repository

- The trusted parent (`attachGameHost`) is the only code that moves money. Every value that decides what a transaction does comes from the page's configuration and the adopted round, never from the frame. Refusal codes to preserve: `invalid-authorisation`, `buyer-mismatch`, `pool-mismatch`, `expired`, `unexpected-signer`, `nonce-replayed`, `bad-signature`. Nonces are marked spent before submission and rolled back only when no hash exists. Wallet changes are read through a ref so they never detach a bridge that still owes the game a buy result. Buys default to a 2 minute deadline including wallet interaction; a timeout returns `try-again` with the hash and does not undo the transaction or release the gate hold.
- Readiness: separate earned allowance, actual balance and ERC20 approval. Provide an explicit funding path (the inline buy was replaced with an external link). Market data fed to the game is deliberately lossy (`priceEth` is null; games read `priceUsd`) and never participates in scoring.
- **Required evidence.** No balance, insufficient allowance, mismatched router, unavailable USD price, cap exceeding the standing budget, a player who chooses not to buy.

### 5.9 Scale — Observed, advisory

- Asked whether 1,000 concurrent players across games is supported. The gate serialises whole round state to Postgres per action on a single replica, and the site polls three endpoints every 3 seconds per open coin page. No fix; the skill should state the limits.

---

## 6. Wallet, Privy and RPC `[launchpad]` `[game]`

### 6.1 Privy identities loop and RPC substitution — Repository

- Privy returns new `login`, `logout` and `wallets` identities every render; publishing a session re-renders the tree and loops forever. Fix: `latest` ref plus `useCallback` wrappers with empty deps; the publishing effect depends only on primitives. A regression test mocks fresh identities per call. Privy replaces the default RPC with its embedded-wallet RPC unless `addRpcUrlOverrideToChain(CHAIN, url)` is used for both `defaultChain` and `supportedChains`. `PRIVY_CONFIG` must be module-scoped.
- **Skill rule.** Verify the configured RPC is used by both public reads and wallet clients. Do not add an undisclosed raw-RPC fallback that bypasses the intended gateway.
- **Anchor.** `47510c1`; `PrivyBridge.tsx`.

### 6.2 Authentication, connection and initialisation treated as one state — Observed in review

- The account UI required both authentication and a connected address, so an authenticated user with no restored wallet saw Connect Wallet, whose action called `login()` again. Readiness combined Privy initialisation with wallet discovery.
- **Skill rule.** Define separate states: initialising auth, signed out, authenticated, restoring wallet, wallet disconnected, transaction-ready. Keep public quoting independent of wallet readiness. Do not mistake an address missing from `useWallets()` for a revoked session. Re-verify address and chain after every `getWalletClient()` and again right before signing.
- **Required evidence.** Auth restored before wallets, authenticated with an empty wallet list, account change, delayed discovery, failed reconnect.

### 6.3 RPC gateway budget and CORS — Observed

- `project-level rate limit rule exceeded … rule: 'method:eth_getBlockByNumber'` on a shared 75 rps project budget; surfaced in the UI as "An unknown RPC error occurred." PRs to add the preview origin to CORS and move to a per-visitor budget were opened in the gateway repo; merge was classifier-blocked and left to the user, still unmerged at production deploy. The app has no raw-RPC fallback, so a missing origin in the gateway allowlist is the most likely "works in prod, not locally" trap.
- **Skill rule.** Budget RPC per visitor. Surface `error.details`. Treat the gateway allowlist as a deploy checklist item. A working curl request is not a CORS test.

---

## 7. Deploy, environment and verification `[launchpad]` `[game]`

### 7.1 Build-time configuration and hosting traps — Observed

- Production domain served `main` (landing page only), so every app route 404'd until the preview domain was attached to the feature branch. Preview had `ssoProtection: all_except_custom_domains`, so nothing could be verified there for hours. `NEXT_PUBLIC_DEMO_MODE=true` had been set a day earlier ("why's it showing as Demo mode"). Public vars are inlined at build time. Vercel commands initially used the wrong team scope; the CLI rejected converting a Secret to Config in place; env pulls returned `[SENSITIVE]` placeholders; the CLI printed `FAILED` for `NEXT_PUBLIC_*` adds after its exposure warning even when the value landed. Production builds took about 6 minutes versus 1 for previews ("is our build stuck?").
- **Skill rule.** Inspect linked project, team, production branch and variable targets before mutation. Recognise build-time public values versus server secrets. Preserve environment coverage when replacing a variable. Redeploy the intended commit without bundling unrelated local edits. Never infer deployment from a successful push.
- **Required evidence.** Correct project and team, expected variable targets, intended deployed commit, ready production alias, browser-observed public configuration.

### 7.2 Readiness went back and forth — Observed

- "are we ready to put this live?" four times before production deploy, each time blocked by a missing env var or allowlist. "I want 3 to be as best tested as possible now as I do not want to launch a coin … run the test do not deploy to production." A simulate-only launch through the manager-aware zap on mainnet found two real bugs (`opensAt: 0` and no ETH/USDC route) before going live.
- **Skill rule.** Deploy checklist: domain to branch mapping; SSO protection off for the preview to verify; demo flag off; every `NEXT_PUBLIC_*` and server secret present in every environment; allowlists (Privy, RPC gateway, gate CORS, game CSP) updated; a simulate-only launch on mainnet before the first real coin. Use the vocabulary code pushed, deployment ready, live dependency reachable, mainnet write executed, user flow verified.

### 7.3 Geographic restrictions and tooling prevented final browser verification — Observed

- The production browser was redirected to the regional restriction page, preventing the final wallet-click check. The shared Chrome DevTools profile was in use; a separate Playwright browser was needed. Initial sandbox restrictions prevented Chrome launch and network access.
- **Skill rule.** Plan an authorised test environment and permitted test location before release. Distinguish a blocked harness from a broken app. Do not remove restrictions or report bypassed local checks as production evidence. Do not hardcode this launch's country list into the skill.

### 7.4 Documentation and handoffs contradicted the implementation — Observed, Repository

- README kept "no direct router fallback" after one was added, described manual quoting after auto-quoting shipped, kept a 5/15/60 minute picker after a fixed 3 minute delay, and disagreed with code on launch economics. The `managerDeposit.ts` docblock still says the zap cannot deposit at launch. Branches disagreed about what had shipped.
- **Skill rule.** Update behavioural documentation alongside fixes. Check README claims against code and the deployed branch. Handoffs retain external dependencies and unresolved failures rather than flattening everything into done. Keep numbers out of the README and point at the constants file.

---

## 8. Tooling and process `[launchpad]` `[game]`

- Vitest defaults to `environment: "node"`; every DOM test needs `// @vitest-environment jsdom` on line 1. No jest-dom matchers. `oxc.jsx.runtime: "automatic"` required for TSX tests.
- `typecheck` must be `next typegen && tsc --noEmit`; `next-env.d.ts` is gitignored. Build uses `next build --webpack`.
- React compiler lint fired on "Calling setState synchronously within an effect" and "Cannot access refs during render"; assign refs inside effects.
- Hydration: browser-only storage returns a `null` server snapshot; use `query.errorUpdatedAt` rather than `Date.now()` in render. `localStorage` is never load-bearing; wrap every access in try/catch.
- Several sessions edited the same tree concurrently: type errors referenced code the current session had not written, unrelated changes rode along in commits. One session per tree, or a worktree per session.
- The auto-mode classifier blocked eight external-state commands (Railway variables, Vercel env and SSO settings, `gh pr merge`, a hooks-bypassing commit). Keep a list of commands the user must run and batch them.
- Patch scripts tripped repeatedly on template literals and exact-string anchors; zsh expanded unquoted `echo =====` separators 22 times. Quote separators; prefer structured edit tools for large files.

---

## 9. Reference values that were looked up repeatedly

Examples from this launch; verify before reuse.

| Name | Value |
|---|---|
| LAPTOP (paired token, 18 dp) | `0xB095274743941e953c746F9C228DA9c18Bb6ec29` |
| flETH | `0x000000000D564D5be76f7f0d28fE52605afC7Cf8` |
| Native ETH sentinel (0x) | `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE` |
| USDC (Base, 6 dp) | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |
| 0x AllowanceHolder (Base) | `0x0000000000001fF3684f28c67538d4D072C22734` |
| Revenue manager (v1.3.1 multi-asset) | `0x60636623E6Ff789bfdFA138ac86C5EE41f42C670` |
| LAPTOP price calculator | `0x7CA2359dDD33663Aa872A158587889a0d1e252a6` |
| ERC721 Transfer topic | `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef` |
| Envio ids | `${chainId}-${lowercaseAddress}`; `Bundle` id is the bare chain id |
| Upload API | `https://web2-api.flaunch.gg/api/v1/upload-image`, `upload-metadata` |
| Game packages | `@flayerlabs/gamemode-spec`, `gamemode-client`, `gamemode-gate` |
| Gate public endpoints | `GET /config`, `POST /rounds/adopt`, `GET /rounds/:id`, `GET /coins/:coin/rankings`, `GET /games/:chainId/:coin` |

---

## 10. Instructions for the skill editor

- Place each entry beside the relevant existing workflow in the consuming skill: configuration and auth, paired launch, receipts and recovery, discovery and pricing, swap UX, game gate and host, deployment verification. Do not append an undifferentiated checklist.
- For each retained entry, express a trigger, a diagnostic step, a corrective action and an observable completion condition. Preserve the distinction between proven root causes and hypotheses.
- Give highest prominence to section 1. Those are the failures that looked like successes.
- Keep game lessons conditional in the launchpad skill and route to the game skill. Keep the launchpad skill routing to `basic/token-launchpad`, `core/sdk`, `core/api` and `core/manager` rather than restating them.
- Do not prescribe LAPTOP, Base addresses, a fixed approval budget, a particular manager, this launch's hosting, or its geographic policy to every launchpad.
- Mark version-dependent SDK gaps (2.1, 5.4) and provider behaviour (1.1, 6.1) for re-verification when the skill is applied.
- Do not label the launch or auth work complete on the strength of these notes. Last verified outcome: automatic unsigned quoting merged and deployed through PR #3; persistent Privy auth remained dependent on an unconfigured client (1.3).

## Evidence index

- [PR #2](https://github.com/flayerlabs/laptop.cash/pull/2): client-ID support and disconnected price previews, merged as `9fcc79f`.
- [PR #3](https://github.com/flayerlabs/laptop.cash/pull/3): automatic quotes for signed-out users, merged as `776279b`.
- Commits on `feat/laptop-cash` (inspect with `git show <hash>`): `5dddaa1` upload bounds, quote expiry, recovery tests; `546b2f1` game configuration, upcoming rounds, eager upload; `e19b132` indexing wait; `6e4ca0d` paired pricing correction; `7a35358`, `482198d` approvals and readiness; `af54b09`, `00bf54f` manager configuration and atomic manager launch; `016dab8`, `a51a599` receipt polling and broadcast recovery; `fe81e81`, `115dc4d` pool sells, route defaults, ended-round normalisation; `1c3cea9`, `d1e5698`, `c0c0853`, `9948fd8` amount display and automatic quotes.
- Source specs this merges: `laptop.cash/docs/flaunch-launchpad-skill-pain-points.md` and `laptop.cash/artifacts/flaunch-launchpad-skill-pain-points-spec.md`.
- Real-world references: `laptop.cash/src/features/{create,swap,game}`, `laptop-hunter/{gate,game-mode}`, `rstr-launch/docs/LAUNCHPAD_SKILL_PLAN.md`, `gamemode-sdk/docs/guides/*`.
