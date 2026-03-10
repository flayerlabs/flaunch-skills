---
name: flaunch-manager-zap-wrapper
description: Build custom wrapper zaps around FlaunchZap that force a specific treasury manager policy and default manager params, then validate launch binding, post-launch init, and payout/accounting behavior.
---

# Flaunch Manager Zap Wrapper Skill

Use this skill when the user wants a custom launch entrypoint that always routes through a chosen manager policy.

This skill depends on the broader manager model. Read `../../core/manager/SKILL.md` when you need the full manager lifecycle, encoding, custody, and accounting context behind the wrapper zap flow.

## What this covers

- custom wrapper contracts around `FlaunchZap`
- forcing `_treasuryManagerParams.manager`
- setting wrapper defaults for `permissions`, `initializeData`, and `depositData`
- binding launched tokens to the intended manager
- post-launch manager init or deposit logic
- required wrapper-zap test coverage

## Standard pattern

1. deploy custom manager implementation
2. approve it in `TreasuryManagerFactory`
3. deploy wrapper zap that calls `FlaunchZap.flaunch(...)`
4. force manager-related defaults inside the wrapper
5. launch through the wrapper
6. assert the resulting token is bound to the intended manager

## Required tests

- happy path proving wrapper launch binds the intended manager
- failure path for invalid params or unauthorized config
- post-launch integration test for manager-specific init or deposit logic
- payout and accounting test verifying the manager policy is actually enforced

## Why this is advanced

- it depends on manager internals plus launch orchestration
- it is not the lowest-parameter path to shipping
- it should only be used when the launch flow itself must enforce a manager policy

## Related source skill

- Full manager guidance: `../../core/manager/SKILL.md`
