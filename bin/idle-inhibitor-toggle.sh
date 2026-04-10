#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${CAFFEINE_SERVICE_NAME:-caffeine-mode.service}"
STATE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
PIDFILE="${STATE_DIR}/caffeine-mode.pid"
WHO="${CAFFEINE_WHO:-Caffeine Mode}"
WHY="${CAFFEINE_WHY:-Manual idle inhibition}"
MODE="${CAFFEINE_MODE:-block}"
ACTIVE_TEXT="${CAFFEINE_ACTIVE_TEXT:-ON}"
INACTIVE_TEXT="${CAFFEINE_INACTIVE_TEXT:-OFF}"
REQUIRE_SERVICE="${CAFFEINE_REQUIRE_SERVICE:-0}"
WAYBAR_SIGNAL="${CAFFEINE_WAYBAR_SIGNAL:-}"

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

json_escape() {
    local value="${1-}"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/\\n}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\t'/\\t}"
    printf '%s' "$value"
}

notify_state() {
    local summary="$1"
    local body="$2"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u normal -t 2000 "$summary" "$body" >/dev/null 2>&1 || true
    fi
}

notify_waybar() {
    [[ -n "$WAYBAR_SIGNAL" ]] || return 0

    if command -v pkill >/dev/null 2>&1; then
        pkill "-RTMIN+${WAYBAR_SIGNAL}" waybar >/dev/null 2>&1 || true
    fi
}

have_user_systemd() {
    command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1
}

service_exists() {
    systemctl --user cat "$SERVICE_NAME" >/dev/null 2>&1
}

service_active() {
    systemctl --user is-active --quiet "$SERVICE_NAME"
}

fallback_pid() {
    local pid

    [[ -f "$PIDFILE" ]] || return 1
    pid="$(<"$PIDFILE")"

    if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
        rm -f "$PIDFILE"
        return 1
    fi

    if kill -0 "$pid" 2>/dev/null; then
        printf '%s\n' "$pid"
        return 0
    fi

    rm -f "$PIDFILE"
    return 1
}

current_backend() {
    if have_user_systemd && service_exists && service_active; then
        printf 'systemd\n'
        return 0
    fi

    if fallback_pid >/dev/null; then
        printf 'process\n'
        return 0
    fi

    printf 'none\n'
}

is_active() {
    [[ "$(current_backend)" != "none" ]]
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

print_status() {
    if is_active; then
        printf 'activated\n'
    else
        printf 'deactivated\n'
    fi
}

print_waybar_json() {
    local backend state text tooltip class

    backend="$(current_backend)"

    if [[ "$backend" == "none" ]]; then
        state="deactivated"
        text="$INACTIVE_TEXT"
        class="deactivated"
        tooltip="Caffeine mode inactive"
    else
        state="activated"
        text="$ACTIVE_TEXT"
        class="activated"
        tooltip="Caffeine mode active"
    fi

    if [[ "$backend" == "systemd" ]]; then
        tooltip="${tooltip}"$'\n'"Managed by systemd user service"
    elif [[ "$backend" == "process" ]]; then
        tooltip="${tooltip}"$'\n'"Managed by background fallback process"
    else
        tooltip="${tooltip}"$'\n'"System will follow normal idle settings"
    fi

    printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$text")" \
        "$(json_escape "$state")" \
        "$(json_escape "$tooltip")" \
        "$(json_escape "$class")"
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
            print_status
            ;;
        waybar)
            print_waybar_json
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
