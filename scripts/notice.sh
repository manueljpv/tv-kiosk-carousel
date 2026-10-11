#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Shows the welcome or goodbye screen for 20 seconds on top of the carousel.
# Usage: notice.sh welcome   or   notice.sh goodbye
# The language of the messages comes from KIOSK_LANG (en, pt or es; default en).
# If the carousel is not running, it does nothing.
export DISPLAY=:0
DIR="$HOME/kiosk"
MODE="${1:-welcome}"
LANG_CODE="${KIOSK_LANG:-en}"

pgrep -f "user-data-dir=$DIR/chrome-profile" >/dev/null || exit 0

# kiosk.sh stops switching tabs while this file is recent
touch /tmp/kiosk-pause

# Open the page as a new tab in the same kiosk Chrome
google-chrome-stable --user-data-dir="$DIR/chrome-profile" \
  "file://$DIR/welcome.html?mode=$MODE&lang=$LANG_CODE" >/dev/null 2>&1 &
sleep 3

id=$(xdotool search --onlyvisible --class "google-chrome" | head -n1)
[ -n "$id" ] && xdotool windowactivate "$id"

sleep 17          # total duration: 3 + 17 = 20 seconds
xdotool key ctrl+w
rm -f /tmp/kiosk-pause
