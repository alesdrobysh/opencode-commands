---
description: Orchestrate large parallel codebase changes with planning, worker tasks, and PR tracking
agent: build
---

You are running /batch.

Arguments: $ARGUMENTS

Goal: execute a large, parallelizable migration/refactor by orchestrating independent worker tasks. Use OpenCode native `batch` for parallel tool calls; do not reimplement batching manually.

If $ARGUMENTS is empty, stop and return:
- a one-line explanation of required input
- 3 examples:
  - `/batch migrate from react-query v4 to v5`
  - `/batch replace lodash get/set usages with native equivalents`
  - `/batch rename legacy API client types to sdk client types`

## Phase 1 - Preflight and planning

1) Verify prerequisites:
- ensure this is a git repository (`git rev-parse --is-inside-work-tree`)
- if not a git repo, stop with a clear error that `/batch` requires git for branch/worktree/PR workflow

2) Research scope in foreground:
- launch one or more `task` calls to `explore` (parallel when useful) to map impacted files, call sites, and conventions
- use `task` with `general` only when deeper reasoning is needed beyond discovery
- keep findings concise and concrete

3) Decompose work into independent units:
- create 5-30 units when scope warrants it; small changes can use fewer units
- each unit must be independently implementable and mergeable
- prefer per-module/per-directory boundaries over arbitrary file lists
- keep unit size roughly uniform

4) Determine e2e verification recipe workers can execute autonomously:
- discover existing e2e/integration scripts, browser/CLI verification paths, or dev-server + endpoint checks
- if no concrete e2e path is inferable, ask the user with the `question` tool and offer 2-3 specific options based on discovered project setup
- write one short shared recipe (or an explicit "skip e2e because ..." instruction)

5) Present plan and wait for explicit approval before execution. Include:
- research summary
- numbered unit list: title, scope (files/directories), one-line change intent
- shared e2e recipe
- worker prompt template you will use

## Phase 2 - Execute workers in parallel (after approval)

After plan approval:

1) Spawn one worker task per unit with `subagent_type: "batch-worker"`.

2) Use the native `batch` tool to launch worker `task` calls in parallel.
- pass each worker a fully self-contained prompt containing:
  - overall goal (`$ARGUMENTS`)
  - the unit title/scope/change intent
  - relevant discovered conventions
  - shared e2e recipe
- run all units in a single `batch` call when unit count <= 25
- if unit count > 25, execute in waves of up to 25 while preserving unit numbering

3) Do not batch operations with dependencies between each other.

## Phase 3 - Track status and aggregate results

Immediately after launch, render status table:

| # | Unit | Status | PR |
|---|------|--------|----|
| 1 | <title> | running | - |

As worker results arrive:
- parse final `PR:` line from each worker
- update status to `done` when PR URL exists
- update status to `failed` when output is `PR: none - <reason>` or missing PR line
- keep a brief failure note per failed unit

When all workers finish, render final table and one-line rollup:
- `<done>/<total> units landed as PRs`

Operational requirements:
- Never execute workers before explicit plan approval.
- Never let one worker modify another unit's intended scope.
- Keep coordinator output concise and execution-focused.
