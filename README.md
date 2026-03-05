# opencode-commands

Custom commands and subagents for [OpenCode](https://github.com/sst/opencode).

## Commands

| Command | Description |
|---------|-------------|
| `/ask` | Read-only codebase Q&A — answers questions with file/line evidence, never modifies files |
| `/simplify` | Fast auto-apply simplification using 3 parallel specialist subagents (reuse, quality, efficiency+risk) |
| `/batch` | Claude-style orchestration for large changes: plan, split into independent units, run parallel worker tasks, and track PR outcomes |
| `/codescene` | Fix CodeScene code smells in parallel — one subagent per file, single verification pass |

## Agents

| Agent | Used by | Description |
|-------|---------|-------------|
| `simplify-minimal` | `/simplify` | Finds smallest safe simplifications and reuse opportunities |
| `simplify-readability` | `/simplify` | Identifies code-quality and readability improvements |
| `simplify-risk` | `/simplify` | Identifies efficiency issues, behavior risks, and verification steps |
| `batch-worker` | `/batch` | Executes one approved unit in an isolated worktree, verifies it, and reports `PR:` status |
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
