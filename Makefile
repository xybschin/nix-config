.DEFAULT_GOAL := nixos

CONFIG_ROOT := "$(shell git rev-parse --show-toplevel)"
host ?= $(shell hostname)

# Coding agents for this rebuild (claude copilot opencode, or none).
# Precedence: with= arg > .feature-overrides (gitignored, persists) > host default.
with ?=
CODING_AGENTS = "$(strip $(if $(with),$(with),$(shell cat $(CONFIG_ROOT)/.feature-overrides 2>/dev/null)))"

submodules:
	git submodule update --init --recursive

nixos: submodules
	CONFIG_ROOT=$(CONFIG_ROOT) CODING_AGENTS=$(CODING_AGENTS) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

nixos-remote: submodules
	@test -n "$(target)" || { echo "usage: make nixos-remote host=<name> target=<address>"; exit 1; }
	CONFIG_ROOT=$(CONFIG_ROOT) CODING_AGENTS=$(CODING_AGENTS) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure --flake .#$(host) --target-host root@$(target)

nixos-install: submodules
	./scripts/nixos-install.sh "$(host)" "$(target)"

# Add a WireGuard client to atlas: generate keys, register, deploy, commit.
# usage: make wg-peer name=<device> [args="--home-lan"]
wg-peer:
	@test -n "$(name)" || { echo "usage: make wg-peer name=<device> [args=\"--home-lan\"]"; exit 1; }
	./scripts/wg-add-peer.sh "$(name)" --deploy --commit $(args)

darwin: submodules
	CONFIG_ROOT=$(CONFIG_ROOT) CODING_AGENTS=$(CODING_AGENTS) NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake .#$(host)

up:
	nix flake update
	git add flake.lock
	git commit -m "chore: bump dependencies"

check:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 ./scripts/check.sh

.PHONY: submodules nixos nixos-remote nixos-install wg-peer darwin up check clean-all

clean-all:
	sudo nix-collect-garbage -d
	nix-store --optimise
	rm -f result result-*
