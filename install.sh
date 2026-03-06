#!/usr/bin/env bash
set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=false
PULL=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --pull)    PULL=true ;;
    --help|-h)
      echo "Usage: $0 [--dry-run] [--pull]"
      echo ""
      echo "  --dry-run   Show what would be installed without making changes"
      echo "  --pull      Run 'git pull' before installing"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Run '$0 --help' for usage." >&2
      exit 1
      ;;
  esac
done

log()  { echo "  $*"; }
warn() { echo "  [warn] $*"; }
run()  {
  if $DRY_RUN; then
    echo "  [dry-run] $*"
  else
    eval "$@"
  fi
}

# Verify we're in the repo root
if [[ ! -d "$SCRIPT_DIR/commands" || ! -d "$SCRIPT_DIR/agents" ]]; then
  echo "Error: must be run from the opencode-commands repository root." >&2
  exit 1
fi

echo "opencode-commands installer"
echo ""

# Optional git pull
if $PULL; then
  echo "Updating repository..."
  run "git -C \"$SCRIPT_DIR\" pull"
  echo ""
fi

# Create ~/.opencode if missing
if [[ ! -e "$OPENCODE_DIR" ]]; then
  log "Creating $OPENCODE_DIR"
  run "mkdir -p \"$OPENCODE_DIR\""
elif [[ ! -d "$OPENCODE_DIR" ]]; then
  echo "Error: $OPENCODE_DIR exists but is not a directory." >&2
  exit 1
fi

installed=0
updated=0

install_dir() {
  local src_dir="$1"    # e.g. ./commands
  local name="$2"       # e.g. commands
  local target="$OPENCODE_DIR/$name"

  echo "Installing $name/..."

  # Handle existing symlink (old install method)
  if [[ -L "$target" ]]; then
    warn "$target is a symlink — replacing with a real directory"
    run "rm \"$target\""
  fi

  # Create target dir if missing
  if [[ ! -d "$target" ]]; then
    log "Creating $target"
    run "mkdir -p \"$target\""
  fi

  # Copy each .md file
  for src_file in "$src_dir"/*.md; do
    [[ -e "$src_file" ]] || continue   # glob found nothing
    local filename
    filename="$(basename "$src_file")"
    local dest="$target/$filename"

    if [[ -e "$dest" ]]; then
      log "Updating $name/$filename"
      (( updated++ )) || true
    else
      log "Installing $name/$filename"
      (( installed++ )) || true
    fi
    run "cp \"$src_file\" \"$dest\""
  done
}

install_dir "$SCRIPT_DIR/commands" "commands"
install_dir "$SCRIPT_DIR/agents"   "agents"

# e2e-gen config hint
config_src="$SCRIPT_DIR/e2e-gen.config.json"
config_dest="$OPENCODE_DIR/e2e-gen.config.json"
if [[ ! -e "$config_src" && ! -e "$config_dest" ]]; then
  echo ""
  warn "No e2e-gen.config.json found. To use /e2e-gen, copy the example:"
  warn "  cp \"$SCRIPT_DIR/e2e-gen.config.example.json\" \"$config_dest\""
  warn "  # then edit it with your repo paths"
fi

echo ""
if $DRY_RUN; then
  echo "Dry run complete — no changes were made."
else
  echo "Done. Installed: $installed  Updated: $updated"
fi
