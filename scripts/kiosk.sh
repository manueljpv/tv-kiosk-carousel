#!/bin/bash
# tv-kiosk-carousel - Copyright (C) 2026 Manuel Pérez - GPL-3.0-or-later
#
# Main carousel: opens Chrome in kiosk mode with the URLs from ~/kiosk/urls.txt
# and, every INTERVAL seconds, switches to the next tab and reloads the page.

DIR="$HOME/kiosk"
URLS_FILE="$DIR/urls.txt"
INTERVAL=45   # seconds each tab stays on screen

mapfile -t URLS < <(grep -v -E '^\s*(#|$)' "$URLS_FILE")
[ "${#URLS[@]}" -eq 0 ] && { echo "No URLs in $URLS_FILE"; exit 1; }

# Wait for the network (up to 120 s)
nm-online -q -t 120

"$DIR/display.sh"

# Hide the mouse cursor after 1 s idle
pkill unclutter 2>/dev/null
unclutter -idle 1 -root &

# Close any old instance and open Chrome in full-screen kiosk mode
pkill -f "user-data-dir=$DIR/chrome-profile" 2>/dev/null
sleep 1
google-chrome-stable --kiosk --user-data-dir="$DIR/chrome-profile" \
  --no-first-run --noerrdialogs --disable-infobars \
  --disable-session-crashed-bubble --password-store=basic \
  --autoplay-policy=no-user-gesture-required \
  "${URLS[@]}" >/dev/null 2>&1 &

sleep 20

# Bring the Chrome window to the front
focus() {
  local id
  id=$(xdotool search --onlyvisible --class "google-chrome" | head -n1)
  [ -n "$id" ] && xdotool windowactivate "$id"
}

while true; do
  sleep "$INTERVAL"
  # Skip the tab switch while a notice screen is showing (the file is valid for 1 minute)
  [ -n "$(find /tmp/kiosk-pause -mmin -1 2>/dev/null)" ] && continue
  # If Chrome has closed, start over
  pgrep -f "user-data-dir=$DIR/chrome-profile" >/dev/null || exec "$0"
  "$DIR/display.sh"
  focus
  if [ "${#URLS[@]}" -gt 1 ]; then xdotool key ctrl+Tab; sleep 1; fi
  xdotool key F5
done
