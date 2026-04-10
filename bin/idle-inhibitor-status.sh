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
