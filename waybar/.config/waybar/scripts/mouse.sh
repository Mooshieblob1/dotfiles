#!/usr/bin/env bash
# Waybar mouse module: shows the Logitech G903's battery level (read from the
# hid-logitech sysfs power_supply class) with the current DPI in the tooltip.
# DPI cycling is handled by mouse-dpi.sh on click. No jq needed.
set -u

ICON="󰍽"  # nf-md-mouse

emit() { printf '%s\n' "$1"; }

# JSON-escape a string (quotes, backslashes, newlines).
jesc() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    printf '%s' "$s"
}

# --- battery ----------------------------------------------------------------
# Find the hidpp power_supply node belonging to the G903 (numbering is not
# stable across reconnects, so match on model_name rather than a fixed index).
cap="" ; status="" ; volt=""
for ps in /sys/class/power_supply/hidpp_battery_*; do
    [ -e "$ps/model_name" ] || continue
    if grep -qi 'G903' "$ps/model_name" 2>/dev/null; then
        cap=$(cat "$ps/capacity" 2>/dev/null)
        status=$(cat "$ps/status" 2>/dev/null)
        volt=$(cat "$ps/voltage_now" 2>/dev/null)
        break
    fi
done

# Mouse asleep / powered off / receiver unplugged -> no sysfs node.
if [ -z "$cap" ]; then
    emit "$(printf '{"text":"%s","tooltip":"%s","class":"disconnected"}' \
        "$ICON" "$(jesc 'G903 — offline')")"
    exit 0
fi

# --- DPI (for the tooltip) --------------------------------------------------
dpi=""
if command -v ratbagctl >/dev/null 2>&1; then
    dev=$(ratbagctl list 2>/dev/null | grep -i 'g903' | head -1 | cut -d: -f1)
    [ -n "$dev" ] && dpi=$(ratbagctl "$dev" dpi get 2>/dev/null | grep -o '[0-9]\+' | head -1)
fi

# --- state class ------------------------------------------------------------
# The G903 has no fuel gauge: the kernel derives "capacity" from battery
# voltage, which sags under load and jumps up the moment USB charging applies.
# The percent is therefore unreliable while charging, so we hide it then and
# show a charging glyph instead — the raw estimate stays in the tooltip.
CHG="󱐋"  # nf-md-lightning_bolt
class="good"
case "$status" in
    Charging|Full)
        class="charging"
        text="${ICON} ${CHG}"
        ;;
    *)
        if   [ "$cap" -le 15 ]; then class="critical"
        elif [ "$cap" -le 30 ]; then class="warning"
        fi
        text="${ICON} ${cap}%"
        ;;
esac

tip="G903 LIGHTSPEED"
tip="${tip}"$'\n'"Battery ~${cap}% (${status}, voltage-estimated)"
[ -n "$volt" ] && tip="${tip}"$'\n'"$(awk "BEGIN{printf \"%.2f V\", ${volt}/1000000}")"
[ -n "$dpi" ] && tip="${tip}"$'\n'"DPI ${dpi}"$'\n'"Click to cycle DPI"

emit "$(printf '{"text":"%s","tooltip":"%s","class":"%s"}' \
    "$(jesc "$text")" "$(jesc "$tip")" "$class")"
