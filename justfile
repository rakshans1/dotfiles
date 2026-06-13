set shell := ["bash", "-Eeuo", "pipefail", "-c"]

default:
    @just --list --unsorted

check-format: shell-check-format nix-check-format

fix-format:
    @echo "📝 Fixing all formatting..."
    @just shell-fix-format
    @just nix-fix-format
    @echo "✅ All formatting fixed!"

check-code:
    @echo "🔍 Checking all code quality..."
    @just shell-check-code
    @echo "✅ All code quality checks passed!"

shell-ls:
  #!/usr/bin/env bash
  set -euo pipefail
  # Find .sh files and bin/* files, but exclude non-shell scripts and common directories
  find . \( -name node_modules -o -name .git -o -name .cache \) -prune -o \
    \( -name '*.sh' -o -path './bin/*' \) -type f -not -type l -print 2>/dev/null | while read -r file; do
    # Check if file has a shell shebang
    if head -n1 "$file" | grep -qE '^#!/.*(bash|sh|zsh)'; then
      echo "$file"
    fi
  done | sort

# Check shell formatting
shell-check-format:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(just shell-ls)
  [ -z "$files" ] && echo "✅ No shell scripts" && exit 0

  echo "📝 Checking shell formatting..."
  if echo "$files" | xargs -r shfmt -d -i 2; then
    echo "✅ Shell formatting OK"
  else
    echo "❌ Format issues (run: just shell-fix-format)"
    exit 1
  fi

shell-check-code:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(just shell-ls)
  [ -z "$files" ] && echo "✅ No shell scripts" && exit 0

  echo "🔍 Checking shell code..."
  if command -v shellcheck >/dev/null 2>&1; then
    if echo "$files" | xargs -r shellcheck; then
      echo "✅ Shellcheck OK"
    else
      echo "❌ Shellcheck issues found"
      exit 1
    fi
  else
    echo "⚠️  shellcheck not installed, skipping"
  fi

# Fix shell formatting
shell-fix-format:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(just shell-ls)
  [ -z "$files" ] && echo "✅ No shell scripts" && exit 0

  echo "📝 Fixing shell formatting..."
  echo "$files" | xargs -r shfmt -w -i 2 2>/dev/null || true
  echo "✅ Done"

# Combined check
shell-check: shell-check-format shell-check-code

# Combined fix
shell-fix: shell-fix-format

nix-ls:
  @find . -name '*.nix' -type f -not -type l -print 2>/dev/null | sort

# Check Nix formatting
nix-check-format:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(just nix-ls)
  [ -z "$files" ] && echo "✅ No Nix files" && exit 0

  echo "📝 Checking Nix formatting..."
  if command -v nixfmt >/dev/null 2>&1; then
    if echo "$files" | xargs -r nixfmt --check; then
      echo "✅ Nix formatting OK"
    else
      echo "❌ Format issues (run: just nix-fix-format)"
      exit 1
    fi
  else
    echo "⚠️  nixfmt not installed, skipping"
  fi

# Fix Nix formatting
nix-fix-format:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(just nix-ls)
  [ -z "$files" ] && echo "✅ No Nix files" && exit 0

  echo "📝 Fixing Nix formatting..."
  if command -v nixfmt >/dev/null 2>&1; then
    echo "$files" | xargs -r nixfmt
    echo "✅ Done"
  else
    echo "⚠️  nixfmt not installed, skipping"
  fi

# Combined check
nix-check: nix-check-format

# Combined fix
nix-fix: nix-fix-format

# Run neovim flake
rvim-run:
    cd config/rvim && nix run .#

alias rvim := rvim-run

# Show neovim flake output
rvim-show:
    cd config/rvim && nix flake show

# Update neovim flake
rvim-update:
    cd config/rvim && nix flake update

# Check neovim flake
rvim-check:
    cd config/rvim && nix flake check

# Update invideo flake inputs (iv + invideo-cli) in the private flake
invideo-update:
    cd private && nix flake update --allow-dirty-locks iv invideo-cli

secrets-edit:
  sops private/secrets/common.yaml

secrets-view:
  sops -d private/secrets/common.yaml
