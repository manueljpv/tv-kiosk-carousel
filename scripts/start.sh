#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Starts the carousel if it is not already running.
# Can be run over SSH, from cron, or from auto.sh.
export DISPLAY=:0
pgrep -f "$HOME/kiosk/kiosk.sh" >/dev/null && exit 0
xset s off -dpms s noblank
nohup "$HOME/kiosk/kiosk.sh" >/tmp/kiosk.log 2>&1 &
