{ ... }:
{
  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      grace = 0;
      ignore_empty_input = true;
    };
    background = {
      path = "screenshot";
      blur_passes = 3;
      blur_size = 10;
      brightness = 1.0;
      contrast = 1.0;
      noise = 0.02;
    };
    input-field = {
      monitor = "";
      size = "250, 50";
      outline_thickness = 0;
      dots_size = 0.26;
      inner_color = "rgba(39, 39, 39, 0.2)";
      dot_color = "rgba(255, 255, 255, 0.75)";
      font_color = "rgb(255, 255, 255)";
      dots_spacing = 0.64;
      dots_center = true;
      fade_on_empty = true;
      placeholder_text = ''<span color="##ffffff"><i>Password...</i></span>'';
      hide_input = false;
      check_color = "rgb(69, 142, 230)";
      fail_color = "rgb(255, 118, 118)";
      position = "0, 50";
      halign = "center";
      valign = "bottom";
    };
  };
  programs.hyprlock.extraConfig = ''
    label {
        monitor =
        text = cmd[update:1000] echo "<b><big> $(date +"%H:%M") </big></b>"
        color = rgba(176, 176, 176, 0.75)
        font_size = 64
        font_family = SF Pro Display
        position = 0, -70
        halign = center
        valign = center
    }
    label {
        monitor =
        text = cmd[update:18000000] echo "<b> "$(date +'%-d %B %Y')" </b>"
        color = rgba(176, 176, 176, 0.75)
        font_size = 24
        font_family = SF Pro Display
        position = 0, -150
        halign = center
        valign = center
    }
  '';
}
