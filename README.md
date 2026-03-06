# opencode-commands

Custom commands and subagents for [OpenCode](https://github.com/sst/opencode).

## Commands

| Command | Description |
|---------|-------------|
| `/ask` | Read-only codebase Q&A — answers questions with file/line evidence, never modifies files |
| `/simplify` | Fast auto-apply simplification using 3 parallel specialist subagents (reuse, quality, efficiency+risk) |
| `/batch` | Claude-style orchestration for large changes: plan, split into independent units, run parallel worker tasks, and track PR outcomes |
| `/codescene` | Fix CodeScene code smells in parallel — one subagent per file, single verification pass |
| `/e2e-gen` | Generate, validate, and propose a Playwright E2E test from one or two GitLab MRs and a scenario description |

## Agents

| Agent | Used by | Description |
|-------|---------|-------------|
| `simplify-minimal` | `/simplify` | Finds smallest safe simplifications and reuse opportunities |
| `simplify-readability` | `/simplify` | Identifies code-quality and readability improvements |
| `simplify-risk` | `/simplify` | Identifies efficiency issues, behavior risks, and verification steps |
| `batch-worker` | `/batch` | Executes one approved unit in an isolated worktree, verifies it, and reports `PR:` status |
| `codescene-fixer` | `/codescene` | Fixes CodeScene code smells in a single file |
| `e2e-writer` | `/e2e-gen` | Writes a complete Playwright spec file from MR context and a selector inventory |
| `e2e-reviewer` | `/e2e-gen` | Reviews generated specs for coverage, selector quality, and flakiness risks |

## Install

```bash
git clone https://github.com/alesdrobysh/opencode-commands.git
cd opencode-commands
./install.sh
```

To update later, pull and re-run the installer:

```bash
./install.sh --pull
```

**Options:**

| Flag | Description |
|------|-------------|
| `--pull` | Run `git pull` before installing |
| `--dry-run` | Show what would change without making any edits |

## Requirements

- [OpenCode](https://github.com/sst/opencode)
- `/codescene` requires the [CodeScene CLI](https://codescene.com/engineering-intelligence/code-health/) (`cs`) to be installed and authenticated
- `/e2e-gen` requires an `e2e-gen.config.json` file in the opencode-commands directory (see `e2e-gen.config.example.json`), the GitLab MCP server, and the Chrome DevTools MCP server
