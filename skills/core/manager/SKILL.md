# Flaunch Manager Integration Guide

## Purpose
Use this guide to integrate contracts with Flaunch treasury managers, launch a real memecoin for integration testing, and validate fee routing to recipient contracts (vaults, treasuries, staking receivers, buyback executors, etc.).

This guide is manager-agnostic and applies across approved manager implementations.

## Reference Map

- Contracts repo: `https://github.com/flayerlabs/flaunch-contracts`


## Chains

- Base Mainnet (`base`): `8453`
- Base Sepolia (`baseSepolia`): `84532`

## Quick Router

| Goal | Manager | Primary assertion |
| --- | --- | --- |
| Send fees to fixed addresses | `AddressFeeSplitManager` | recipient balances match configured shares |
| Send fees to stakers | `StakingManager` | staker rewards accrue and claim correctly |
| Execute buyback policy | `BuyBackManager` | buyback route works separately from claim accounting |
| Creator + protocol split only | `RevenueManager` | protocol and creator claims are correct |
| Split by NFT ownership | `ERC721OwnerFeeSplitManager` | ownership-based claims route correctly |

Default for simple vault routing:

- `AddressFeeSplitManager` with `recipientShares = [(recipientContract, 100_00000)]`

## Portability Rule

This skill is written to be portable across workspaces.

- Use the snippets and invariants in this file as the default source of truth.
- When the user is actively working inside `flaunch-contracts`, adapt imports, harnesses, and test structure to that repo.
- Do not assume a specific local folder layout, remapping set, or harness file unless the user has already provided that repo context.

## Preconditions

- The builder knows which manager policy they want to implement.
- The builder has access to the relevant Flaunch contracts, interfaces, and deployment addresses for the chosen chain.
- The builder can run their own Solidity test suite, even if the exact harness differs from repo to repo.

## Required Inputs (Before Coding)

- Manager type and fee policy.
- Target chain/environment for test.
- Recipient contract behavior (passive receiver vs active claim caller).
- Expected claim/action path (`claim`, protocol claim, staking claim, buyback route, etc.).
- Test invariants (who should receive what, and when).

## Manager Selection Rules

1. Fixed recipient split -> `AddressFeeSplitManager`.
2. ERC20 staking rewards -> `StakingManager`.
3. Buyback policy required -> `BuyBackManager`.
4. Simple creator + protocol split -> `RevenueManager`.
5. NFT-holder split -> `ERC721OwnerFeeSplitManager`.
6. Mixed policy requirements -> choose dominant payout policy and validate secondary behavior in separate manager-specific tests.

## Integration Workflow

1. Deploy or set up the Flaunch integration harness.
2. Deploy recipient/consumer contracts if needed.
3. Deploy manager implementation and approve it in `TreasuryManagerFactory`.
4. Build manager-specific `initializeData` and `depositData`.
5. Launch memecoin via `FlaunchZap.flaunch(...)` with treasury manager params.
6. Capture deployed manager address from launch result/events.
7. Wire the manager into recipient or consumer contracts if required.
8. Execute the manager-specific action path.
9. Assert balances, accounting state, and ownership invariants.

Base manager lifecycle to keep in mind while implementing:

1. `initialize(owner, data)` sets `managerOwner`, marks the manager initialized, and then forwards into manager-specific `_initialize(owner, data)`.
2. `deposit(flaunchToken, creator, data)` validates the Flaunch contract + creator permissions, transfers custody of the Flaunch ERC721 into the manager, and then forwards into manager-specific `_deposit(...)`.
3. Custom manager behavior should normally live in `_initialize` and `_deposit`, not by re-implementing base setup or escrow rules.

Low-level implementation notes:

- Fee balances are not invented locally inside each manager. Managers withdraw from registered fee escrow sources via the base `TreasuryManager` flow, then layer manager-specific accounting/dispatch rules on top.
- Deposit permissions follow the base `TreasuryManager` path: `managerOwner` is always valid, `permissions == address(0)` means open deposits, otherwise `permissions.isValidCreator(...)` gates the deposit.
- Deposited Flaunch NFTs are custodied by the manager contract itself. Base manager logic also provides token timelock and rescue behavior, so custom managers should extend that model rather than bypass it.
- Reference the base manager internals when needed: `TreasuryManager.sol` in the Flaunch contracts repo.

## Custom Manager Wrapper Zap

Use this pattern after manager creation when you want a project specific launch entrypoint that still launches through `FlaunchZap`, but always routes through your manager policy.

1. Deploy your custom manager implementation.
2. Approve the manager in `TreasuryManagerFactory`.
3. Deploy a wrapper zap contract that calls `FlaunchZap.flaunch(...)` and forces your manager in `_treasuryManagerParams.manager`.
4. Set wrapper defaults for `_treasuryManagerParams` (`manager`, `permissions`, `initializeData`, `depositData`) so launches consistently use your manager config.
5. Launch through the wrapper zap, then run manager specific post-launch deposit or initialization logic when needed (for example `depositFromZap`).
6. Capture returned launch outputs and assert the launched token is bound to your manager before claim or action-path tests.

Required tests for wrapper zaps:
- one happy-path test proving wrapper launch binds the intended manager
- one failure-path test for invalid manager params or unauthorized config changes
- one post-launch integration test for manager specific deposit or init logic
- one payout and accounting test verifying fees route according to manager policy

## Direct Routing Default (Single Recipient)

Use this when goal is "all fees to one vault/treasury":

1. Choose `AddressFeeSplitManager`.
2. Use recipient shares `[(recipientContract, 100_00000)]`.
3. Launch memecoin with that manager config.
4. Trigger `claim()` path.
5. Assert recipient receives expected amount.

## Non-Negotiable Testing Rule

When building or integrating any manager, a test is always required.

- Minimum: one happy-path integration test + one failure/revert-path test.
- Preferred: include accounting assertions (claimed totals, per-recipient balances, protocol/creator/owner splits) in addition to external balance checks.
- Do not ship manager integrations without manager-specific tests.

## Detailed Manager Flows + Required Tests

Use these as baseline implementation flows.

### `AddressFeeSplitManager` (fixed recipient split)

Flow:
1. Build `recipientShares` and initialize manager with desired `creatorShare`/`ownerShare`.
2. Deposit token(s) into manager.
3. Allocate/distribute fees.
4. Call `claim()` for each recipient path under test.
5. Assert recipient payouts and manager accounting (`amountClaimed`, creator/owner totals when enabled).

Required minimum for new builds:
- one test validating share payout correctness,
- one test validating init/share constraints revert path.

Low-level notes:
- Treat the share table as accounting state, not just config. Tests should prove the share sum is valid at initialization and that each claim path only realizes the recipient's configured portion.
- Include a no-double-claim invariant: once a recipient has claimed accrued fees, repeating the same claim without new accrual should not increase payout.
- If creator or owner shares are enabled, assert that recipient payouts still reconcile against total fees and do not leak value across buckets.

Snippet:
```solidity
AddressFeeSplitManager.RecipientShare[] memory recipientShares = new AddressFeeSplitManager.RecipientShare[](1);
recipientShares[0] = AddressFeeSplitManager.RecipientShare({
    recipient: recipientContract,
    share: 100_00000
});

bytes memory initializeData = abi.encode(
    AddressFeeSplitManager.InitializeParams({
        creatorShare: 0,
        ownerShare: 0,
        recipientShares: recipientShares
    })
);

// After launch + fee accrual:
uint claimed = AddressFeeSplitManager(manager).claim();
assertGt(claimed, 0);
```

### `StakingManager` (staking + creator/owner)

Flow:
1. Initialize with staking token + durations + share params.
2. Deposit manager NFT(s) and stake ERC20.
3. Allocate fees and trigger claim cycle.
4. Call `claim()` from staker/creator/owner contexts.
5. Assert staking rewards, creator rewards, owner rewards, and position snapshot updates.

Required minimum for new builds:
- one test for stake -> accrue -> claim happy path,
- one test for staking/unstaking/escrow lock failure path.

Low-level notes:
- The manager still custodies the Flaunch NFT while stakers interact through the manager's staking accounting, so tests should distinguish escrowed asset ownership from reward entitlement.
- Assert timing boundaries explicitly: staking duration, escrow duration, and any unstake restrictions should fail cleanly before maturity and succeed after maturity.
- Reward accounting should separate staker rewards from creator and owner allocations so new stake/unstake events cannot retroactively claim previously earned rewards.

Snippet:
```solidity
bytes memory initializeData = abi.encode(
    StakingManager.InitializeParams({
        stakingToken: address(stakingToken),
        minEscrowDuration: 30 days,
        minStakeDuration: 7 days,
        creatorShare: 10_00000,
        ownerShare: 0
    })
);

// After launch + deposit:
stakingToken.approve(manager, stakeAmount);
StakingManager(manager).stake(stakeAmount);
// ...allocate fees...
uint claimed = StakingManager(manager).claim();
assertGt(claimed, 0);
```

### `BuyBackManager` (creator/owner claims + buyback routing)

Flow:
1. Initialize with `buyBackPoolKey` and share params.
2. Deposit token(s) and accrue fees.
3. Validate creator/owner claim path (if configured).
4. Trigger `routeBuyBack()` and assert funds routed into buyback policy.
5. Keep buyback assertions separate from creator/owner claim assertions.

Required minimum for new builds:
- one test for successful `routeBuyBack`,
- one test for unauthorized/invalid route path revert.

Low-level notes:
- `buyBackPoolKey` is part of the manager's trust boundary. Validate that the pool is initialized and that `hooks` points at a recognized Flaunch `PositionManager`, rather than assuming any `PoolKey` is safe.
- Buyback flow is multi-step: fee withdrawal into the manager, ETH accounting update, flETH wrapping/transfer, then `PoolManager.unlock(...)` for the BidWall deposit path. Tests should isolate failures at each boundary.
- Keep creator/owner claims and buyback routing as separate accounting assertions. Routing buyback funds should not implicitly mutate creator claim state except through the intended fee-withdraw path.
- Reference `BuyBackManager.sol` in the Flaunch contracts repo when you need the exact routing implementation.

Snippet:
```solidity
bytes memory initializeData = abi.encode(
    BuyBackManager.InitializeParams({
        creatorShare: 20_00000,
        ownerShare: 0,
        buyBackPoolKey: buyBackPoolKey
    })
);

// Claim creator/owner side if applicable
BuyBackManager(manager).claim();

// Then route manager fees into buyback policy
uint routed = BuyBackManager(manager).routeBuyBack();
assertGt(routed, 0);
```

### `RevenueManager` (creator + protocol split)

Flow:
1. Initialize with `protocolRecipient` and `protocolFee`.
2. Deposit token(s) for creators.
3. Allocate fees, then execute creator claim and protocol claim paths.
4. Assert creator totals (`creatorTotalClaimed`, `tokenTotalClaimed`) and protocol totals.
5. Validate admin paths (`setProtocolRecipient`, `setCreator`, `rescue`) as needed.

Required minimum for new builds:
- one test for creator + protocol payout correctness,
- one test for invalid admin/creator/protocol path revert.

Low-level notes:
- Treat creator claims and protocol claims as distinct state machines. Tests should prove protocol claims cannot consume creator balances and creator claims cannot consume protocol balances.
- Assert monotonically increasing accounting such as per-token claimed totals and creator aggregate claimed totals; repeated claims without new accrual should settle to zero.
- Validate admin mutation paths separately from payout paths so recipient updates, creator updates, and rescue logic cannot silently corrupt accounting.

Snippet:
```solidity
bytes memory initializeData = abi.encode(
    RevenueManager.InitializeParams({
        protocolRecipient: payable(protocolRecipient),
        protocolFee: 5_00 // 5%
    })
);

// Creator path
ITreasuryManager.FlaunchToken[] memory creatorTokens = new ITreasuryManager.FlaunchToken[](1);
creatorTokens[0] = ITreasuryManager.FlaunchToken({flaunch: flaunch, tokenId: tokenId});
uint creatorClaimed = RevenueManager(manager).claim(creatorTokens);
assertGt(creatorClaimed, 0);

// Protocol recipient path
vm.prank(protocolRecipient);
uint protocolClaimed = RevenueManager(manager).claim();
assertGt(protocolClaimed, 0);
```

### `ERC721OwnerFeeSplitManager` (NFT ownership-based split)

Flow:
1. Initialize with ERC721 share config (`shares`) and creator/owner share params.
2. Deposit manager token(s) and accrue fees.
3. Build `ClaimParams` for NFT holder path and call `claim(bytes)`.
4. Optionally test creator/owner path separately.
5. Assert per-token claim accounting and ownership validation behavior.

Required minimum for new builds:
- one test for valid ownership-based claim success,
- one test for invalid ownership/claim params rejection.

Low-level notes:
- Ownership checks are part of the security model, not just input validation. Tests should prove claims fail for unowned token IDs, duplicated token IDs, malformed arrays, or stale ownership assumptions.
- Claim parameter validation should also prove that per-token accounting cannot be replayed across the same NFT set without new fees accruing.
- If creator or manager-owner side allocations are also enabled, assert that NFT-holder claims do not overrun the non-holder fee buckets.

Snippet:
```solidity
ERC721OwnerFeeSplitManager.ERC721Share[] memory shares = new ERC721OwnerFeeSplitManager.ERC721Share[](1);
shares[0] = ERC721OwnerFeeSplitManager.ERC721Share({
    erc721: nftCollection,
    share: 100_00000,
    totalSupply: totalSupply
});

bytes memory initializeData = abi.encode(
    ERC721OwnerFeeSplitManager.InitializeParams({
        creatorShare: 0,
        ownerShare: 0,
        shares: shares
    })
);

uint[][] memory tokenIds = new uint[][](1);
tokenIds[0] = new uint[](1);
tokenIds[0][0] = ownedTokenId;

bytes memory claimData = abi.encode(
    ERC721OwnerFeeSplitManager.ClaimParams({
        erc721: _toAddressArray(nftCollection),
        tokenIds: tokenIds
    })
);

uint claimed = ERC721OwnerFeeSplitManager(manager).claim(claimData);
assertGt(claimed, 0);
```

Helper:
```solidity
function _toAddressArray(address _single) internal pure returns (address[] memory arr_) {
    arr_ = new address[](1);
    arr_[0] = _single;
}
```

## Shared TreasuryManager Params

- `manager`: approved manager implementation.
- `permissions`: optional permissions contract (`address(0)` allowed).
- `initializeData`: manager-specific ABI-encoded init payload.
- `depositData`: optional manager-specific deposit metadata.

Launch snippet:
```solidity
(address memecoin_, uint ethSpent_, address deployedManager_) = flaunchZap.flaunch({
    _flaunchParams: PositionManager.FlaunchParams({
        name: "Token",
        symbol: "TKN",
        tokenUri: "",
        initialTokenFairLaunch: 0,
        fairLaunchDuration: 0,
        premineAmount: 0,
        creator: creator,
        creatorFeeAllocation: 0,
        flaunchAt: block.timestamp,
        initialPriceParams: abi.encode(""),
        feeCalculatorParams: abi.encode("")
    }),
    _trustedFeeSigner: address(0),
    _premineSwapHookData: "",
    _whitelistParams: FlaunchZap.WhitelistParams({
        merkleRoot: "",
        merkleIPFSHash: "",
        maxTokens: 0
    }),
    _airdropParams: FlaunchZap.AirdropParams({
        airdropIndex: 0,
        airdropAmount: 0,
        airdropEndTime: 0,
        merkleRoot: "",
        merkleIPFSHash: ""
    }),
    _treasuryManagerParams: FlaunchZap.TreasuryManagerParams({
        manager: managerImplementation,
        permissions: address(0),
        initializeData: initializeData,
        depositData: abi.encode("")
    })
});

assertTrue(memecoin_ != address(0));
assertTrue(deployedManager_ != address(0));
assertEq(flaunch.ownerOf(flaunch.tokenId(memecoin_)), deployedManager_);
```

## Manager-Specific `initializeData` Patterns

### `AddressFeeSplitManager`

- `abi.encode(AddressFeeSplitManager.InitializeParams(creatorShare, ownerShare, recipientShares))`
- For direct routing: `creatorShare=0`, `ownerShare=0`, `recipientShares=[(recipient, 100_00000)]`

### `StakingManager`

- `abi.encode(StakingManager.InitializeParams(stakingToken, minEscrowDuration, minStakeDuration, creatorShare, ownerShare))`
- Validate staking flows separately from creator/owner claim accounting

### `BuyBackManager`

- `abi.encode(BuyBackManager.InitializeParams(creatorShare, ownerShare, buyBackPoolKey))`
- Validate creator/owner claim and `routeBuyBack()` in separate assertions

### `RevenueManager`

- `abi.encode(RevenueManager.InitializeParams(protocolRecipient, protocolFee))`
- Validate protocol claim and creator attribution independently

### `ERC721OwnerFeeSplitManager`

- `abi.encode(ERC721OwnerFeeSplitManager.InitializeParams(creatorShare, ownerShare, shares))`
- Claim paths may require encoded `ClaimParams`

## Action Path by Manager

- `AddressFeeSplitManager`: `claim()` (+ creator/owner claim if configured)
- `StakingManager`: stake -> accrue fees -> claim
- `BuyBackManager`: creator/owner claim + `routeBuyBack()`
- `RevenueManager`: creator claim + protocol claim
- `ERC721OwnerFeeSplitManager`: ownership-based `claim(bytes)` + creator/owner path

## Flaunch Params Note

Fair launch is deprecated for new integrations/tests:

- `initialTokenFairLaunch = 0`
- `fairLaunchDuration = 0`

Do not rely on fair-launch bypass helpers for new manager integrations.

## Gotchas

- `vm.deal(manager, amount)` does not trigger manager `receive()` accounting in Foundry-based tests.
- To simulate real fee accounting in Solidity tests, transfer ETH with:
  - `(bool ok,) = payable(manager).call{value: amount}("");`
- Keep mocks test-only; production logic should use Flaunch contracts and interfaces.
- Some managers require more than `claim()` alone, for example `BuyBackManager.routeBuyBack()`.
- Ownership/token-list claim paths require the exact calldata shape expected by the manager.
- `BuyBackManager` requires the implementation to hold the BidWall `POSITION_MANAGER` role before deployed manager instances can route buybacks correctly.
- `deposit(...)` is pull-based from the current NFT owner, so the NFT owner must approve the deployed manager before deposit is called.

## Do / Don't (LLM Safety)

Do:

- Separate manager-policy assertions from generic fee-routing assertions.
- Keep one manager behavior per test path when possible.
- Assert both external balances and manager internal accounting.
- Use realistic fee allocation flow over direct balance mutation.

Don't:

- Assume all managers are fully validated by `claim()` alone.
- Overload one test with multiple policy behaviors.
- Copy large dependency code when imports/harnesses exist.

## Validation Checklist

- Memecoin address from zap is nonzero.
- Flaunch token NFT owner is deployed manager when manager flow is active.
- Manager-specific action path succeeds.
- Recipient action path returns expected claimed amount.
- Manager accounting state updates correctly (claimed totals, protocol fees, staking rewards, creator fees).
- Tests pass in the builder's Solidity test environment.

## Standard Execution Output (LLM)

For every integration/review response, use this fixed structure:

1. `Manager selected`: name + one-line reason.
2. `Inputs used`: manager params, recipient policy, chain (`8453` or `84532`).
3. `Encoding`: exact `initializeData` and `depositData` shape.
4. `Action path`: exact calls in order.
5. `Assertions`: external balances + internal accounting checks.
6. `Gaps / assumptions`: anything missing that can change behavior.

## Output Requirements

When returning implementation/review output, include:

1. chosen manager and why.
2. `initializeData`/`depositData` encoding shape used.
3. claim/action path tested.
4. explicit invariants asserted (balances + internal state).
5. any assumptions or unresolved manager-policy decisions.

## When To Ask Before Proceeding

Ask if missing:

- manager policy choice.
- recipient split semantics (including basis units).
- whether buyback behavior is required in this integration.
- whether tests should prioritize minimal direct-routing path or full manager-policy coverage.

## Suggested Verification

Before shipping a manager integration, verify:

- the chosen manager matches the intended payout policy
- `initializeData` and `depositData` are encoded exactly as expected
- the launch result binds the deployed manager to the launched token
- the manager-specific action path succeeds
- both external payouts and internal accounting reconcile
- repeat claims without new accrual do not leak value
