.ONESHELL:
SHELL := /bin/bash
.PHONY: help all profile zsh tmux neovim tools asdf
.DEFAULT_GOAL := help
CURRENT_FOLDER := $(shell basename "$$(pwd)")
BOLD := $(shell tput bold)
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RESET := $(shell tput sgr0)

## Global
NAME := main
VERSION := scratch
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$$/arm64/')

## Paths
DOTFILES := $(shell pwd)

## Burn, baby, burn
help: ## Shows this makefile help
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: asdf profile ## Install everything
	@echo "$(BOLD)$(GREEN)All installation completed successfully$(RESET)"

profile: zsh tmux neovim ## Install ZSH, Tmux, and Neovim profiles
	@echo "$(BOLD)$(GREEN)Profile installation completed$(RESET)"

tools: ## Install development tools
	$(MAKE) all -C tools

asdf: ## Install asdf (always latest version)
	@echo "$(BOLD)$(GREEN)Installing/Updating ASDF$(RESET)"
	@set -e; \
	ASDF_VERSION=$$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'); \
	if [ -z "$$ASDF_VERSION" ]; then \
		echo "$(RED)Failed to fetch latest ASDF version$(RESET)"; \
		exit 1; \
	fi; \
	echo "Latest ASDF version: $$ASDF_VERSION"; \
	if command -v asdf >/dev/null 2>&1; then \
		CURRENT_VERSION=$$(asdf version | awk '{print $$1}' | sed 's/v//'); \
		if [ "$$CURRENT_VERSION" = "$$ASDF_VERSION" ]; then \
			echo "$(GREEN)ASDF is already up to date (v$$ASDF_VERSION)$(RESET)"; \
			exit 0; \
		else \
			echo "$(YELLOW)Updating ASDF from v$$CURRENT_VERSION to v$$ASDF_VERSION$(RESET)"; \
		fi; \
	fi; \
	mkdir -p ${HOME}/bin; \
	wget -q "https://github.com/asdf-vm/asdf/releases/download/v$$ASDF_VERSION/asdf-v$$ASDF_VERSION-linux-$(ARCH).tar.gz" -O ${HOME}/asdf-linux.tar.gz; \
	tar -xzf ${HOME}/asdf-linux.tar.gz -C ${HOME}/bin; \
	rm ${HOME}/asdf-linux.tar.gz; \
	echo "$(GREEN)ASDF v$$ASDF_VERSION installation completed successfully$(RESET)"

zsh: ## Install ZSH profile
	@echo "$(BOLD)Setting up ZSH shell$(RESET)"
	@set -e; \
	if ! command -v zsh >/dev/null 2>&1; then \
		echo "$(RED)Error: ZSH is not installed. Please install it first.$(RESET)"; \
		exit 1; \
	fi
ifeq ($(OS), linux)
	@if [ "$$(getent passwd ${USER} | cut -d: -f7)" != "/bin/zsh" ]; then \
		echo "Setting ZSH as default shell for user"; \
		sudo usermod --shell /bin/zsh ${USER}; \
	else \
		echo "$(YELLOW)ZSH is already the default shell$(RESET)"; \
	fi
endif
	@rm -f ${HOME}/.zshrc ${HOME}/.zsh.d
	@ln -s -f ${DOTFILES}/zshrc ${HOME}/.zshrc
	@ln -s -f ${DOTFILES}/zsh.d ${HOME}/.zsh.d
	@echo "$(GREEN)ZSH configured$(RESET)"

neovim: ## Install Vim/Neovim profile
	@echo "$(BOLD)Setting up NeoVIM$(RESET)"
	@set -e; \
	mkdir -p ${HOME}/.config/nvim; \
	ln -s -f ${DOTFILES}/vimrc ${HOME}/.config/nvim/init.vim; \
	ln -s -f ${DOTFILES}/vimrc ${HOME}/.vimrc; \
	echo "$(GREEN)NeoVIM configured$(RESET)"

tmux: ## Install TMUX profile
	@echo "$(BOLD)Setting up TMUX$(RESET)"
	@set -e; \
	if ! command -v tmux >/dev/null 2>&1; then \
		echo "$(YELLOW)Warning: tmux is not installed$(RESET)"; \
	fi; \
	ln -s -f ${DOTFILES}/tmux.conf ${HOME}/.tmux.conf; \
	ln -s -f ${DOTFILES}/tmux.local ${HOME}/.tmux.conf.local; \
	echo "$(GREEN)TMUX configured$(RESET)"
