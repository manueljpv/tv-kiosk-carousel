#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Automatic start at login: only starts inside working hours (Monday to Friday,
# 08:00 to 18:00). Outside those hours the machine stays idle; use start.sh to
# start the carousel by hand.
day=$(date +%u)              # 1 = Monday ... 7 = Sunday
now=$((10#$(date +%H%M)))    # e.g. 0800 becomes 800
if [ "$day" -le 5 ] && [ "$now" -ge 800 ] && [ "$now" -lt 1800 ]; then
  exec "$HOME/kiosk/start.sh"
fi
exit 0
