---
description: Fast simplification of uncommitted changes using 3 parallel specialist subagents (reuse, quality, efficiency)
agent: build
---

You are running /simplify.

Arguments: $ARGUMENTS

Default mode: auto-apply. Do not ask for confirmation unless the user explicitly asks for preview/plan mode.

If $ARGUMENTS contains `plan`, `preview`, `dry-run`, or `no-apply`, switch to plan mode and do not edit files.

## Step 1 - Identify scope quickly

Collect uncommitted changes with:
- `git diff`
- `git diff --cached`

If both are empty, tell the user there are no uncommitted changes and stop.

Build a compact scope brief:
- changed files
- staged/unstaged status
- optional user focus from $ARGUMENTS

Do not pre-read full file context for every changed file. Start from diff-first context for speed.

## Step 2 - Launch 3 review subagents in parallel

Launch all three `task` calls concurrently in one message (no sequential waiting, no extra wrapper command):

- `simplify-minimal` - prioritize reuse and smallest safe diff
- `simplify-readability` - identify quality and maintainability issues in changed code
- `simplify-risk` - identify efficiency concerns, behavior risks, and verification needs

Pass each subagent the same compact input:
- scope brief
- combined raw diff
- user focus from $ARGUMENTS

Tell subagents to return concise findings, not full-file rewrites.

## Step 3 - Aggregate and prioritize

Merge subagent findings into one ordered action list:
1. minimal safe simplifications and reuse wins
2. code quality/readability improvements
3. efficiency improvements and risk mitigations

Drop duplicates and obvious false positives.

## Step 4 - Apply edits immediately (default)

In auto-apply mode:
- implement the prioritized fixes directly
- keep edits minimal and scoped to changed files when possible
- only touch lines outside changed files if required for correctness
- if a suggestion is risky or uncertain, skip it and note why

In plan mode:
- provide the ordered plan and proposed patch snippets
- do not apply edits

## Step 5 - Verification

Run focused verification when possible:
- targeted tests for changed areas
- or lightweight project checks relevant to the modified files

If you cannot run verification, provide exact commands for the user.

## Step 6 - Report

Return a concise summary:
- what was changed (or planned, in plan mode)
- what was skipped and why
- verification results/checklist
