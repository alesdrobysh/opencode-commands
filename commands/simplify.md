---
description: Simplify code using 3 parallel specialist subagents (minimal diff, readability, risk)
agent: build
---

You are running /simplify.

Arguments: $ARGUMENTS

## Step 1 — Determine scope

If $ARGUMENTS contains file paths or function names, use those as the target scope.
Otherwise infer scope from the most recently discussed code or visible diffs in the conversation.
Write a one-paragraph "scope brief" stating: which files/functions you are targeting and why.

## Step 2 — Launch 3 subagents IN PARALLEL

Use the `batch` tool to execute all 3 `task` calls simultaneously:

- subagent_type: `simplify-minimal` — find the smallest behavior-preserving diff
- subagent_type: `simplify-readability` — find readability/naming/structure improvements
- subagent_type: `simplify-risk` — identify behavior-change risks and required tests

Pass each subagent the full scope brief plus the relevant code (file contents or snippets).

## Step 3 — Aggregate results

Combine the three outputs into:
1. **Recommended plan** — ordered list of changes, prioritized by safety and impact (minimal first)
2. **Proposed patches** — grouped by file, with exact before/after snippets
3. **Risk + verification checklist** — consolidated from the risk subagent, deduped

## Step 4 — Ask before applying

Present the aggregated plan to the user. Ask: "Apply these changes now?"
Only apply edits after explicit confirmation. Keep diffs minimal.
