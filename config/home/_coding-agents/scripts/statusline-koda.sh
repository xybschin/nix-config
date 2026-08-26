#!/usr/bin/env bash
# Koda Dark status line for Claude Code.
# Colors are koda-dark's base16 hex values as 24-bit ANSI true-color escapes
# (hardcoded rather than templated from stylix, since this is a plain script
# file, not a Nix string).
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

AMBER=$'\033[38;2;217;186;115m' # base09/0A/06 d9ba73 - accent
GRAY=$'\033[38;2;119;119;119m'  # base04/0C/0E 777777 - neutral
MUTED=$'\033[38;2;80;88;93m'    # base03 50585d - muted/comment
WHITE=$'\033[38;2;255;255;255m' # base05/07/0B/0D ffffff - focus/emphasis
RED=$'\033[38;2;255;118;118m'   # base0F ff7676 - danger
BOLD=$'\033[1m'
RESET=$'\033[0m'

if [ "$PCT" -ge 90 ]; then
    BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
    BAR_COLOR="$AMBER"
else
    BAR_COLOR="$GRAY"
fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
if [ "$FILLED" -gt 0 ]; then
    printf -v FILL "%${FILLED}s"
    BAR="${FILL// /▓}"
fi
if [ "$EMPTY" -gt 0 ]; then
    printf -v PAD "%${EMPTY}s"
    BAR="${BAR}${PAD// /░}"
fi

GIT_INFO=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    GIT_INFO=" ${MUTED}|${RESET} ${WHITE}${BRANCH}${RESET}"
    [ "$STAGED" -gt 0 ] && GIT_INFO="${GIT_INFO} ${AMBER}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_INFO="${GIT_INFO} ${GRAY}~${MODIFIED}${RESET}"
fi

COST_FMT=$(LC_NUMERIC=C printf '$%.2f' "$COST")
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

LEFT="${AMBER}${BOLD}[$MODEL]${RESET} ${GRAY}$(basename "$DIR")${RESET}${GIT_INFO}"
RIGHT="${BAR_COLOR}${BAR}${RESET} ${PCT}% ${MUTED}·${RESET} ${GRAY}${COST_FMT} · ${MINS}m ${SECS}s${RESET}"

# Right-align RIGHT to the terminal width, measuring visible length with
# ANSI escapes stripped out.
strip_ansi() { printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*m//g'; }
LEFT_PLAIN=$(strip_ansi "$LEFT")
RIGHT_PLAIN=$(strip_ansi "$RIGHT")
LEFT_LEN=${#LEFT_PLAIN}
RIGHT_LEN=${#RIGHT_PLAIN}

SAFETY_MARGIN=4 # Claude Code adds its own built-in spacing around the row
COLS=$(( ${COLUMNS:-80} - SAFETY_MARGIN ))
GAP=$((COLS - LEFT_LEN - RIGHT_LEN))
[ "$GAP" -lt 1 ] && GAP=1
printf -v PADDING '%*s' "$GAP" ''

printf '%s\n-\n' "${LEFT}${PADDING}${RIGHT}"
