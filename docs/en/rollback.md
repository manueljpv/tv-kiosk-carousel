# How to roll back each change

Before you start, create a restore point with Timeshift (RSYNC on the system disk). It solves most problems:

```
sudo timeshift --create --comments "before the change" --tags D
sudo timeshift --list
```

| Change | How to roll back |
|---|---|
| Welcome and goodbye screens | `crontab -e` and delete the three lines of the "Welcome and goodbye screens" block. The `notice.sh` and `welcome.html` files can stay in the folder with no effect. |
| `kiosk.sh` pause for the notice | Remove the line with `/tmp/kiosk-pause` from `kiosk.sh`. |
| Automatic schedule | `crontab -r` deletes the user's whole schedule (or `crontab -e` to remove a single line). To open the carousel on any reboot again, change the `Exec` of `kiosk.desktop` to `/home/kiosk/kiosk/start.sh`. |
| Kiosk at login | `rm ~/.config/autostart/kiosk.desktop` and `~/kiosk/stop.sh` to stop whatever is running. |
| Firewall | `sudo ufw disable` (turns it off) or `sudo ufw reset` (deletes all rules). To remove a single rule: `sudo ufw status numbered` and `sudo ufw delete <number>`. |
| Forced HDMI | `sudo cp /etc/default/grub.bak-hdmi /etc/default/grub && sudo update-grub`, then reboot. |
| Suspend and hibernate | `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target` and `sudo rm /etc/systemd/logind.conf.d/99-always-on.conf`. |
| Autostart items | Delete the matching `.desktop` file in `~/.config/autostart/`. |
| Disabled services | `sudo systemctl enable --now bluetooth cups cups-browsed avahi-daemon ModemManager` (and `cups.socket`, `avahi-daemon.socket`). |
| Fixed IP | `sudo nmcli connection modify "Wired connection 1" ipv4.method auto ipv4.ignore-auto-dns no ipv4.addresses "" ipv4.gateway "" ipv4.dns ""` and `sudo nmcli connection up "Wired connection 1"`. |
| Removed programs | `sudo apt install <package>`. An old kernel that was removed should not be reinstalled. |
| SSH | `sudo systemctl disable --now ssh` and `sudo ufw delete <number>` for the port 22 rules. First, confirm that RustDesk works. |
