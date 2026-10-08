# nix-config

Personal Nix flake that describes every machine and user environment Bjarne runs, from one set of reusable features.

## Language

### Machines

**Host**:
A named entry in the flake that describes one machine role: its platform, its user, and which **Features** it enables.
_Avoid_: machine, system, box

**System configuration**:
The OS-level half of a **Host**, built by `nixos-rebuild` or `darwin-rebuild`.
_Avoid_: system, OS config

### User environments

**Home**:
The user-level environment (dotfiles, user packages, user services) for one user on one **Host**.
_Avoid_: dotfiles, user config, HM config

**Integrated home**:
A **Home** built and activated as part of its **Host's** **System configuration**.
_Avoid_: embedded home, NixOS home

**Standalone home**:
A **Home** built and activated on its own with `home-manager switch`, with no **System configuration** involved. It is the only way a **Home** reaches a machine that isn't managed by Nix at the OS level (e.g. an Ubuntu WSL with only Nix and home-manager installed).
_Avoid_: HM-only, home-only config

A single **Home** can be delivered both ways: the nixwsl **Home** is an **Integrated home** on NixOS-WSL and a **Standalone home** on Ubuntu WSL, with identical content. Only the **System configuration** differs between those machines.

### Building blocks

**Feature**:
A named, reusable module that a **Host** opts into for either its **System configuration** or its **Home**.
_Avoid_: profile, role, module (when you mean a named opt-in unit)

## Example dialogue

> **Dev:** "If I add a package to the nixwsl **Home**, does the Ubuntu WSL get it?"
> **Domain expert:** "Yes, if the Ubuntu WSL activates that **Home** as a **Standalone home**. The NixOS-WSL machine gets the same **Home** as an **Integrated home** on its next rebuild."
