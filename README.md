# Hyprland Caffeine Mode

Manual idle inhibition for Hyprland that works with Waybar and Hypridle.

**Website:** [https://hyprland-caffiene-mode.kitsunelabs.xyz](https://hyprland-caffiene-mode.kitsunelabs.xyz)

## Why

Waybar's built-in `idle_inhibitor` is internal-only. Toggle it from a keybind and Waybar won't know. This project uses `systemd --user` as the source of truth, so Waybar, keybinds, and scripts all see the same state.

## Quick Start

```bash
# Interactive install with path prompts
./install.sh

# Optional: enable only if you want caffeine mode on by default
systemctl --user enable --now caffeine-mode.service

# Toggle on/off
idle-inhibitor-toggle.sh toggle

# Check status
idle-inhibitor-status.sh waybar
```

## How It Works

**Backend:** A `systemd --user` service runs `systemd-inhibit --what=idle sleep infinity` when active. That's it - one sleeping process.

**Hypridle integration:** Hypridle should respect systemd idle inhibitors. Ensure this is set in `hypridle.conf`:

```ini
general {
    ignore_systemd_inhibit = false
}
```

Some Hypridle versions can lose track of systemd inhibitors. If your screen still dims while caffeine mode is active, guard the listener action with the status command:

```ini
listener {
    timeout = 120
    on-timeout = sh -c 'idle-inhibitor-status.sh inactive && { brightnessctl -s && brightnessctl s 1%; }'
    on-resume = brightnessctl -r
}

listener {
    timeout = 240
    on-timeout = sh -c 'idle-inhibitor-status.sh inactive && loginctl lock-session'
}

listener {
    timeout = 420
    on-timeout = sh -c 'idle-inhibitor-status.sh inactive && hyprctl dispatch dpms off'
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 900
    on-timeout = sh -c 'idle-inhibitor-status.sh inactive && systemctl suspend'
}
```

The `active` and `inactive` commands are quiet exit-code checks, so they are cheap enough for Hypridle guards.

Also make sure only one Hypridle instance is running. If both a desktop startup unit and `hypridle.service` are active, one process may own `org.freedesktop.ScreenSaver` while the other reads the config, which makes inhibit behavior confusing. On HyDE setups, prefer the HyDE-managed `app-Hyprland-hypridle@...` unit and keep `hypridle.service` disabled.

**Waybar integration:** Uses signal-based updates.

- The toggle script sends `SIGRTMIN+20` to Waybar after state changes by default
- Waybar listens with `"signal": 20`
- Set `CAFFEINE_WAYBAR_SIGNAL=N` if you use a different Waybar signal
- Set `CAFFEINE_WAYBAR_SIGNAL=off` to disable Waybar notification
- No polling - instant updates

## Resource Use

- Inactive: zero overhead
- Active: one sleeping `systemd-inhibit` process (~1MB)
- Updates: shell script runs on toggle only

## Install

Run the interactive installer:

```bash
./install.sh
```

Press Enter to accept the default XDG-friendly paths. Defaults are:

- scripts: `~/.local/bin`
- shared data: `~/.local/share/hyprland-caffeine-mode`
- installer metadata: `~/.config/hyprland-caffeine-mode`
- systemd user unit: `~/.config/systemd/user`
- Waybar snippets: `~/.local/share/waybar/modules` and `~/.local/share/waybar/styles/classes`

For non-interactive default install:

```bash
./install.sh --yes
```

For rice-managed or custom layouts:

```bash
./install.sh --yes \
  --bin-dir "$HOME/.local/bin" \
  --data-dir "$HOME/.local/share/hyprland-caffeine-mode" \
  --systemd-user-dir "$HOME/.config/systemd/user" \
  --waybar-module-dir "$HOME/.config/waybar/modules" \
  --waybar-style-dir "$HOME/.config/waybar/styles"
```

The installer writes a small `idle-inhibitor-install.env` beside the installed scripts, plus `install.env` under the metadata directory. This lets the scripts find their shared helper even when you choose custom paths.

Use `./install.sh --help` to see every option.

## Rice Integration

This project does not overwrite your Hyprland or Waybar config. It installs reusable snippets that any rice can import.

Make sure the script directory is on `PATH`. With the default install:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Waybar can import the installed module file if your setup supports includes. With the default install, the module is here:

```text
~/.local/share/waybar/modules/custom-caffeine.jsonc
```

Then add this module name to your bar layout:

```jsonc
"custom/caffeine"
```

Import the CSS file from your Waybar style:

```css
@import url("/home/YOUR_USER/.local/share/waybar/styles/classes/caffeine.css");
```

If your rice keeps snippets under `~/.config/waybar`, install directly there with:

```bash
./install.sh --yes \
  --waybar-module-dir "$HOME/.config/waybar/modules" \
  --waybar-style-dir "$HOME/.config/waybar/styles"
```

For Hyprland, copy or source the bind from:

```text
hyprland/keybinds.conf
```

The command is intentionally generic:

```ini
bind = $mainMod, BACKSLASH, exec, idle-inhibitor-toggle.sh toggle
```

If your session does not include the script directory in `PATH`, use the full installed path instead.

## Waybar Setup

```jsonc
{
  "custom/caffeine": {
    "return-type": "json",
    "format": "{text}",
    "exec": "CAFFEINE_ACTIVE_TEXT='󰅶' CAFFEINE_INACTIVE_TEXT='󰾪' idle-inhibitor-status.sh",
    "interval": "once",
    "signal": 20,
    "tooltip": true,
    "on-click": "idle-inhibitor-toggle.sh toggle",
    "on-click-right": "idle-inhibitor-toggle.sh off"
  }
}
```

## Hyprland Keybind

```ini
bind = $mainMod, BACKSLASH, exec, idle-inhibitor-toggle.sh toggle
```

## Commands

```bash
idle-inhibitor-toggle.sh toggle   # flip state
idle-inhibitor-toggle.sh on       # enable
idle-inhibitor-toggle.sh off      # disable
idle-inhibitor-toggle.sh status   # print activated/deactivated
idle-inhibitor-status.sh active   # exit 0 when active, 1 otherwise
idle-inhibitor-status.sh inactive # exit 0 when inactive, 1 otherwise
idle-inhibitor-status.sh waybar   # print Waybar JSON
idle-inhibitor-status.sh diagnose # print service and inhibitor details
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CAFFEINE_SERVICE_NAME` | `caffeine-mode.service` | Service name |
| `CAFFEINE_WAYBAR_SIGNAL` | `20` | Signal number to notify Waybar. Use `off` to disable |
| `CAFFEINE_ACTIVE_TEXT` | `ON` | Text when active |
| `CAFFEINE_INACTIVE_TEXT` | `OFF` | Text when inactive |
| `CAFFEINE_WHO` | `Caffeine Mode` | Inhibitor owner string |
| `CAFFEINE_WHY` | `Manual idle inhibition` | Inhibitor reason |

## Uninstall

```bash
./uninstall.sh
```

The uninstaller reads the recorded install paths from `~/.config/hyprland-caffeine-mode/install.env` by default. For a custom metadata directory:

```bash
./uninstall.sh --config-dir /path/to/hyprland-caffeine-mode
```

Use `--keep-waybar` if you want to remove the scripts and service but leave copied Waybar snippets in place.

## Requirements

- Linux
- Hyprland
- `systemd --user`
- `systemd-inhibit`

Optional: Hypridle, Waybar, `notify-send`

## License

MIT
