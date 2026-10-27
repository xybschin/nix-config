#!/usr/bin/env bash
#
# Print the wallpaper hyprpaper is configured to use, as a single absolute path.
#
#   hyprlock-wallpaper            -> the first wallpaper in hyprpaper.conf
#   hyprlock-wallpaper DP-2       -> the wallpaper configured for that monitor
#
# The hyprpaper config file is the source of truth: edit it, and the lock
# screen follows. If it holds no usable wallpaper, hyprpaper's own IPC is
# asked instead (covers a wallpaper set at runtime, or a missing config file).
#
# Used by hyprlock's `background.reload_cmd`. Nothing is written to stderr on
# success - hyprlock logs anything on stderr as an error.

set -uo pipefail

hyprpaper_conf() {
    printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprpaper.conf"
}

# Emits "<monitor>\t<path>" for every wallpaper entry in a hyprpaper config.
# Handles both the block form and the one-line form:
#
#   wallpaper { monitor = DP-2
#               path = /path/to.jpg }
#   wallpaper = DP-2, /path/to.jpg, cover
parse_config() {
    awk '
        {
            line = $0
            sub(/#.*/, "", line)

            if (match(line, /^[ \t]*wallpaper[ \t]*=[ \t]*/)) {
                value = substr(line, RSTART + RLENGTH)
                n = split(value, parts, ",")
                mon  = (n >= 1 ? parts[1] : "")
                path = (n >= 2 ? parts[2] : "")
                trim(mon); trim(path)
                unquote(mon); unquote(path)
                if (path != "") print mon "\t" path
                next
            }

            if (line ~ /^[ \t]*wallpaper[ \t]*\{/) { inblock = 1; mon = ""; path = ""; next }
            if (inblock && line ~ /^[ \t]*\}/) {
                if (path != "") print mon "\t" path
                inblock = 0
                next
            }
            if (inblock) {
                if (match(line, /^[ \t]*monitor[ \t]*=[ \t]*/)) {
                    mon = substr(line, RSTART + RLENGTH); trim(mon); unquote(mon)
                } else if (match(line, /^[ \t]*path[ \t]*=[ \t]*/)) {
                    path = substr(line, RSTART + RLENGTH); trim(path); unquote(path)
                }
            }
        }

        function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
        function unquote(s) {
            if (s ~ /^".*"$/) s = substr(s, 2, length(s) - 2)
            else if (s ~ /^\x27.*\x27$/) s = substr(s, 2, length(s) - 2)
            return s
        }
    ' "$1"
}

# The path as written in the config, turned into something that exists.
resolve_path() {
    local raw="$1" base
    [ -n "$raw" ] || return 1

    case "$raw" in
        "~") raw="$HOME" ;;
        "~/"*) raw="$HOME/${raw#\~/}" ;;
        /*) ;;
        *) base=$(dirname "$(hyprpaper_conf)"); raw="$base/$raw" ;;
    esac

    [ -f "$raw" ] || return 1
    printf '%s\n' "$raw"
}

# The wallpaper for a given monitor: an exact match, else a wildcard entry
# (empty or "all" monitor), else the first entry in the file.
from_config() {
    local monitor="${1:-}" conf="" entries="" entry="" path=""

    conf=$(hyprpaper_conf)
    [ -r "$conf" ] || return 1

    entries=$(parse_config "$conf")
    [ -n "$entries" ] || return 1

    if [ -n "$monitor" ]; then
        entry=$(printf '%s\n' "$entries" | awk -F'\t' -v m="$monitor" '$1 == m { print; exit }')
        if [ -z "$entry" ]; then
            entry=$(printf '%s\n' "$entries" | awk -F'\t' '$1 == "" || $1 == "all" { print; exit }')
        fi
    fi

    [ -n "$entry" ] || entry=$(printf '%s\n' "$entries" | head -n 1)

    path=$(printf '%s\n' "$entry" | cut -f2)
    resolve_path "$path"
}

# Ask hyprpaper itself. Output lines look like: "DP-2: /home/user/wallpaper.jpg"
from_ipc() {
    local monitor="${1:-}" out="" path=""

    command -v hyprctl >/dev/null 2>&1 || return 1
    out=$(hyprctl hyprpaper listactive 2>/dev/null) || return 1
    [ -n "$out" ] || return 1

    if [ -n "$monitor" ]; then
        path=$(printf '%s\n' "$out" | awk -F': ' -v m="$monitor" '$1 == m { print $2; exit }')
    fi
    [ -n "$path" ] || path=$(printf '%s\n' "$out" | awk -F': ' 'NF > 1 && $2 != "" { print $2; exit }')

    [ -f "$path" ] || return 1
    printf '%s\n' "$path"
}

resolve() {
    local monitor="${1:-}" path=""

    path=$(from_config "$monitor") && [ -n "$path" ] && { printf '%s\n' "$path"; return 0; }
    path=$(from_ipc "$monitor") && [ -n "$path" ] && { printf '%s\n' "$path"; return 0; }

    return 1
}

if [ "${1:-}" = "--check" ]; then
    monitor="${2:-}"
    echo "config file:  $(hyprpaper_conf)"
    echo "entries:"
    parse_config "$(hyprpaper_conf)" 2>/dev/null | sed 's/^/  /'
    if path=$(resolve "$monitor"); then
        echo "monitor:     ${monitor:-<any>}"
        echo "resolved:     $path"
    else
        echo "resolved:     <nothing> (the lock screen falls back to the solid color)"
        exit 1
    fi
    exit 0
fi

resolve "${1:-}"
