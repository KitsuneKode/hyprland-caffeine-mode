#!/usr/bin/env bash
set -euo pipefail

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop caffeine-mode.service 2>/dev/null || true
    systemctl --user disable caffeine-mode.service 2>/dev/null || true
fi

rm -f "$HOME/.local/bin/idle-inhibitor-toggle.sh"
rm -f "$HOME/.local/bin/idle-inhibitor-status.sh"
rm -f "$HOME/.local/share/hyprland-caffeine-mode/lib/caffeine-common.sh"
rm -f "$HOME/.config/systemd/user/caffeine-mode.service"
rm -f "$HOME/.local/share/waybar/modules/custom-caffeine.jsonc"
rm -f "$HOME/.local/share/waybar/styles/classes/caffeine.css"

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

printf 'Removed installed caffeine-mode files.\n'
