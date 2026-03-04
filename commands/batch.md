---
description: Apply a repeated transformation across many files (parallel reads, safe sequential writes)
agent: build
---

You are running /batch.

Arguments: $ARGUMENTS

## Step 1 — Clarify inputs

Parse $ARGUMENTS for:
- **Target files**: glob pattern, directory, or description (e.g. `src/**/*.ts`, `all test files`)
- **Transformation**: what change to make (e.g. `rename foo to bar`, `add null check before .map(`)
- **Mode**: `propose` (default — show patches first) or `apply` (apply immediately)

If any of the above is missing or ambiguous, ask the user before continuing.

## Step 2 — Discover target files

Use glob/grep tools to enumerate all matching files. Show the user the list and ask for confirmation if it exceeds 10 files.

## Step 3 — Analyze in parallel

Use the `batch` tool to read all target files simultaneously (or grep for the relevant pattern). Keep individual reads focused — only fetch the lines needed for the transformation.

## Step 4 — Produce a summary table

For each file, output:

| File | Change summary | Risk (low/med/high) |
|------|---------------|---------------------|

Flag `high` risk if the change affects exported symbols, touches tests, or is non-trivial.

## Step 5 — Confirm before writing

Present the table and proposed patches. Ask: "Apply all changes?" (or list high-risk ones separately for selective approval).

## Step 6 — Apply edits

Apply changes sequentially (one file at a time). After all edits, provide:
- Final recap: N files changed
- Suggested verification: test command to run, grep to confirm the pattern is gone
