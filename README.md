# Hyprland Caffeine Mode

Portable manual idle inhibition for Hyprland, Hypridle, and Waybar.

This project gives you one shared "caffeine mode" state that works cleanly with:

- Hyprland keybinds
- Hypridle idle handling
- Waybar status display
- `systemd --user` session management

It exists because Waybar's built-in `idle_inhibitor` module is its own internal toggle. If you toggle idle inhibition from a script or keybind outside Waybar, the built-in module does not automatically reflect that external state.

## What It Solves

- One real source of truth for manual idle inhibition
- Waybar and keybinds stay in sync
- No fake Wayland surfaces
- No Python daemon, no audio polling loop, no long-running interpreter
- Works well with Hypridle because Hypridle already respects `systemd-inhibit` when `ignore_systemd_inhibit = false`

## How It Works

Preferred backend:
- A `systemd --user` service called `caffeine-mode.service`

Optional fallback backend:
- A background `systemd-inhibit --what=idle sleep infinity` process

Waybar integration:
- A `custom/caffeine` module
- Signal-based refresh with `SIGRTMIN+20`
- No regular polling after startup

## Resource Use

Compared to Waybar's built-in `idle_inhibitor`, this is slightly heavier, but still extremely light:

- inactive: effectively zero overhead
- active: one sleeping `systemd-inhibit` or `sleep infinity` service process
- updates: one short shell script execution on startup and on state changes

Compared to a Python Wayland client or a polling daemon, this is usually simpler and lighter.

## Files

- `lib/caffeine-common.sh`
  Shared helper for config, backend detection, JSON escaping, and common state helpers.
- `bin/idle-inhibitor-toggle.sh`
  Write-oriented command. Handles `toggle`, `on`, and `off`, and delegates read commands for compatibility.
- `bin/idle-inhibitor-status.sh`
  Read-only status path for Waybar and plain status checks.
- `systemd/caffeine-mode.service`
  Preferred backend for session-wide idle inhibition.
- `waybar/custom-caffeine.jsonc`
  Waybar module definition.
- `waybar/caffeine.css`
  Small theme-aware Waybar styling.
- `hyprland/keybinds.conf`
  Example Hyprland bind snippet.
- `install.sh`
  Installs the files into standard user locations.
- `uninstall.sh`
  Removes the installed files.

## Requirements

- Linux
- Hyprland
- `systemd --user`
- `systemd-inhibit`

Optional:
- Hypridle
- Waybar
- `notify-send`

## Install

```bash
./install.sh
```

This installs:

- `~/.local/share/hyprland-caffeine-mode/lib/caffeine-common.sh`
- `~/.local/bin/idle-inhibitor-toggle.sh`
- `~/.local/bin/idle-inhibitor-status.sh`
- `~/.config/systemd/user/caffeine-mode.service`
- `~/.local/share/waybar/modules/custom-caffeine.jsonc`
- `~/.local/share/waybar/styles/classes/caffeine.css`

`install.sh` also tries to run `systemctl --user daemon-reload` when available.

## Hypridle

Make sure your `hypridle.conf` includes:

```ini
general {
    ignore_systemd_inhibit = false
}
```

Without that, Hypridle will ignore the manual caffeine service.

## Waybar

Use `custom/caffeine` instead of Waybar's built-in `idle_inhibitor`.

### Module Snippet

```jsonc
"custom/caffeine": {
  "return-type": "json",
  "format": "{text}",
  "exec": "CAFFEINE_REQUIRE_SERVICE=1 CAFFEINE_ACTIVE_TEXT='󰅶' CAFFEINE_INACTIVE_TEXT='󰾪' ~/.local/bin/idle-inhibitor-status.sh",
  "interval": "once",
  "signal": 20,
  "tooltip": true,
  "on-click": "CAFFEINE_REQUIRE_SERVICE=1 CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh toggle",
  "on-click-right": "CAFFEINE_REQUIRE_SERVICE=1 CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh off"
}
```

### CSS Snippet

```css
@import "~/.local/share/waybar/styles/classes/caffeine.css";
```

## Hyprland Keybind

```ini
binddl = $mainMod, BACKSLASH, $d toggle caffeine mode, exec, CAFFEINE_REQUIRE_SERVICE=1 CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh toggle
```

## Commands

```bash
idle-inhibitor-toggle.sh toggle
idle-inhibitor-toggle.sh on
idle-inhibitor-toggle.sh off
idle-inhibitor-toggle.sh status
idle-inhibitor-status.sh waybar
```

## Environment Variables

- `CAFFEINE_SERVICE_NAME`
  Override the user service name. Default: `caffeine-mode.service`
- `CAFFEINE_REQUIRE_SERVICE`
  Set to `1` to disable the fallback backend
- `CAFFEINE_WAYBAR_SIGNAL`
  Signal number offset used for Waybar refresh
- `CAFFEINE_ACTIVE_TEXT`
  Text or icon shown while active
- `CAFFEINE_INACTIVE_TEXT`
  Text or icon shown while inactive
- `CAFFEINE_WHO`
  Human-readable inhibitor owner string
- `CAFFEINE_WHY`
  Human-readable inhibitor reason string
- `CAFFEINE_MODE`
  Inhibitor mode passed to `systemd-inhibit`

## Why Not Use Waybar's Built-in `idle_inhibitor`?

Two concrete failure modes:

- **Waybar crashes or restarts** — the built-in module restarts in the default (inactive) state, even if you had caffeine mode enabled. Your session is now unprotected with no indication.
- **Theme changes reload Waybar** — any `pkill -SIGUSR2 waybar` or full restart drops the built-in toggle state. This happens routinely with theme managers, ricing scripts, or even `hyprctl dispatch exec`.

Beyond those: the built-in toggle is Waybar-internal state only. A keybind bound to an external script cannot see or control it. This project uses `systemd --user` as the source of truth, so Waybar, keybinds, and scripts all read and write the same state — and that state survives Waybar restarts and theme reloads.

## Why Two Scripts?

This repo intentionally keeps:

- one write-oriented entrypoint for side effects
- one read-only entrypoint for Waybar/status checks
- one shared helper to avoid logic duplication

That keeps the Waybar path small and predictable while still avoiding copy-pasted logic.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
