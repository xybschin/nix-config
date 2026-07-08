{
  pkgs,
  ...
}:

{
  snowfallorg.users.bjarne = {
    admin = true;
    home.enable = true;
  };

  users.users.bjarne = {
    shell = pkgs.zsh;
  };

  homebrew.casks = [
    "zen-browser"
  ];
}
