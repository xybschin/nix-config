CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

nixos:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

darwin:
	CONFIG_ROOT=$(CONFIG_ROOT) darwin-rebuild switch --flake .#$(host)

home:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#$(user)@$(host)

.PHONY: nixos darwin home check clean-all

# Evaluate (not build) every configuration; fails if any one doesn't evaluate.
check:
	@export CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1; fail=0; \
	check() { \
		names=$$(nix eval --impure --raw .#$$1 --apply 'c: builtins.concatStringsSep " " (builtins.attrNames c)') \
			|| { echo "FAIL $$1 (could not list)"; fail=1; return; }; \
		for name in $$names; do \
			if nix eval --impure --raw ".#$$1.\"$$name\".$$2" >/dev/null 2>/tmp/check-$$$$.log; then \
				echo "ok   $$1.$$name"; \
			else \
				echo "FAIL $$1.$$name"; tail -n 5 /tmp/check-$$$$.log | sed 's/^/     /'; fail=1; \
			fi; \
		done; \
	}; \
	check nixosConfigurations config.system.build.toplevel.drvPath; \
	check darwinConfigurations system.drvPath; \
	check homeConfigurations activationPackage.drvPath; \
	rm -f /tmp/check-$$$$.log; exit $$fail

clean-all:
	sudo nix-collect-garbage -d
	nix-store --optimise
	rm -f result result-*
