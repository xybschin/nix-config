{ ... }:
{
  config.my.features.home.mangohud = {
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
      settings = {
        no_display = true;
        fps = true;
        fps_metrics = [ "avg" "0.01" ];
        cpu_stats = true;
        gpu_stats = true;
        ram = true;
        vram = true;
        toggle_hud = "Shift_R+F12";
      };
    };

    xdg.configFile."uwsm/env.d/99-mangohud".text = ''
      export MANGOHUD=1
      export MANGOHUD_DLSYM=1
    '';
  };
}
