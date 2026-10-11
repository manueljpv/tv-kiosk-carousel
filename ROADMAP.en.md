# Roadmap

[Português](ROADMAP.md) · **English** · [Español (Honduras)](ROADMAP.es-HN.md)

Planned improvements for the project and what we have learned so far. These are ideas with no guaranteed dates, and the order is not final.

## Short term

Small improvements that fit the current scripts and configuration.

- [ ] **Holidays.** Cron only knows weekdays: the carousel starts and the notice screens appear on any working day, holidays included. Create a list of dates (`holidays.txt`) that `auto.sh` and `start.sh` check before starting.
- [ ] **Automatic security updates.** With `mintupdate` disabled, updates are manual. Evaluate `unattended-upgrades` for security only, with a controlled reboot outside working hours.
- [ ] **Configuration in one place.** Today the schedule lives in the crontab and in `auto.sh`, and the interval in `kiosk.sh`. Gather everything in a `kiosk.conf` file (schedule, interval, language, holiday list).
- [ ] **Periodic Chrome restart.** On carousels that stay on for many days, Chrome may use more memory over time. Restart only the kiosk (not the machine) once a day, outside working hours.
- [ ] **Idle screen outside working hours.** When the carousel stops, the Linux desktop shows on the TV. Replace it with a black screen or a simple image.
- [ ] **Exit keyboard shortcut.** A shortcut that runs `stop.sh`, for whoever has a keyboard attached to the machine.
- [ ] **Time per page.** Allow a different interval for each URL (for example, `url;60`).
- [ ] **Automated tests.** Run `shellcheck` on the scripts on every change (GitHub Actions).

## Long term

Larger changes that need a project of their own.

- [ ] **Turn the TV on and off automatically.** Today the TV is turned on and off by hand. Try HDMI-CEC (`libcec`) so the mini PC controls the TV, on models that support it.
- [ ] **Self-hosted RustDesk server.** Today RustDesk uses the project's public servers. A self-hosted server gives more control over access and logs.
- [ ] **Several machines.** Standardize deployment on other identical mini PCs: an `install.sh` script that applies everything, or an Ansible playbook, plus one configuration per machine (IP, pages, schedule).
- [ ] **Monitor the carousel itself.** A "still alive" signal (heartbeat) sent to a monitoring tool, with an alert if the carousel stops or the page goes down.
- [ ] **Fewer dependencies.** Replace `xdotool` (which simulates key presses) with direct control of Chrome (debugging port), and evaluate a minimal graphical environment instead of the full Xfce.
- [ ] **Content by time.** Different pages for different periods of the day or week, and an urgent notice message that overlays the carousel.

## What we learned

- **Reusing idle equipment pays off.** Mini PCs forgotten in a cabinet were a better solution than a laptop: smaller, cooler, with a wired network port and no moving parts. Before buying or adapting anything, look for what already exists.
- **Test HDMI with someone next to the machine.** A newer kernel froze the system when the cable was plugged in (and cut the remote access). Pinning the kernel that works solved it. Rule out causes one by one, with tests, instead of blaming the cable, the TV or the browser.
- **Simulate before removing.** `apt -s purge` shows what will go with it. Create a restore point (Timeshift) before touching the system.
- **Keep an SSH session open when enabling the firewall.** If a rule is wrong, you can still undo it.
- **Change one thing at a time and validate with a reboot.** On a machine with no keyboard and no spare screen, the reboot is the test that matters.
- **Cron only knows minutes and a reduced environment.** Use `sleep` to adjust seconds, and test the script with the minimal environment (`env -i`) before trusting it.
- **A carousel has to restart itself.** If Chrome closes, the script starts over; outside working hours, `auto.sh` stops it from opening needlessly.
- **Dashboard tokens and URLs are secrets.** Keep the real `urls.txt` out of the repository (`.gitignore`) and publish only `urls.txt.example`.
- **Not everything is a Linux problem.** An image cut at the edges (overscan) is fixed on the TV itself.
- **Document as you go.** The step-by-step guide, what went wrong and how to roll back are what make the project repeatable on another machine.
