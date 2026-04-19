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

print_plain_status() {
    if is_active; then
        printf 'activated\n'
    else
        printf 'deactivated\n'
    fi
}

print_waybar_json() {
    local state text tooltip class
    local backend

    backend="$(current_backend)"

    if [[ "$backend" == "none" ]]; then
        state="deactivated"
        text="$INACTIVE_TEXT"
        class="deactivated"
    else
        state="activated"
        text="$ACTIVE_TEXT"
        class="activated"
    fi

    tooltip="$(backend_tooltip "$backend")"

    printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$text")" \
        "$(json_escape "$state")" \
        "$(json_escape "$tooltip")" \
        "$(json_escape "$class")"
}

print_diagnostics() {
    local backend
    backend="$(current_backend)"

    printf 'state=%s\n' "$(is_active && printf 'activated' || printf 'deactivated')"
    printf 'backend=%s\n' "$backend"
    printf 'service=%s\n' "$SERVICE_NAME"

    if have_user_systemd; then
        systemctl --user show "$SERVICE_NAME" \
            -p LoadState \
            -p ActiveState \
            -p SubState \
            -p FragmentPath \
            -p UnitFileState 2>/dev/null || true
    else
        printf 'systemd_user=unavailable\n'
    fi

    if command -v systemd-inhibit >/dev/null 2>&1; then
        systemd-inhibit --list --no-pager --no-legend 2>/dev/null | grep -F "$WHO" || true
    fi
}

case "${1:-waybar}" in
    status)
        print_plain_status
        ;;
    active|is-active)
        is_active
        ;;
    inactive|is-inactive)
        ! is_active
        ;;
    waybar)
        print_waybar_json
        ;;
    diagnose|diagnostics)
        print_diagnostics
        ;;
    *)
        printf 'Usage: %s [status|active|inactive|waybar|diagnose]\n' "${0##*/}" >&2
        exit 1
        ;;
esac
