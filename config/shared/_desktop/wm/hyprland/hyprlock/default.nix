{ pkgs, ... }:
let
  # Prints, as a single absolute path, the wallpaper hyprpaper is using for
  # one output. Kept a plain script so it stays directly testable:
  #   hyprlock-wallpaper --check [output]
  hyprlockWallpaper = pkgs.runCommand "hyprlock-wallpaper" { } ''
    install -Dm755 ${./hyprlock-wallpaper.sh} $out/bin/hyprlock-wallpaper
  '';

  # hyprlock reads one static config file, but two things that file needs are
  # runtime state: which outputs the active monitor profile has on, and which
  # wallpaper hyprpaper is showing on each of them. So `hyprlock` on PATH is
  # this launcher: it renders the config for the current layout into
  # $XDG_RUNTIME_DIR and execs the real hyprlock with it.
  #
  #   - every enabled output draws its own hyprpaper wallpaper
  #     (background.conf.in, one block per output)
  #   - the profile's first output, leftmost in the layout, carries the clock
  #     and the password field (lock.conf.in)
  #
  # With no layout info (hyprctl empty), everything falls back to empty
  # monitors: draw on every output, take the first wallpaper in hyprpaper.conf.
  hyprlock = pkgs.writeShellScriptBin "hyprlock" ''
    set -euo pipefail

    resolver="${hyprlockWallpaper}/bin/hyprlock-wallpaper"
    backgroundTemplate="${./background.conf.in}"
    lockTemplate="${./lock.conf.in}"

    # Enabled outputs of the active monitor profile, leftmost first. Best
    # effort: outside Hyprland this stays empty and everything falls back.
    outputs=$(hyprctl monitors -j 2>/dev/null | jq -r 'sort_by(.x, .y, .name) | .[].name' 2>/dev/null || true)
    lockOutput=$(printf '%s\n' "$outputs" | head -n1)

    # render <template> <output>: template with its placeholders filled.
    render() {
        sed -e "s|@MONITOR@|$2|g" -e "s|@RESOLVER@|$resolver|g" "$1"
    }

    configFile="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/hyprlock.conf"
    {
        if [[ -n "$outputs" ]]; then
            for output in $outputs; do
                render "$backgroundTemplate" "$output"
            done
        else
            render "$backgroundTemplate" ""
        fi

        render "$lockTemplate" "$lockOutput"
    } > "$configFile"

    exec ${pkgs.hyprlock}/bin/hyprlock --config "$configFile" "$@"
  '';
in
{
  home.packages = [ hyprlock ];
}
