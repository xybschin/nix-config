{ ... }:

{
  programs = {
    uwsm.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    steam.enable = true;
  };
}
