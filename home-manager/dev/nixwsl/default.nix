{ lib, ... }: {
  programs.zsh.initContent = lib.mkBefore ''
    # Ensure Windows paths are available when WSL does not inject them
    # (e.g. shells launched under VS Code Server or other systemd user services).
    function _fix_wsl_path() {
      if ! command -v explorer.exe >/dev/null 2>&1; then
        if [[ -f "/mnt/c/Windows/System32/cmd.exe" ]]; then
          local win_path
          win_path=$(/mnt/c/Windows/System32/cmd.exe /c "echo %PATH%" 2>/dev/null)
          win_path=''${win_path%$'\r'}
          local -a unix_paths
          local p drive rest
          for p in ''${(s:;:)win_path}; do
            [[ -z "$p" ]] && continue
            p="''${p//\\//}"
            [[ "$p" =~ "^[a-zA-Z]:" ]] || continue
            drive="''${p[1]:l}"
            rest="''${p[3,-1]}"
            unix_paths+=("/mnt/$drive$rest")
          done
          export PATH="$PATH:''${(j.:.)unix_paths}"
        fi
      fi
    }
    _fix_wsl_path
    unfunction _fix_wsl_path
  '';
}
