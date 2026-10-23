# nix-config

Declarative configuration for personal hosts (NixOS, nix-darwin, Home Manager), composed from named features.

## Language

**Feature**:
A named module registered under `my.features.<kind>` that a host opts into by listing its name.
_Avoid_: Profile, role, plugin

**Host**:
A machine declared under `my.hosts.<name>` with its system, user, and the features it uses.
_Avoid_: Node, machine config

**Dev shell**:
A per-project devenv environment entered with `devenv shell` or direnv, whose shared language defaults (go, typescript, dotnet) come from the `devenvModules` this flake exports.
_Avoid_: flake devShell, toolchain env, devenv config

## Self-hosted

**Self-hosted stack**:
The VPN endpoint, DNS, reverse proxy and containers a machine runs for its own trusted devices, opted into as one feature.
_Avoid_: infra (that is only the container bridge network), homelab, VPS stack

## Atlas networking

**Infra network**:
The container bridge on atlas whose containers have fixed IPs and are routed to directly by the host firewall and VPN clients.
_Avoid_: Podman network, docker network, br-infra (that is only the bridge interface)

**Infra service**:
A container on the infra network, declared once with its IP and the ports VPN clients may reach.
_Avoid_: Container entry, backend

**VPN ingress**:
The set of ports of an infra service that VPN clients are allowed to reach.
_Avoid_: Forward rule (that is how it is enforced), exposed ports

## WireGuard

**Peer**:
A device or router allowed to connect to the atlas WireGuard server, with its own tunnel address, public key and preshared key.
_Avoid_: Client (that is the config a peer imports), device

**Peer registry**:
The JSON file listing every peer, edited by `scripts/wg-add-peer.sh` and read by the WireGuard server.
_Avoid_: Peers file, wg-peers

**Tunnel address**:
The address a peer has inside the WireGuard subnet.
_Avoid_: VPN IP, client IP

## Desktop

**Monitor profile**:
A named monitor layout (which outputs are on, their modes and positions, and which workspaces live where) that can be switched at runtime.
_Avoid_: Monitor config, display setup, layout preset

**Active profile**:
The monitor profile recorded in the per-machine state file; the first declared profile when none is recorded.
_Avoid_: Current monitor, selected layout

**Glyph**:
The MonitorIcons font icon that depicts a Monitor profile's layout, selected by name from `my.monitors.glyphs` (DualActive, DualLeftActive, DualRightActive, Ultrawide) — never by raw codepoint.
_Avoid_: Icon, codepoint, font char

**Gaming workspace**:
The workspace the Monitor profile marks for gaming: gapless wherever a profile pins it, bound to `SUPER + g`, and shown with the G mark in the bar.
_Avoid_: Game workspace, workspace 10

## Coding agents

**Coding agent**:
An AI CLI assistant (claude, copilot, opencode) whose binary and configuration the coding-agents feature manages for a host.
_Avoid_: AI tool, LLM client

**Agent set**:
The list of coding agents a host gets, declared as `my.coding-agents.agents` and overridden per rebuild by `CODING_AGENTS` — `make ... with=...` wins, else the gitignored `.feature-overrides` file, else the host default; `none` selects an agent-less machine.
_Avoid_: with arg, feature flags, enable list

**Rolling release**:
A package whose newest upstream release is resolved while the configuration is evaluated rather than pinned in nixpkgs — claude-code follows Anthropic's release feed, so every rebuild lands on the current release. `CLAUDE_CODE_VERSION` pins it.
_Avoid_: auto-update, latest version, unpinned package
