CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

build-host:
	@echo "Rebuilding configuration for host $(host) with CONFIG_ROOT=$(CONFIG_ROOT)"
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 NIXPKGS_ALLOW_UNFREE=1 \
		nixos-rebuild --sudo --impure switch --flake .#$(host)
	exec $$SHELL

build-user:
	@echo "Rebuilding configuration for user $(user) with CONFIG_ROOT=$(CONFIG_ROOT)"
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 NIXPKGS_ALLOW_UNFREE=1 \
		home-manager switch \
		--impure \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		--flake .#$(user)

	exec $$SHELL

.PHONY: build-host build-user
