#!/usr/bin/env bash

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

fallback_active() {
    fallback_pid >/dev/null
}

current_backend() {
    if have_user_systemd && service_exists && service_active; then
        printf 'systemd\n'
        return 0
    fi

    if fallback_active; then
        printf 'process\n'
        return 0
    fi

    printf 'none\n'
}

is_active() {
    [[ "$(current_backend)" != "none" ]]
}

backend_tooltip() {
    case "${1:-none}" in
        systemd)
            printf 'Caffeine mode active\nManaged by systemd user service\n'
            ;;
        process)
            printf 'Caffeine mode active\nManaged by background fallback process\n'
            ;;
        *)
            printf 'Caffeine mode inactive\nSystem will follow normal idle settings\n'
            ;;
    esac
}
