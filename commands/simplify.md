---
description: Simplify uncommitted changes using 3 parallel specialist subagents (minimal diff, readability, risk)
agent: build
---

You are running /simplify.

Arguments: $ARGUMENTS

## Step 1 — Gather uncommitted changes

Run `git diff` (unstaged) and `git diff --cached` (staged) to collect all uncommitted changes.
If both are empty, tell the user there are no uncommitted changes and stop.

Parse the diff output to build a list of affected files and the specific changed hunks in each.

If $ARGUMENTS contains additional filters (e.g. file paths, function names), narrow the scope to only matching files/hunks.

## Step 2 — Build scope brief

Write a one-paragraph "scope brief" stating:
- Which files have uncommitted changes
- How many hunks / lines changed per file
- Whether changes are staged, unstaged, or both

## Step 3 — Read full context for changed regions

For each affected file, read enough surrounding context around the changed hunks (at least 30 lines above and below) so the subagents can reason about behavior.

## Step 4 — Launch 3 subagents IN PARALLEL

Use the `batch` tool to execute all 3 `task` calls simultaneously:

- subagent_type: `simplify-minimal` — find the smallest behavior-preserving simplification of the uncommitted changes
- subagent_type: `simplify-readability` — find readability/naming/structure improvements within the uncommitted changes
- subagent_type: `simplify-risk` — identify behavior-change risks and required tests for the uncommitted changes

Pass each subagent the scope brief, the raw diffs, and the surrounding code context.

## Step 5 — Aggregate results

Combine the three outputs into:
1. **Recommended plan** — ordered list of changes, prioritized by safety and impact (minimal first)
2. **Proposed patches** — grouped by file, with exact before/after snippets (only touching lines within the uncommitted diff)
3. **Risk + verification checklist** — consolidated from the risk subagent, deduped

## Step 6 — Ask before applying

Present the aggregated plan to the user. Ask: "Apply these changes now?"
Only apply edits after explicit confirmation. Keep diffs minimal — do not modify code outside the uncommitted change regions unless strictly necessary for correctness.
