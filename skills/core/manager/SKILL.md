---
name: flaunch-manager
description: Build and integrate Flaunch treasury managers, launch memecoins with manager params, and validate fee routing, accounting, claims, buybacks, and permissions on Base and Base Sepolia.
---

# Flaunch Manager Skill

Use this skill when the user is building, testing, or reviewing Flaunch treasury manager integrations.

## Supported chains

- Base Mainnet (`base`) `8453`
- Base Sepolia (`baseSepolia`) `84532`

## Manager router

| Goal | Manager | Primary assertion |
| --- | --- | --- |
| Send fees to fixed addresses | `AddressFeeSplitManager` | recipient balances match configured shares |
| Send fees to stakers | `StakingManager` | staker rewards accrue and claim correctly |
| Execute buyback policy | `BuyBackManager` | buyback route works separately from claim accounting |
| Creator + protocol split only | `RevenueManager` | protocol and creator claims are correct |
| Split by NFT ownership | `ERC721OwnerFeeSplitManager` | ownership-based claims route correctly |

Default for simple vault routing:

- `AddressFeeSplitManager` with `recipientShares = [(recipientContract, 100_00000)]`

## Integration workflow

1. Deploy or set up the Flaunch integration harness.
2. Deploy recipient or consumer contracts if needed.
3. Deploy the manager implementation and approve it in `TreasuryManagerFactory`.
4. Build manager-specific `initializeData` and `depositData`.
5. Launch memecoin via `FlaunchZap.flaunch(...)` with treasury manager params.
6. Capture the deployed manager address from the launch result or events.
7. Execute the manager-specific action path.
8. Assert balances, accounting state, and ownership invariants.

## Base manager lifecycle

1. `initialize(owner, data)` sets `managerOwner`, marks the manager initialized, and forwards into manager-specific `_initialize(owner, data)`.
2. `deposit(flaunchToken, creator, data)` validates the Flaunch contract and creator permissions, transfers custody of the Flaunch ERC721 into the manager, and forwards into manager-specific `_deposit(...)`.
3. Custom manager behavior should normally live in `_initialize` and `_deposit`, not by re-implementing base setup or escrow rules.

## Low-level implementation notes

- Fee balances are not invented locally inside each manager. Managers withdraw from registered fee escrow sources via the base `TreasuryManager` flow, then layer manager-specific accounting and dispatch rules on top.
- Deposit permissions follow the base `TreasuryManager` path: `managerOwner` is always valid, `permissions == address(0)` means open deposits, otherwise `permissions.isValidCreator(...)` gates the deposit.
- Deposited Flaunch NFTs are custodied by the manager contract itself. Base manager logic also provides token timelock and rescue behavior.
- `BuyBackManager` should treat `buyBackPoolKey` as part of the trust boundary and validate the pool plus recognized hook address before routing funds.

## Required tests

- Minimum: one happy-path integration test and one failure-path test.
- Preferred: include accounting assertions for claimed totals, recipient balances, creator/protocol/owner splits, and no-double-claim behavior.
- Do not ship manager integrations without manager-specific tests.

## Output expectations

When helping builders, include:

1. manager selected and why
2. exact `initializeData` and `depositData` encoding shape
3. action path in order
4. external balance assertions plus internal accounting checks
5. assumptions or unresolved manager-policy decisions
