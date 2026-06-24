#!/usr/bin/env bash
# Power menu for the waybar button: a wofi dmenu (themed via the shared wofi
# style) offering the usual session actions. Escape / no selection is a no-op.
set -uo pipefail

entries=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

chosen="$(printf '%b' "$entries" | wofi --dmenu --prompt power --width 260 --height 300)"

case "$chosen" in
    *Lock)     exec hyprlock ;;
    *Logout)   exec hyprctl dispatch exit ;;
    *Suspend)  exec systemctl suspend ;;
    *Reboot)   exec systemctl reboot ;;
    *Shutdown) exec systemctl poweroff ;;
    *)         exit 0 ;;
esac
