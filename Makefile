CONFIG_ROOT := $(shell git rev-parse --show-toplevel)
host ?= $(shell hostname)
user ?= $(shell echo $$USER)

nixos:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --sudo --impure --flake .#$(host)

darwin:
	CONFIG_ROOT=$(CONFIG_ROOT) darwin-rebuild switch --flake .#$(host)

home:
	CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#$(user)@$(host)

up:
	nix flake update
	git add flake.lock
	git commit -m "chore: bump dependencies"

check:
	@export CONFIG_ROOT=$(CONFIG_ROOT) NIXPKGS_ALLOW_UNFREE=1; fail=0; \
	rows=/tmp/check-$$$$.rows; details=/tmp/check-$$$$.details; log=/tmp/check-$$$$.log; \
	: > $$rows; : > $$details; \
	check() { \
		names=$$(nix eval --impure --raw .#$$1 --apply 'c: builtins.concatStringsSep " " (builtins.attrNames c)') \
			|| { printf '%s\t%s\t%s\n' "$$1.*" FAIL "could not list configurations" >> $$rows; fail=1; return; }; \
		for name in $$names; do \
			if nix eval --impure --raw ".#$$1.\"$$name\".$$2" >/dev/null 2>$$log; then \
				printf '%s\t%s\t%s\n' "$$1.$$name" ok "" >> $$rows; \
			else \
				msg=$$(grep -v '^[[:space:]]*$$' $$log | tail -n 1 | tr '\t|' '  ' | cut -c1-60); \
				printf '%s\t%s\t%s\n' "$$1.$$name" FAIL "$$msg" >> $$rows; \
				{ printf '%s.%s\n' "$$1" "$$name"; tail -n 5 $$log | sed 's/^/    /'; printf '\n'; } >> $$details; \
				fail=1; \
			fi; \
		done; \
	}; \
	check nixosConfigurations config.system.build.toplevel.drvPath; \
	check darwinConfigurations system.drvPath; \
	check homeConfigurations activationPackage.drvPath; \
	awk -F'\t' '\
	function rep(s, n,   o, i) { o = ""; for (i = 0; i < n; i++) o = o s; return o } \
	function pad(s, w) { return s rep(" ", w - length(s)) } \
	{ n++; c1[n] = $$1; c2[n] = $$2; c3[n] = $$3; \
	  if (length($$1) > w1) w1 = length($$1); \
	  if (length($$2) > w2) w2 = length($$2); \
	  if (length($$3) > w3) w3 = length($$3); \
	  if ($$2 == "ok") ok++; else bad++ } \
	END { \
	  if (w1 < 13) w1 = 13; \
	  if (w2 < 6) w2 = 6; \
	  if (w3 < 7) w3 = 7; \
	  sep = "+" rep("-", w1 + 2) "+" rep("-", w2 + 2) "+" rep("-", w3 + 2) "+"; \
	  print sep; \
	  print "| " pad("Configuration", w1) " | " pad("Status", w2) " | " pad("Message", w3) " |"; \
	  print sep; \
	  for (i = 1; i <= n; i++) \
	    printf "| %s | %s | %s |\n", pad(c1[i], w1), pad(c2[i], w2), pad(c3[i], w3); \
	  print sep; \
	  printf "%d checked, %d ok, %d failed\n", n, ok, bad }' $$rows; \
	[ ! -s $$details ] || { echo; echo "Failure details:"; echo; cat $$details; }; \
	rm -f $$rows $$details $$log; exit $$fail

.PHONY: nixos darwin home up check clean-all

clean-all:
	sudo nix-collect-garbage -d
	nix-store --optimise
	rm -f result result-*
