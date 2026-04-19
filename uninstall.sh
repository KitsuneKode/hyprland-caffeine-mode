#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DEFAULT_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland-caffeine-mode"
DEFAULT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprland-caffeine-mode"
DEFAULT_SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
DEFAULT_WAYBAR_MODULE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/waybar/modules"
DEFAULT_WAYBAR_STYLE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/waybar/styles/classes"

CONFIG_DIR="$DEFAULT_CONFIG_DIR"
INSTALL_ENV="$CONFIG_DIR/install.env"
ASSUME_YES=0
REMOVE_WAYBAR=1

usage() {
    cat <<EOF
Usage: ./uninstall.sh [options]

Options:
  -y, --yes          Do not prompt
      --config-dir DIR
                    Read installer metadata from DIR
      --keep-waybar  Leave Waybar snippets in place
  -h, --help         Show this help
EOF
}

while (($#)); do
    case "$1" in
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        --config-dir)
            CONFIG_DIR="${2:?Missing value for --config-dir}"
            INSTALL_ENV="$CONFIG_DIR/install.env"
            shift 2
            ;;
        --keep-waybar)
            REMOVE_WAYBAR=0
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

if [[ -f "$INSTALL_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$INSTALL_ENV"
fi

BIN_DIR="${CAFFEINE_BIN_DIR:-$DEFAULT_BIN_DIR}"
DATA_DIR="${CAFFEINE_DATA_DIR:-$DEFAULT_DATA_DIR}"
SYSTEMD_USER_DIR="${CAFFEINE_SYSTEMD_USER_DIR:-$DEFAULT_SYSTEMD_USER_DIR}"
WAYBAR_MODULE_DIR="${CAFFEINE_WAYBAR_MODULE_DIR:-$DEFAULT_WAYBAR_MODULE_DIR}"
WAYBAR_STYLE_DIR="${CAFFEINE_WAYBAR_STYLE_DIR:-$DEFAULT_WAYBAR_STYLE_DIR}"

is_interactive() {
    [[ "$ASSUME_YES" == "0" && -t 0 ]]
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

printf '\nHyprland Caffeine Mode uninstall\n\n'
printf 'Will remove:\n'
printf '  %s/idle-inhibitor-toggle.sh\n' "$BIN_DIR"
printf '  %s/idle-inhibitor-status.sh\n' "$BIN_DIR"
printf '  %s/idle-inhibitor-install.env\n' "$BIN_DIR"
printf '  %s/lib/caffeine-common.sh\n' "$DATA_DIR"
printf '  %s/caffeine-mode.service\n' "$SYSTEMD_USER_DIR"
printf '  %s\n' "$INSTALL_ENV"
if [[ "$REMOVE_WAYBAR" == "1" ]]; then
    printf '  %s/custom-caffeine.jsonc\n' "$WAYBAR_MODULE_DIR"
    printf '  %s/caffeine.css\n' "$WAYBAR_STYLE_DIR"
fi
printf '\n'

if is_interactive && ! ask_yes_no 'Continue with uninstall?' yes; then
    printf 'Uninstall cancelled.\n'
    exit 0
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop caffeine-mode.service 2>/dev/null || true
    systemctl --user disable caffeine-mode.service 2>/dev/null || true
fi

rm -f "$BIN_DIR/idle-inhibitor-toggle.sh"
rm -f "$BIN_DIR/idle-inhibitor-status.sh"
rm -f "$BIN_DIR/idle-inhibitor-install.env"
rm -f "$DATA_DIR/lib/caffeine-common.sh"
rm -f "$SYSTEMD_USER_DIR/caffeine-mode.service"
rm -f "$INSTALL_ENV"

if [[ "$REMOVE_WAYBAR" == "1" ]]; then
    rm -f "$WAYBAR_MODULE_DIR/custom-caffeine.jsonc"
    rm -f "$WAYBAR_STYLE_DIR/caffeine.css"
fi

rmdir "$DATA_DIR/lib" "$DATA_DIR" "$CONFIG_DIR" 2>/dev/null || true

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

printf 'Removed installed caffeine-mode files.\n'
