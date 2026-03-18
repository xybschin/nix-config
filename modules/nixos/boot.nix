{ pkgs, ... }:

{
  boot = {
    plymouth =
      let
        theme = "darth_vader";
      in
      {
        inherit theme;
        enable = true;
        themePackages = [
          (pkgs.adi1090x-plymouth-themes.override {
            selected_themes = [ theme ];
          })
        ];
      };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max";
      };
    };
  };
}
