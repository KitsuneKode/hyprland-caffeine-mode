#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_HELPER="$SCRIPT_DIR/../lib/caffeine-common.sh"
INSTALLED_HELPER="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland-caffeine-mode/lib/caffeine-common.sh"

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
Usage: idle-inhibitor-toggle.sh [toggle|on|off|status|waybar]

Commands:
  toggle  Toggle caffeine mode on or off (default)
  on      Enable caffeine mode
  off     Disable caffeine mode
  status  Print "activated" or "deactivated"
  waybar  Print Waybar-compatible JSON

Behavior:
  - Preferred backend: a user systemd service named caffeine-mode.service
  - Fallback backend: a managed background systemd-inhibit process
  - Set CAFFEINE_REQUIRE_SERVICE=1 to disable the fallback backend
  - Set CAFFEINE_WAYBAR_SIGNAL=N to notify Waybar via SIGRTMIN+N after state changes
EOF
}

start_service() {
    systemctl --user start "$SERVICE_NAME"
}

stop_service() {
    systemctl --user stop "$SERVICE_NAME"
}

start_fallback() {
    local pid

    if fallback_pid >/dev/null; then
        return 0
    fi

    nohup systemd-inhibit \
        --what=idle \
        --who="$WHO" \
        --why="$WHY" \
        --mode="$MODE" \
        sleep infinity >/dev/null 2>&1 &
    pid=$!
    printf '%s\n' "$pid" >"$PIDFILE"
    sleep 0.1

    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$PIDFILE"
        echo "Failed to start systemd-inhibit fallback process." >&2
        exit 1
    fi
}

stop_fallback() {
    local pid

    if ! pid="$(fallback_pid)"; then
        return 0
    fi

    kill "$pid" >/dev/null 2>&1 || true
    rm -f "$PIDFILE"
}

start_caffeine() {
    if is_active; then
        return 0
    fi

    if have_user_systemd && service_exists; then
        start_service
    elif [[ "$REQUIRE_SERVICE" == "1" ]]; then
        echo "caffeine-mode.service is required but was not found in the user systemd manager." >&2
        exit 1
    else
        start_fallback
    fi

    notify_state "Caffeine Mode" "Activated"
    notify_waybar
}

stop_caffeine() {
    if ! is_active; then
        return 0
    fi

    if have_user_systemd && service_exists && service_active; then
        stop_service
    fi

    stop_fallback
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
