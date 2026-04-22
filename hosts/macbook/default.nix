{
  ...
}:

{
  imports = [
    ../../modules/darwin/common.nix
  ];

  networking.hostName = "macbook";

  homebrew.casks = [
    "zen-browser"
  ];
}
