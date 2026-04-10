#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/waybar/modules"
mkdir -p "$HOME/.local/share/waybar/styles/classes"
mkdir -p "$HOME/.local/share/hyprland-caffeine-mode/lib"
mkdir -p "$HOME/.config/systemd/user"

install -m 755 "$ROOT_DIR/bin/idle-inhibitor-toggle.sh" "$HOME/.local/bin/idle-inhibitor-toggle.sh"
install -m 755 "$ROOT_DIR/bin/idle-inhibitor-status.sh" "$HOME/.local/bin/idle-inhibitor-status.sh"
install -m 644 "$ROOT_DIR/lib/caffeine-common.sh" "$HOME/.local/share/hyprland-caffeine-mode/lib/caffeine-common.sh"
install -m 644 "$ROOT_DIR/systemd/caffeine-mode.service" "$HOME/.config/systemd/user/caffeine-mode.service"
install -m 644 "$ROOT_DIR/waybar/custom-caffeine.jsonc" "$HOME/.local/share/waybar/modules/custom-caffeine.jsonc"
install -m 644 "$ROOT_DIR/waybar/caffeine.css" "$HOME/.local/share/waybar/styles/classes/caffeine.css"

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

printf 'Installed caffeine-mode files.\n'
printf 'Next steps:\n'
printf '  1. Replace Waybar built-in idle_inhibitor with custom/caffeine\n'
printf '  2. Import the CSS snippet from waybar/caffeine.css\n'
printf '  3. Add the Hyprland keybind snippet from hyprland/keybinds.conf\n'
printf '  4. Reload Hyprland and restart Waybar\n'
