#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

DEFAULT_BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DEFAULT_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland-caffeine-mode"
DEFAULT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprland-caffeine-mode"
DEFAULT_SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
DEFAULT_WAYBAR_MODULE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/waybar/modules"
DEFAULT_WAYBAR_STYLE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/waybar/styles/classes"

BIN_DIR="$DEFAULT_BIN_DIR"
DATA_DIR="$DEFAULT_DATA_DIR"
CONFIG_DIR="$DEFAULT_CONFIG_DIR"
SYSTEMD_USER_DIR="$DEFAULT_SYSTEMD_USER_DIR"
WAYBAR_MODULE_DIR="$DEFAULT_WAYBAR_MODULE_DIR"
WAYBAR_STYLE_DIR="$DEFAULT_WAYBAR_STYLE_DIR"
INSTALL_WAYBAR=1
ASSUME_YES=0

style() {
    local _mode="$1"
    shift
    [[ "$_mode" == "setaf" ]] && shift
    printf '%s' "$*"
}

info() {
    printf '%s %s\n' "$(style setaf 6 '==>')" "$*"
}

success() {
    printf '%s %s\n' "$(style setaf 2 'OK ')" "$*"
}

warn() {
    printf '%s %s\n' "$(style setaf 3 '!! ')" "$*"
}

usage() {
    cat <<EOF
Usage: ./install.sh [options]

Options:
  -y, --yes                     Use defaults and do not prompt
      --bin-dir DIR             Install scripts here
      --data-dir DIR            Install shared project data here
      --config-dir DIR          Store installer metadata here
      --systemd-user-dir DIR    Install caffeine-mode.service here
      --waybar-module-dir DIR   Install Waybar JSONC snippet here
      --waybar-style-dir DIR    Install Waybar CSS snippet here
      --no-waybar               Skip Waybar snippets
  -h, --help                    Show this help

Defaults:
  bin:            $DEFAULT_BIN_DIR
  data:           $DEFAULT_DATA_DIR
  config:         $DEFAULT_CONFIG_DIR
  systemd user:   $DEFAULT_SYSTEMD_USER_DIR
  waybar module:  $DEFAULT_WAYBAR_MODULE_DIR
  waybar style:   $DEFAULT_WAYBAR_STYLE_DIR
EOF
}

while (($#)); do
    case "$1" in
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        --bin-dir)
            BIN_DIR="${2:?Missing value for --bin-dir}"
            shift 2
            ;;
        --data-dir)
            DATA_DIR="${2:?Missing value for --data-dir}"
            shift 2
            ;;
        --config-dir)
            CONFIG_DIR="${2:?Missing value for --config-dir}"
            shift 2
            ;;
        --systemd-user-dir)
            SYSTEMD_USER_DIR="${2:?Missing value for --systemd-user-dir}"
            shift 2
            ;;
        --waybar-module-dir)
            WAYBAR_MODULE_DIR="${2:?Missing value for --waybar-module-dir}"
            shift 2
            ;;
        --waybar-style-dir)
            WAYBAR_STYLE_DIR="${2:?Missing value for --waybar-style-dir}"
            shift 2
            ;;
        --no-waybar)
            INSTALL_WAYBAR=0
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

is_interactive() {
    [[ "$ASSUME_YES" == "0" && -t 0 ]]
}

ask_path() {
    local label="$1"
    local current="$2"
    local answer

    if ! is_interactive; then
        printf '%s' "$current"
        return 0
    fi

    printf '%s [%s]: ' "$label" "$current" >&2
    read -r answer
    printf '%s' "${answer:-$current}"
}

ask_yes_no() {
    local label="$1"
    local default="$2"
    local answer

    if ! is_interactive; then
        [[ "$default" == "yes" ]]
        return
    fi

    printf '%s [%s]: ' "$label" "$([[ "$default" == "yes" ]] && printf 'Y/n' || printf 'y/N')" >&2
    read -r answer
    answer="${answer:-$default}"

    case "$answer" in
        y|Y|yes|YES|Yes)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

if is_interactive; then
    printf '\n'
    style bold 'Hyprland Caffeine Mode installer'
    printf '\n\nPress Enter to accept a default path.\n\n'

    BIN_DIR="$(ask_path 'Script directory' "$BIN_DIR")"
    DATA_DIR="$(ask_path 'Shared data directory' "$DATA_DIR")"
    CONFIG_DIR="$(ask_path 'Installer metadata directory' "$CONFIG_DIR")"
    SYSTEMD_USER_DIR="$(ask_path 'systemd user directory' "$SYSTEMD_USER_DIR")"

    if ask_yes_no 'Install Waybar snippets?' yes; then
        INSTALL_WAYBAR=1
        WAYBAR_MODULE_DIR="$(ask_path 'Waybar module directory' "$WAYBAR_MODULE_DIR")"
        WAYBAR_STYLE_DIR="$(ask_path 'Waybar style directory' "$WAYBAR_STYLE_DIR")"
    else
        INSTALL_WAYBAR=0
    fi
fi

LIB_DIR="$DATA_DIR/lib"
INSTALL_ENV="$CONFIG_DIR/install.env"
LOCAL_INSTALL_ENV="$BIN_DIR/idle-inhibitor-install.env"
SERVICE_FILE="$SYSTEMD_USER_DIR/caffeine-mode.service"

printf '\n'
info 'Install plan'
printf '  scripts:        %s\n' "$BIN_DIR"
printf '  shared data:    %s\n' "$DATA_DIR"
printf '  metadata:       %s\n' "$INSTALL_ENV"
printf '  script env:     %s\n' "$LOCAL_INSTALL_ENV"
printf '  systemd unit:   %s\n' "$SERVICE_FILE"
if [[ "$INSTALL_WAYBAR" == "1" ]]; then
    printf '  Waybar module:  %s/custom-caffeine.jsonc\n' "$WAYBAR_MODULE_DIR"
    printf '  Waybar CSS:     %s/caffeine.css\n' "$WAYBAR_STYLE_DIR"
else
    printf '  Waybar snippets: skipped\n'
fi
printf '\n'

if is_interactive && ! ask_yes_no 'Continue with this install?' yes; then
    warn 'Install cancelled.'
    exit 0
fi

mkdir -p "$BIN_DIR" "$LIB_DIR" "$CONFIG_DIR" "$SYSTEMD_USER_DIR"

install -m 755 "$ROOT_DIR/bin/idle-inhibitor-toggle.sh" "$BIN_DIR/idle-inhibitor-toggle.sh"
install -m 755 "$ROOT_DIR/bin/idle-inhibitor-status.sh" "$BIN_DIR/idle-inhibitor-status.sh"
install -m 644 "$ROOT_DIR/lib/caffeine-common.sh" "$LIB_DIR/caffeine-common.sh"
install -m 644 "$ROOT_DIR/systemd/caffeine-mode.service" "$SERVICE_FILE"

{
    printf 'CAFFEINE_DATA_DIR=%q\n' "$DATA_DIR"
    printf 'CAFFEINE_BIN_DIR=%q\n' "$BIN_DIR"
    printf 'CAFFEINE_SYSTEMD_USER_DIR=%q\n' "$SYSTEMD_USER_DIR"
    printf 'CAFFEINE_WAYBAR_MODULE_DIR=%q\n' "$WAYBAR_MODULE_DIR"
    printf 'CAFFEINE_WAYBAR_STYLE_DIR=%q\n' "$WAYBAR_STYLE_DIR"
    printf 'CAFFEINE_INSTALL_WAYBAR=%q\n' "$INSTALL_WAYBAR"
} >"$INSTALL_ENV"
chmod 644 "$INSTALL_ENV"
install -m 644 "$INSTALL_ENV" "$LOCAL_INSTALL_ENV"

if [[ "$INSTALL_WAYBAR" == "1" ]]; then
    mkdir -p "$WAYBAR_MODULE_DIR" "$WAYBAR_STYLE_DIR"
    install -m 644 "$ROOT_DIR/waybar/custom-caffeine.jsonc" "$WAYBAR_MODULE_DIR/custom-caffeine.jsonc"
    install -m 644 "$ROOT_DIR/waybar/caffeine.css" "$WAYBAR_STYLE_DIR/caffeine.css"
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

success 'Installed caffeine-mode files.'
printf '\nNext steps:\n'
printf '  1. Add %s to PATH if it is not already there.\n' "$BIN_DIR"
if [[ "$INSTALL_WAYBAR" == "1" ]]; then
    printf '  2. Import the Waybar module from %s/custom-caffeine.jsonc.\n' "$WAYBAR_MODULE_DIR"
    printf '  3. Import the CSS from %s/caffeine.css.\n' "$WAYBAR_STYLE_DIR"
else
    printf '  2. Add your own Waybar module or rerun without --no-waybar.\n'
    printf '  3. Skip Waybar CSS import.\n'
fi
printf '  4. Add the Hyprland bind from %s/hyprland/keybinds.conf.\n' "$ROOT_DIR"
printf '  5. Reload Hyprland and restart Waybar if you changed Waybar config.\n'
printf '\nTry it:\n'
printf '  idle-inhibitor-toggle.sh toggle\n'
printf '  idle-inhibitor-status.sh waybar\n'
