# Installation and tuning of the mini PC

Step by step guide to turn a repurposed mini PC into a TV screen that starts by itself and runs a page carousel in Chrome. All addresses, names and users below are fictional examples.

Example values used in this document:

| Item | Example |
|---|---|
| User | `kiosk` |
| Computer name | `tv-kiosk` |
| Fixed IP of the mini PC | `192.0.2.20/24` |
| Gateway | `192.0.2.1` |
| Internal DNS | `192.0.2.53` (plus `8.8.8.8` as backup) |
| Site shown in the carousel | `http://192.0.2.10:8080` |
| Trusted ranges (SSH) | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` |
| MAC (fictional) | `02:00:00:00:00:01` |

## 1. System

- Linux Mint 21.3 Xfce (Ubuntu 22.04 base), X11, automatic login of the `kiosk` user (LightDM).
- Time zone set correctly and clock synchronized (check with `timedatectl`).
- A small disk is enough: about 10 GB stay in use after the tuning.

## 2. Fixed IP on the network

Reserve the IP in the DHCP server of your router/firewall (using the MAC of the network card) and set the same IP on Linux:

```
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.0.2.20/24 \
  ipv4.gateway 192.0.2.1 \
  ipv4.dns "192.0.2.53 8.8.8.8" \
  ipv4.ignore-auto-dns yes
sudo nmcli connection up "Wired connection 1"
```

Check: `ip -4 -brief addr show` must show the fixed IP.

## 3. Remote access

SSH as the main access and RustDesk as a last resort. Details in [remote-access.md](remote-access.md). Set this up first, so the rest can be done without a keyboard and mouse on the machine.

## 4. System tuning

### 4.1 Power and screen: the machine never sleeps

Block the systemd sleep targets:

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Install the file [`config/logind-99-always-on.conf`](../../config/logind-99-always-on.conf) as `/etc/systemd/logind.conf.d/99-always-on.conf`.

In Xfce, turn off the power manager timers and the screen lock (channel `xfce4-power-manager`):

```
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 14
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -s true
```

(`inactivity-on-ac = 14` means "never" in that interface.) If one of these properties does not exist yet, create it with `-n -t <type>`.

The `start.sh` script also runs `xset s off -dpms s noblank` when it starts the carousel.

### 4.2 Programs that start by themselves: disable

For each item below, create `~/.config/autostart/<name>.desktop` with only the lines below (it overrides the system default):

```
[Desktop Entry]
Type=Application
Name=<name>
Hidden=true
```

Items: mintwelcome, mintupdate, mintreport, blueman, warpinator-autostart, print-applet, onboard-autostart, orca-autostart, caribou-autostart, geoclue-demo-agent, org.gnome.Evolution-alarm-notify, sticky, xscreensaver and light-locker.

Note: without `mintupdate` there is no update notice. Updates become manual (`sudo apt update && sudo apt upgrade`).

### 4.3 Unneeded services: disable

```
sudo systemctl disable --now bluetooth blueman-mechanism cups.socket cups.path cups cups-browsed ModemManager avahi-daemon.socket avahi-daemon kerneloops
```

If the machine has ZFS installed, also disable: `zfs-zed`, `zfs-share`, `zfs-mount`, `zfs-volume-wait`, `zfs-import-cache`, `zfs-load-module`.

### 4.4 Unneeded programs: remove

Always simulate first:

```
sudo apt-get -s purge <package>
sudo apt-get purge <package>
```

Removed in this project: Firefox, Thunderbird, LibreOffice (all packages), Rhythmbox, Celluloid, Hypnotix, Transmission, HexChat, Pix, Drawing, Document Scanner, Redshift, Warpinator, Onboard, OpenVPN and plugins, and old kernels. This freed about 3.4 GB.

Kept on purpose: Python, fonts, themes, Timeshift and Synaptic.

## 5. Video

### Without a monitor, remote access shows "No Displays"

A "phantom" output (VGA) shows up as connected but does not keep the screen alive. Fix: force HDMI-1 as always on with a kernel parameter. In `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=HDMI-A-1:1920x1080@60e"
```

Then:

```
sudo cp /etc/default/grub /etc/default/grub.bak-hdmi
sudo update-grub
```

(Make the backup before editing.) Without a monitor, the virtual screen comes up at 1024x768, which is enough for remote access.

The TV must always stay on the same HDMI port (HDMI-1). On another port the system would see two screens and the images may overlap.

### Resolution

The system may keep 1024x768 after a test without a monitor. The [`display.sh`](../../scripts/display.sh) script re-applies 1920x1080 on HDMI-1 when the carousel starts and on every loop.

### Image cut at the edges (overscan)

On the TV itself, set the picture format to the mode that does not crop (on many brands: "Just Scan", "Full" or "1:1"). It is not a Linux problem.

## 6. Google Chrome and keyring

```
sudo apt install ./google-chrome-stable_current_amd64.deb
sudo apt install xdotool unclutter
```

On first start Chrome asks for a keyring password ("Choose password for new keyring"), because of the automatic login. Leave the password empty and confirm "Use Unsafe Storage". The kiosk also uses `--password-store=basic` and its own profile in `~/kiosk/chrome-profile`. Do not store personal passwords in this Chrome.

## 7. Firewall (ufw)

Policy: block incoming, allow outgoing. Chrome and the carousel sites only use outgoing connections, so they are not affected.

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
sudo ufw enable
```

Before enabling, keep an SSH session open as a safety net. Status: `sudo ufw status verbose`.

RustDesk, using the public servers, only makes outgoing connections and needs no incoming rule.

## 8. The carousel

Create the `~/kiosk` folder and copy into it:

| Source | Destination |
|---|---|
| `scripts/kiosk.sh`, `display.sh`, `stop.sh`, `start.sh`, `auto.sh`, `notice.sh` | `~/kiosk/` (make executable with `chmod +x ~/kiosk/*.sh`) |
| `web/welcome.html` | `~/kiosk/welcome.html` |
| `config/urls.txt.example` | `~/kiosk/urls.txt` (edit with your URLs) |
| `config/kiosk.desktop` | `~/.config/autostart/kiosk.desktop` |
| `config/crontab.example` | paste into the user's `crontab -e` |

How it works:

- **`kiosk.sh`:** waits for the network, adjusts the screen, opens Chrome in full screen with the URLs from `urls.txt` and, every 45 seconds, focuses the window, moves to the next tab (`Ctrl+Tab`, if there is more than one) and reloads (`F5`). If Chrome closes, the script starts over by itself.
- **`start.sh`:** starts the carousel if it is not already running. Used by cron, by SSH and for overtime.
- **`stop.sh`:** stops everything. Used by cron at the end of the day and as an emergency exit.
- **`auto.sh`:** called at login. Only starts inside working hours (Monday to Friday, 08:00 to 18:00). If the machine reboots outside working hours, the carousel does not open.
- **`notice.sh` + `welcome.html`:** show a welcome or goodbye screen for 20 seconds on top of the carousel, opening the page as a new tab and closing it with `Ctrl+W`. While it is showing, `kiosk.sh` pauses the tab switching through the `/tmp/kiosk-pause` file. The language of the messages comes from the `KIOSK_LANG` variable (`en`, `pt` or `es`), set at the top of the crontab.
- **Cron:** starts and stops at the scheduled times and triggers the notice screens. To change the schedule, use `crontab -e`.

After changing `urls.txt`, restart the carousel: `~/kiosk/stop.sh` and then `~/kiosk/start.sh`. The `urls.txt` file is only read at startup.

### Day-to-day use

- **Start by hand (overtime, weekends):** `~/kiosk/start.sh`. Outside the normal schedule no welcome screen appears. A carousel started after hours stays on until someone runs `~/kiosk/stop.sh`.
- **Show a notice screen right now:** `~/kiosk/notice.sh welcome` or `~/kiosk/notice.sh goodbye`. It only works with the carousel running.
- **Turning the TV on and off:** done by hand by the team. The mini PC does not control the TV. When the carousel is closed, the Linux desktop appears on the TV.

## 9. How to validate

Reboot the machine with the TV connected to HDMI-1, without touching anything. Expected: Chrome opens by itself in full screen, pages switch every 45 seconds, and the image is complete and sharp.

Verification commands:

```
DISPLAY=:0 xrandr --listmonitors                        # HDMI-1 at 1920x1080
systemctl is-active ssh rustdesk NetworkManager cron    # all "active"
pgrep -fa kiosk.sh                                      # kiosk running (inside working hours)
ip -4 -brief addr show                                  # fixed IP
sudo ufw status verbose                                 # active, SSH only from the allowed ranges
crontab -l                                              # schedule
timedatectl                                             # time zone and synchronized clock
```

The cron triggers can only be validated on the first working day: welcome at 08:00 and 13:00, goodbye at 17:59:40. To simulate cron's reduced environment without touching the schedule:

```
env -i HOME=$HOME PATH=/usr/bin:/bin /bin/sh -c '/home/kiosk/kiosk/notice.sh goodbye'
```

## 10. Common problems

| Symptom | Likely cause | What to do |
|---|---|---|
| Remote access shows "No Displays" | With no monitor, there is no active output | Apply the `video=HDMI-A-1:1920x1080@60e` parameter (section 5) |
| Image cut at the edges | TV overscan | Change the picture format on the TV |
| 1024x768 even with the TV at Full HD | Mode saved from a test without a monitor | `display.sh` already re-applies 1920x1080; check with `xrandr --listmonitors` |
| Chrome asks for a keyring password | Automatic login without an unlocked keyring | Empty password and "Use Unsafe Storage" (section 6) |
| Overlapping images on two screens | TV plugged into another HDMI port | Move the TV back to HDMI-1 |
| Carousel does not open after a reboot | It rebooted outside working hours | `~/kiosk/start.sh` |
| Alt+F4 or F11 and Chrome comes back | `kiosk.sh` reopens Chrome | Use `~/kiosk/stop.sh` |
| A page with a token stops opening | Token expired or removed | Generate a new token and update `urls.txt` |
| System notices appear over the carousel | `mintupdate` or another application | Disable the item in `~/.config/autostart` (section 4.2) |
