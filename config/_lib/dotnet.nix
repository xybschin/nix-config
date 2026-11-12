# The combined .NET SDK host used by the home feature (config/home/dotnet.nix).
{ pkgs }:
with pkgs.dotnetCorePackages;
combinePackages [
  sdk_11_0
  sdk_10_0
]
