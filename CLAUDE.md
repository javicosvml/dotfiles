# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Documentation Style Guide

**IMPORTANT: NO EMOJIS IN DOCUMENTATION**
- NEVER use emojis in any documentation files (README.md, comments, commit messages, etc.)
- Keep documentation clean, professional, and emoji-free
- Use clear text formatting instead (bold, italics, lists, code blocks)
- This applies to all files: Markdown, code comments, configuration files

## Repository Overview

This is a **dotfiles repository** for Linux development environments. It provides a production-ready, self-contained terminal configuration system with ZSH, Tmux, Neovim, and development tools. The repository is designed to work offline and supports air-gapped environments.

## Architecture

### Flat Repository Structure
The repository has a flat structure with all configuration files at the root level:
- **Root Makefile** (`/Makefile`) - Manages all installations (profile configs, asdf, tools)
- **Tools Makefile** (`/tools/Makefile`) - Installs development tools (pre-commit, cheat, checkmake)
- Configuration files (zshrc, vimrc, tmux.conf, etc.) are at the root

All Makefiles follow strict best practices:
- Use `.ONESHELL:` for multi-line recipes
- Use `SHELL := /bin/bash` (not `.SHELL`)
- Declare all non-file targets as `.PHONY`
- Use `:=` for variable assignment (immediate expansion)
- Include colored output using tput
- Self-documenting with `## comments` for help target
- Idempotent operations (safe to run multiple times)

### Configuration Directory Structure
```
zsh.d/           # Modular ZSH configuration
├── alias.zsh          # Command aliases
├── autocomplete.zsh   # Tool completions
├── config.zsh         # User configurations (tmux auto-start settings)
├── tmux.zsh           # Tmux helpers and functions
├── toolbox.zsh        # Toolbox function
└── tools.zsh          # Tool initialization and PATH setup
```

The `zshrc` file sources all files from `zsh.d/` to enable modular configuration.

### Tmux Configuration
- **tmux.conf** - Optimized configuration (129 lines, 93% smaller than original)
- **tmux.conf.original** - Full Oh my tmux! config (1889 lines) - kept as reference
- **tmux.local** - User customizations and overrides

The optimized config assumes tmux 3.2+ and removes deprecated options, embedded shell scripts, and complex version checks while keeping all core functionality.

### Version Management
Uses **asdf** for managing tool versions. The root Makefile dynamically fetches the latest asdf version from GitHub releases.

## Common Commands

### Setup and Installation
```bash
# Install everything (profile + asdf)
make all

# Install only profile configurations (ZSH, Tmux, Neovim)
make profile

# Install development tools (requires asdf)
make tools

# Install specific components
make zsh
make tmux
make neovim
make asdf
```

### Development Tools
```bash
# Install pre-commit hooks
make pre-commit -C tools
pre-commit install

# Lint Makefiles
checkmake Makefile

# Run all pre-commit hooks manually
pre-commit run --all-files
```

### Tmux Management
```bash
# List sessions
tmux list-sessions
tl  # alias

# Create new session
tmux new-session -s <name>
tn <name>  # alias

# Attach to session
tmux attach-session -t <name>
ta <name>  # alias

# Kill session
tmux kill-session -t <name>
tk <name>  # alias
```

## Important Configuration Details

### Tmux Auto-Start
Tmux auto-start is configured in `zsh.d/config.zsh` and `zsh.d/tmux.zsh`. Key environment variables:
- `TMUX_AUTOSTART_ENABLED` (default: true) - Enable/disable tmux auto-start
- `TMUX_AUTOSTART_SESSION` (default: "default") - Default session name
- `TMUX_SKIP_SSH` (default: false) - Skip in SSH sessions
- `TMUX_SKIP_IDE` (default: true) - Skip in VSCode/Emacs
- `TMUX_SKIP_DESKTOP` (default: true) - Skip in graphical desktop environments
- `TMUX_SKIP_DESKTOP_SESSIONS` - Comma-separated list of desktop sessions to skip

### Profile Installation Paths
The Makefile uses symlinks to connect configurations from the repository root:
- `~/.zshrc` → `$DOTFILES/zshrc`
- `~/.zsh.d` → `$DOTFILES/zsh.d`
- `~/.tmux.conf` → `$DOTFILES/tmux.conf`
- `~/.tmux.conf.local` → `$DOTFILES/tmux.local`
- `~/.vimrc` → `$DOTFILES/vimrc`
- `~/.config/nvim/init.vim` → `$DOTFILES/vimrc`

Note: `$DOTFILES` is set to the current directory using `$(shell pwd)` in the Makefile, making it work regardless of where the repository is cloned.

### ASDF Integration
The root Makefile fetches the latest asdf version dynamically and installs it to `~/bin/asdf`. Tools that depend on asdf should:
1. Check for asdf with `check-asdf` target
2. Use the ASDF variable: `ASDF := $(shell command -v asdf 2>/dev/null || echo "${HOME}/.asdf/bin/asdf")`

### Self-Contained Design
Profile configurations (ZSH, Tmux, Neovim) work completely offline - no internet required. Only tool installations (asdf, pre-commit, checkmake, cheat) require internet on first install.

## Development Workflow

### Making Changes to Makefiles
1. Use checkmake to validate: `checkmake Makefile`
2. Test with dry-run: `make -n <target>`
3. Verify idempotency by running twice
4. Pre-commit hooks will auto-validate on commit

### Updating External Configurations
```bash
# Update tmux.conf from upstream
curl -o profile/tmux.conf.original \
  https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf

# Commit the update
git add profile/tmux.conf.original
git commit -m "Update tmux.conf from upstream"
```

### Adding New Tools
1. Add installation target to appropriate Makefile (tools/container/cloud)
2. Make it idempotent (check if already installed)
3. Use colored output (GREEN for success, YELLOW for warnings, RED for errors)
4. Add help comment with `##`
5. Add to dependencies of `all` or `tools` target

## Code Style and Conventions

### Makefile Variables
- Always use `:=` for immediate expansion
- Define standard variables: NAME, VERSION, OS, ARCH
- Use tput for colors: `BOLD`, `RED`, `GREEN`, `YELLOW`, `RESET`
- Path variables: `DOTFILES`, `PROFILE`, `TOOLS`, etc.

### Makefile Targets
- All targets should be `.PHONY` unless they create files
- Use `@set -e;` for error handling in multi-line recipes
- Provide user feedback with colored echo statements
- Check prerequisites before running (e.g., command existence)

### Shell Configuration
- Break ZSH config into logical files in `zsh.d/`
- Use guards for conditional features: `command -v tool >/dev/null 2>&1`
- Export configuration variables with defaults: `${VAR:-default}`
- Keep tmux integration separate in `tmux.zsh`

## Recent Restructuring
The repository was recently restructured from a hierarchical to a flat layout:
- **Old structure**: Files in subdirectories (`profile/`, `cloud/`, `container/`, `scripts/`)
- **New structure**: Configuration files moved to root level
- The Makefile was updated to work with the new flat structure
- `DOTFILES` path now uses `$(shell pwd)` instead of hardcoded `${HOME}/.dotfiles`

## Platform Support
- Primary platform: Linux (Ubuntu/Debian)
- Tested on: Darwin (macOS)
- Architecture detection: Handles x86_64/amd64 and arm64/aarch64
- Shell requirement: ZSH (checks and sets as default on Linux)
- to memorize