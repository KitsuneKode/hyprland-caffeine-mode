# AGENTS

## Purpose

This repository provides a portable "caffeine mode" for Hyprland setups.
It gives Waybar, Hyprland keybinds, and Hypridle one shared manual idle-inhibit
state using `systemd --user` as the preferred backend.

## Main Files

- `bin/idle-inhibitor-toggle.sh`
  Main control script. Handles `toggle`, `on`, `off`, `status`, and `waybar`.
- `bin/idle-inhibitor-status.sh`
  Lightweight Waybar/status path. Keep this small and cheap.
- `systemd/caffeine-mode.service`
  Preferred backend. This is the intended source of truth in normal installs.
- `waybar/custom-caffeine.jsonc`
  Example Waybar module config using signal-based refresh.
- `waybar/caffeine.css`
  Small styling layer for the Waybar module.
- `hyprland/keybinds.conf`
  Example Hyprland keybind.
- `install.sh` / `uninstall.sh`
  Install and remove the packaged files.

## Design Constraints

- Prefer `systemd --user` over custom daemons.
- Avoid polling where possible.
- Keep the Waybar status path lightweight.
- Do not introduce Python or background loops unless there is a strong reason.
- Preserve portability across Hyprland setups instead of baking in local paths.

## Editing Notes

- If you change the Waybar module behavior, keep the README examples in sync.
- If you change install locations, update `install.sh`, `uninstall.sh`, and README.
- If you change script commands or env vars, document them in README.
- Keep documentation concise and practical. This repo is for real desktop use, not a demo.

## Validation

- Run `bash -n` on shell scripts after edits.
- If touching the systemd unit, run `systemd-analyze verify`.
- If touching the Waybar JSON/CSS, check that examples still match the installed paths.
