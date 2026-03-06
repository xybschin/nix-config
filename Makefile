CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)

switch:
	@echo "Rebuilding configuration for $(host) with DOTFILES_DIR=$(DOTFILES_DIR)"
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 NIXPKGS_ALLOW_UNFREE=1 \
		nixos-rebuild --sudo --impure switch --flake .#$(host)
	exec $$SHELL

.PHONY: switch
