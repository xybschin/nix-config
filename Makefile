CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

build-host:
	CONFIG_ROOT=$(CONFIG_ROOT) nixos-rebuild switch --sudo --impure --flake .#$(host)

build-user:
	CONFIG_ROOT=$(CONFIG_ROOT) home-manager switch --impure --flake .#$(user)

.PHONY: build-host build-user
