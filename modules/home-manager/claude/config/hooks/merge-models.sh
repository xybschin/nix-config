#!/bin/bash
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
MODELS_JSON="$HOME/.claude/models.json"

# Skip if models.json doesn't exist
if [ ! -f "$MODELS_JSON" ]; then
  exit 0
fi

# Skip if settings.json doesn't exist
if [ ! -f "$SETTINGS" ]; then
  exit 0
fi

# Merge models.json into settings.json
jq --slurpfile models "$MODELS_JSON" \
  '.models = $models[0]' \
  "$SETTINGS" > "${SETTINGS}.tmp" \
  && mv "${SETTINGS}.tmp" "$SETTINGS"
