#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Makes sure HDMI-1 is running at 1920x1080 when the TV offers that mode.
# If the active mode is already that, it does nothing.
xrandr --listmonitors | grep -q '+\*HDMI-1 1920/' && exit 0
xrandr --output HDMI-1 --mode 1920x1080 --rate 60 2>/dev/null
exit 0
