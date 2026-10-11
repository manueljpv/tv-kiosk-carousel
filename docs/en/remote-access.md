# Remote access

Order of use:

1. **SSH (main access).** Lets you administer the machine without interfering with what is on the TV: whoever is watching the screen notices nothing.
2. **RustDesk (last resort).** Shows the real screen. Use it when you need to see what the TV displays or when SSH is not responding.

Example values: user `kiosk`, IP `192.0.2.20`, trusted ranges `192.0.2.0/24`, `198.51.100.0/24` and `203.0.113.0/24`.

## 1. SSH

### Installation

```
sudo apt install openssh-server
sudo systemctl enable --now ssh
systemctl is-active ssh
```

### Firewall: SSH only from trusted ranges

```
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
```

Any other source stays blocked (see [install-and-tuning.md](install-and-tuning.md), section 7).

### Access

```
ssh kiosk@192.0.2.20
```

### Good practice (optional): SSH key instead of a password

On your computer:

```
ssh-keygen -t ed25519
ssh-copy-id kiosk@192.0.2.20
```

Test the key login. Only after confirming it works, disable the password in `/etc/ssh/sshd_config.d/99-key-only.conf`:

```
PasswordAuthentication no
```

and apply it with `sudo systemctl reload ssh`. Keep one session open during the test.

### Changing the kiosk without showing on the TV

The scripts already use `export DISPLAY=:0`, so they work over SSH without opening windows in the terminal.

What does **not** interfere with what is on screen:

- editing `~/kiosk/urls.txt`;
- editing the schedule (`crontab -e`);
- adjusting settings, installing packages and checking logs;
- checking state (`pgrep -fa kiosk.sh`, `crontab -l`, `sudo ufw status`).

What makes the TV blink:

- **Restarting the carousel** (`~/kiosk/stop.sh` and then `~/kiosk/start.sh`), needed after changing `urls.txt`. Do it when nobody is watching, or warn people first.
- **Showing a notice screen** (`~/kiosk/notice.sh`). It appears for 20 seconds.

Tip: to show something on the TV for a test without leaving SSH, use `notice.sh` instead of opening Chrome by hand.

## 2. RustDesk

Official `.deb` package of the RustDesk project (GitHub releases):

```
sudo apt install ./rustdesk-<version>-x86_64.deb
sudo systemctl enable --now rustdesk
```

Set a fixed password for unattended access (type the password in the terminal, never in a versioned script):

```
sudo rustdesk --password
```

To get the machine ID:

```
sudo rustdesk --get-id
```

Notes:

- By default RustDesk uses the project's own public servers, so it only makes outgoing connections and needs no incoming firewall rule. A self-hosted server can be set up later as an improvement.
- Keep the ID and the password in the team's password manager, not in documents or in the repository.
- For direct connection by IP on the internal network, RustDesk listens on UDP ports 21119 and 41216; open them in ufw only for the trusted ranges, and only if really needed.
- If the service is `active` but the connection drops, SSH is still the way to restart the service: `sudo systemctl restart rustdesk`.
