#!/usr/bin/env bash
# Cycle the Logitech G903 through a list of DPI presets via ratbagctl, notify
# the new value, and poke waybar so the mouse module's tooltip refreshes.
# Bound to the waybar custom/mouse module's on-click.
set -u

# Edit this list to change the presets the click cycles through.
PRESETS=(400 800 1600 3200)

notify() {
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send -t 1500 -i input-mouse \
        -h string:x-canonical-private-synchronous:mouse-dpi \
        "Mouse DPI" "$1"
}

if ! command -v ratbagctl >/dev/null 2>&1; then
    notify "ratbagctl not found"
    exit 1
fi

dev=$(ratbagctl list 2>/dev/null | grep -i 'g903' | head -1 | cut -d: -f1)
if [ -z "$dev" ]; then
    notify "G903 not detected"
    exit 1
fi

cur=$(ratbagctl "$dev" dpi get 2>/dev/null | grep -o '[0-9]\+' | head -1)

# Pick the next preset: the one after an exact match, else the smallest preset
# greater than the current DPI, else wrap back to the first.
next="${PRESETS[0]}"
n=${#PRESETS[@]}
matched=0
for ((i = 0; i < n; i++)); do
    if [ "${PRESETS[$i]}" = "$cur" ]; then
        next="${PRESETS[$(((i + 1) % n))]}"
        matched=1
        break
    fi
done
if [ "$matched" -eq 0 ] && [ -n "${cur:-}" ]; then
    for p in "${PRESETS[@]}"; do
        if [ "$p" -gt "$cur" ]; then next="$p"; break; fi
    done
fi

if ratbagctl "$dev" dpi set "$next" >/dev/null 2>&1; then
    notify "${next} DPI"
else
    notify "Failed to set ${next} DPI"
fi

# Refresh the waybar mouse module (matches "signal": 9 in config.jsonc).
pkill -RTMIN+9 waybar 2>/dev/null || true
