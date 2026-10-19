CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

nixos:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

nixos-remote:
	@test -n "$(target)" || { echo "usage: make nixos-remote host=<name> target=<address>"; exit 1; }
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure --flake .#$(host) --target-host root@$(target)

nixos-install:
	./scripts/nixos-install.sh "$(host)" "$(target)"

# Add a WireGuard client to atlas: generate keys, register, deploy, commit.
# usage: make wg-peer name=<device> [args="--home-lan"]
wg-peer:
	@test -n "$(name)" || { echo "usage: make wg-peer name=<device> [args=\"--home-lan\"]"; exit 1; }
	./scripts/wg-add-peer.sh "$(name)" --deploy --commit $(args)

darwin:
	CONFIG_ROOT=$(CONFIG_ROOT) darwin-rebuild switch --flake .#$(host)

home:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#$(user)@$(host)

up:
	nix flake update
	git add flake.lock
	git commit -m "chore: bump dependencies"

check:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 ./scripts/check.sh

.PHONY: nixos nixos-remote nixos-install wg-peer darwin home up check clean-all

clean-all:
	sudo nix-collect-garbage -d
	nix-store --optimise
	rm -f result result-*
