#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${CAFFEINE_SERVICE_NAME:-caffeine-mode.service}"
STATE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
PIDFILE="${STATE_DIR}/caffeine-mode.pid"
ACTIVE_TEXT="${CAFFEINE_ACTIVE_TEXT:-ON}"
INACTIVE_TEXT="${CAFFEINE_INACTIVE_TEXT:-OFF}"
REQUIRE_SERVICE="${CAFFEINE_REQUIRE_SERVICE:-0}"

json_escape() {
    local value="${1-}"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/\\n}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\t'/\\t}"
    printf '%s' "$value"
}

service_active() {
    command -v systemctl >/dev/null 2>&1 || return 1
    systemctl --user is-active --quiet "$SERVICE_NAME"
}

fallback_active() {
    local pid

    [[ -f "$PIDFILE" ]] || return 1
    pid="$(<"$PIDFILE")"
    [[ "$pid" =~ ^[0-9]+$ ]] || return 1
    kill -0 "$pid" 2>/dev/null
}

print_plain_status() {
    if service_active || { [[ "$REQUIRE_SERVICE" != "1" ]] && fallback_active; }; then
        printf 'activated\n'
    else
        printf 'deactivated\n'
    fi
}

print_waybar_json() {
    local state text tooltip class

    if service_active; then
        state="activated"
        text="$ACTIVE_TEXT"
        class="activated"
        tooltip="Caffeine mode active"$'\n'"Managed by systemd user service"
    elif [[ "$REQUIRE_SERVICE" != "1" ]] && fallback_active; then
        state="activated"
        text="$ACTIVE_TEXT"
        class="activated"
        tooltip="Caffeine mode active"$'\n'"Managed by background fallback process"
    else
        state="deactivated"
        text="$INACTIVE_TEXT"
        class="deactivated"
        tooltip="Caffeine mode inactive"$'\n'"System will follow normal idle settings"
    fi

    printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$text")" \
        "$(json_escape "$state")" \
        "$(json_escape "$tooltip")" \
        "$(json_escape "$class")"
}

case "${1:-waybar}" in
    status)
        print_plain_status
        ;;
    waybar)
        print_waybar_json
        ;;
    *)
        printf 'Usage: %s [status|waybar]\n' "${0##*/}" >&2
        exit 1
        ;;
esac
