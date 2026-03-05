---
description: Resolve CodeScene code smells (parallel, one subagent per file)
agent: codescene
---

You are running /codescene.

Arguments: $ARGUMENTS

## Step 1 — Discover smells

Run `cs delta` to get the current list of code smells. Parse the output and group smells by file.

## Step 2 — Show summary and confirm

Display a table of affected files:

| File | Smells | Count |
|------|--------|-------|

If more than 5 files are affected, ask the user to confirm before proceeding.

## Step 3 — Fix in parallel

Use the `batch` tool to spawn one `codescene-fixer` task per file simultaneously.

For each file, pass:
- The file path
- The list of smells for that file (name, location, description as reported by `cs delta`)

## Step 4 — Verify

After all parallel tasks complete, run `cs delta` once to check remaining smells.

## Step 5 — Report

Output a final summary:
- N smells fixed across M files
- Remaining smells (if any): list them with file and smell name
- Skipped smells (if any): list them with reason
