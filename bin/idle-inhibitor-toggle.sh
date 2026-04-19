#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_HELPER="$SCRIPT_DIR/../lib/caffeine-common.sh"
DEFAULT_INSTALL_ENV="${XDG_CONFIG_HOME:-$HOME/.config}/hyprland-caffeine-mode/install.env"
LOCAL_INSTALL_ENV="$SCRIPT_DIR/idle-inhibitor-install.env"
INSTALL_ENV="${CAFFEINE_INSTALL_ENV:-}"

if [[ -n "$INSTALL_ENV" && -f "$INSTALL_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$INSTALL_ENV"
elif [[ -f "$LOCAL_INSTALL_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$LOCAL_INSTALL_ENV"
elif [[ -f "$DEFAULT_INSTALL_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$DEFAULT_INSTALL_ENV"
fi

INSTALLED_HELPER="${CAFFEINE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/hyprland-caffeine-mode}/lib/caffeine-common.sh"

if [[ -f "$REPO_HELPER" ]]; then
    # shellcheck source=../lib/caffeine-common.sh
    source "$REPO_HELPER"
elif [[ -f "$INSTALLED_HELPER" ]]; then
    # shellcheck source=/dev/null
    source "$INSTALLED_HELPER"
else
    printf 'Unable to locate caffeine-common.sh\n' >&2
    exit 1
fi

usage() {
    cat <<'EOF'
Usage: idle-inhibitor-toggle.sh [toggle|on|off|status|waybar|diagnose]

Commands:
  toggle  Toggle caffeine mode on or off (default)
  on      Enable caffeine mode
  off     Disable caffeine mode
  status  Print "activated" or "deactivated"
  waybar  Print Waybar-compatible JSON
  diagnose Print service and inhibitor details

Requires:
  - systemd --user
  - caffeine-mode.service installed

Environment:
  - CAFFEINE_WAYBAR_SIGNAL=N    Notify Waybar via SIGRTMIN+N after state changes
  - CAFFEINE_WAYBAR_SIGNAL=off  Disable Waybar notification
EOF
}

start_service() {
    systemctl --user start "$SERVICE_NAME"
    if ! service_active; then
        printf 'Error: %s did not become active.\n' "$SERVICE_NAME" >&2
        exit 1
    fi
}

stop_service() {
    systemctl --user stop "$SERVICE_NAME"
}

start_caffeine() {
    if is_active; then
        return 0
    fi

    if ! have_user_systemd; then
        printf 'Error: systemd --user is not available.\n' >&2
        exit 1
    fi

    if ! service_exists; then
        printf 'Error: %s is not installed.\n' "$SERVICE_NAME" >&2
        printf 'Run: systemctl --user enable --now %s\n' "$SERVICE_NAME" >&2
        exit 1
    fi

    start_service

    notify_state "Caffeine Mode" "Activated"
    notify_waybar
}

stop_caffeine() {
    local backend
    backend="$(current_backend)"
    [[ "$backend" == "none" ]] && return 0

    stop_service
    notify_state "Caffeine Mode" "Deactivated"
    notify_waybar
}

main() {
    local command="${1:-toggle}"

    case "$command" in
        toggle)
            if is_active; then
                stop_caffeine
            else
                start_caffeine
            fi
            ;;
        on)
            start_caffeine
            ;;
        off)
            stop_caffeine
            ;;
        status)
            exec "$SCRIPT_DIR/idle-inhibitor-status.sh" status
            ;;
        waybar)
            exec "$SCRIPT_DIR/idle-inhibitor-status.sh" waybar
            ;;
        diagnose|diagnostics)
            exec "$SCRIPT_DIR/idle-inhibitor-status.sh" diagnose
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            echo "Unknown command: $command" >&2
            usage >&2
            exit 1
            ;;
    esac
}

main "$@"
