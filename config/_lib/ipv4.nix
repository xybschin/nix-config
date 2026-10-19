# Dotted-quad IPv4 and CIDR helpers shared by the network features.
{ lib }:
rec {
  isIpv4 =
    s:
    builtins.match "[0-9]{1,3}(\\.[0-9]{1,3}){3}" s != null
    && lib.all (o: o <= 255) (map lib.toInt (lib.splitString "." s));

  toInt = s: lib.foldl (acc: o: acc * 256 + o) 0 (map lib.toInt (lib.splitString "." s));

  fromInt =
    n:
    lib.concatStringsSep "." (
      map (d: toString (lib.mod (n / d) 256)) [
        16777216
        65536
        256
        1
      ]
    );

  pow2 = n: lib.foldl (acc: _: acc * 2) 1 (lib.range 1 n);

  addrOf = cidr: lib.head (lib.splitString "/" cidr);
  prefixOf = cidr: lib.toInt (lib.last (lib.splitString "/" cidr));
  sizeOf = cidr: pow2 (32 - prefixOf cidr);
  baseOf = cidr: (toInt (addrOf cidr) / sizeOf cidr) * sizeOf cidr;

  # `cidr` is a well-formed IPv4 CIDR; `ip` a valid IPv4 address.
  inSubnet = cidr: ip: toInt ip / sizeOf cidr == toInt (addrOf cidr) / sizeOf cidr;

  # Usable host addresses of the subnet (network and broadcast excluded).
  hostsOf = cidr: map (i: fromInt (baseOf cidr + i)) (lib.range 1 (sizeOf cidr - 2));
}
