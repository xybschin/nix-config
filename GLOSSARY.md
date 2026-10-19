# nix-config

Declarative configuration for personal hosts (NixOS, nix-darwin, Home Manager), composed from named features.

## Language

**Feature**:
A named module registered under `my.features.<kind>` that a host opts into by listing its name.
_Avoid_: Profile, role, plugin

**Host**:
A machine declared under `my.hosts.<name>` with its system, user, and the features it uses.
_Avoid_: Node, machine config

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
