#!/usr/bin/env bash

SERVICE_NAME="${CAFFEINE_SERVICE_NAME:-caffeine-mode.service}"
WHO="${CAFFEINE_WHO:-Caffeine Mode}"
WHY="${CAFFEINE_WHY:-Manual idle inhibition}"
MODE="${CAFFEINE_MODE:-block}"
ACTIVE_TEXT="${CAFFEINE_ACTIVE_TEXT:-ON}"
INACTIVE_TEXT="${CAFFEINE_INACTIVE_TEXT:-OFF}"
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

current_backend() {
    if have_user_systemd && service_exists && service_active; then
        printf 'systemd\n'
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
        *)
            printf 'Caffeine mode inactive\nSystem will follow normal idle settings\n'
            ;;
    esac
}
