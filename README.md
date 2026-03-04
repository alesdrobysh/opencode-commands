# opencode-commands

Custom commands and subagents for [OpenCode](https://github.com/sst/opencode).

## Commands

| Command | Description |
|---------|-------------|
| `/ask` | Read-only codebase Q&A — answers questions with file/line evidence, never modifies files |
| `/simplify` | Simplify code using 3 parallel specialist subagents (minimal diff, readability, risk) |
| `/batch` | Apply a repeated transformation across many files (parallel reads, safe sequential writes) |
| `/codescene` | Fix CodeScene code smells in parallel — one subagent per file, single verification pass |

## Agents

| Agent | Used by | Description |
|-------|---------|-------------|
| `simplify-minimal` | `/simplify` | Proposes the smallest safe simplification with minimal diff |
| `simplify-readability` | `/simplify` | Improves readability and consistency while preserving behavior |
| `simplify-risk` | `/simplify` | Identifies behavior-change risks and edge cases in proposed simplifications |
| `codescene-fixer` | `/codescene` | Fixes CodeScene code smells in a single file |

## Install

Copy (or symlink) the directories into your OpenCode config folder:

```bash
git clone https://github.com/alesdrobysh/opencode-commands.git
cd opencode-commands

# Copy
cp -r commands/* ~/.opencode/commands/
cp -r agents/* ~/.opencode/agents/

# Or symlink the whole folders (keeps them in sync with git pull)
ln -s "$PWD/commands" ~/.opencode/commands
ln -s "$PWD/agents" ~/.opencode/agents
```

> **Note:** If `~/.opencode/commands/` or `~/.opencode/agents/` already exist, use the copy approach and merge files manually.

## Requirements

- [OpenCode](https://github.com/sst/opencode)
- `/codescene` requires the [CodeScene CLI](https://codescene.com/engineering-intelligence/code-health/) (`cs`) to be installed and authenticated
