# Hyprland Caffeine Mode

Manual idle inhibition for Hyprland that works with Waybar and Hypridle.

**Website:** [https://hyprland-caffeine-mode.kitsunekode.xyz](https://hyprland-caffeine-mode.kitsunekode.xyz)

## Why

Waybar's built-in `idle_inhibitor` is internal-only. Toggle it from a keybind and Waybar won't know. This project uses `systemd --user` as the source of truth - Waybar, keybinds, and scripts all see the same state.

## Quick Start

```bash
# 1. Install
./install.sh

# 2. Enable the systemd service (so it runs on login, or just start manually)
systemctl --user enable --now caffeine-mode.service

# 3. Toggle on/off
idle-inhibitor-toggle.sh toggle

# 4. Check status
idle-inhibitor-status.sh waybar
```

## How It Works

**Backend:** A `systemd --user` service runs `systemd-inhibit --what=idle sleep infinity` when active. That's it - one sleeping process.

**Hypridle integration:** Already works. Just ensure in your `hypridle.conf`:
```ini
general {
    ignore_systemd_inhibit = false
}
```

**Waybar integration:** Uses signal-based updates.
- Set `CAFFEINE_WAYBAR_SIGNAL=20` to send `SIGRTMIN+20` on toggle
- Waybar listens with `"signal": 20`
- No polling - instant updates

## Resource Use

- Inactive: zero overhead
- Active: one sleeping `systemd-inhibit` process (~1MB)
- Updates: shell script runs on toggle only

## Install

```bash
./install.sh
```

This installs:
- `~/.local/bin/idle-inhibitor-toggle.sh`
- `~/.local/bin/idle-inhibitor-status.sh`
- `~/.local/share/hyprland-caffeine-mode/lib/caffeine-common.sh`
- `~/.config/systemd/user/caffeine-mode.service`
- Waybar module & CSS

## Waybar Setup

```jsonc
"custom/caffeine": {
  "return-type": "json",
  "format": "{text}",
  "exec": "CAFFEINE_ACTIVE_TEXT='󰅶' CAFFEINE_INACTIVE_TEXT='󰾪' ~/.local/bin/idle-inhibitor-status.sh",
  "interval": "once",
  "signal": 20,
  "tooltip": true,
  "on-click": "CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh toggle",
  "on-click-right": "CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh off"
}
```

## Hyprland Keybind

```ini
bind = $mainMod, BACKSLASH, exec, CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh toggle
```

## Commands

```bash
idle-inhibitor-toggle.sh toggle   # flip state
idle-inhibitor-toggle.sh on     # enable
idle-inhibitor-toggle.sh off   # disable
idle-inhibitor-toggle.sh status  # print activated/deactivated
idle-inhibitor-status.sh waybar # print Waybar JSON
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CAFFEINE_SERVICE_NAME` | `caffeine-mode.service` | Service name |
| `CAFFEINE_WAYBAR_SIGNAL` | (none) | Signal number to notify Waybar |
| `CAFFEINE_ACTIVE_TEXT` | `ON` | Text when active |
| `CAFFEINE_INACTIVE_TEXT` | `OFF` | Text when inactive |
| `CAFFEINE_WHO` | `Caffeine Mode` | Inhibitor owner string |
| `CAFFEINE_WHY` | `Manual idle inhibition` | Inhibitor reason |

## Uninstall

```bash
./uninstall.sh
```

## Requirements

- Linux
- Hyprland
- `systemd --user`
- `systemd-inhibit`

Optional: Hypridle, Waybar, `notify-send`

## License

MIT