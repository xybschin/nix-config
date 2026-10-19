CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

nixos:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

nixos-remote:
	@test -n "$(target)" || { echo "usage: make nixos-remote host=<name> target=<address>"; exit 1; }
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure --flake .#$(host) --target-host root@$(target)

nixos-install:
	@test -n "$(target)" || { echo "usage: make nixos-install host=<name> target=<address>"; exit 1; }
	@test -f $(HOME)/.config/sops/age/atlas.txt || { echo "missing age key: ~/.config/sops/age/atlas.txt"; exit 1; }
	rm -rf /tmp/atlas-extra
	mkdir -p /tmp/atlas-extra/var/lib/sops-nix/age
	cp $(HOME)/.config/sops/age/atlas.txt /tmp/atlas-extra/var/lib/sops-nix/age/keys.txt
	chmod 600 /tmp/atlas-extra/var/lib/sops-nix/age/keys.txt
	nix run github:nix-community/nixos-anywhere -- --flake .#$(host) --extra-files /tmp/atlas-extra root@$(target)
	rm -rf /tmp/atlas-extra

darwin:
	CONFIG_ROOT=$(CONFIG_ROOT) darwin-rebuild switch --flake .#$(host)

home:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#$(user)@$(host)

up:
	nix flake update
	git add flake.lock
	git commit -m "chore: bump dependencies"

check:
	@export CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1; fail=0; checked=0; ok=0; \
	check() { \
		names=$$(nix eval --impure --raw .#$$1 --apply 'c: builtins.concatStringsSep " " (builtins.attrNames c)') \
			|| { echo "$$1.* FAIL could not list configurations"; fail=1; return; }; \
		for name in $$names; do \
			checked=$$((checked + 1)); \
			if out=$$(nix eval --impure --raw ".#$$1.\"$$name\".$$2" 2>&1 >/dev/null); then \
				ok=$$((ok + 1)); \
				echo "$$1.$$name ok"; \
			else \
				msg=$$(printf '%s\n' "$$out" | grep -i error | tail -n 1); \
				msg=$${msg:-$$(printf '%s\n' "$$out" | grep -v '^[[:space:]]*$$' | tail -n 1)}; \
				msg=$$(printf '%s' "$$msg" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$$//'); \
				echo "$$1.$$name FAIL: $$msg"; \
				fail=1; \
			fi; \
		done; \
	}; \
	check nixosConfigurations config.system.build.toplevel.drvPath; \
	check darwinConfigurations system.drvPath; \
	check homeConfigurations activationPackage.drvPath; \
	echo "$$checked checked, $$ok ok, $$((checked - ok)) failed"; \
	exit $$fail

.PHONY: nixos nixos-remote nixos-install darwin home up check clean-all

clean-all:
	sudo nix-collect-garbage -d
	nix-store --optimise
	rm -f result result-*
