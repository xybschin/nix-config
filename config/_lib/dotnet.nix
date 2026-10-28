# The combined .NET SDK host used by both the home feature
# (config/home/dotnet.nix) and the shared devenv module
# (config/devenv-modules/dotnet.nix), so one place decides the SDK versions.
{ pkgs }:
with pkgs.dotnetCorePackages;
combinePackages [
  sdk_11_0
  sdk_10_0
]
