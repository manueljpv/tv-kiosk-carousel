#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Stops the carousel (script, kiosk Chrome and cursor hider).
# Used by the end-of-day cron job and as an emergency exit.
# Do not use Alt+F4 or F11 on the TV: kiosk.sh reopens Chrome.
pkill -f "$HOME/kiosk/kiosk.sh"
pkill -f "user-data-dir=$HOME/kiosk/chrome-profile"
pkill unclutter
