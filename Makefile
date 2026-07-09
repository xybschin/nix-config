CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

# /bin/sh doesn't source the user profile; add the nix profile paths so
# home-manager / nixos-rebuild / darwin-rebuild are resolvable.
export PATH := $(HOME)/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$(PATH)

nixos:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

darwin:
	CONFIG_ROOT=$(CONFIG_ROOT) darwin-rebuild switch --flake .#$(host)

home:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#$(user)@$(host)

.PHONY: nixos darwin home
