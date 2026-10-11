# Cómo revertir cada cambio

Antes de empezar, cree un punto de restauración con Timeshift (RSYNC en el disco del sistema). Resuelve la mayoría de los problemas:

```
sudo timeshift --create --comments "antes del cambio" --tags D
sudo timeshift --list
```

| Cambio | Cómo revertir |
|---|---|
| Pantallas de bienvenida y despedida | `crontab -e` y borre las tres líneas del bloque "Welcome and goodbye screens". Los archivos `notice.sh` y `welcome.html` pueden quedarse en la carpeta sin efecto. |
| Pausa de `kiosk.sh` para el aviso | Elimine de `kiosk.sh` la línea con `/tmp/kiosk-pause`. |
| Horario automático | `crontab -r` borra toda la programación del usuario (o `crontab -e` para quitar una sola línea). Para volver a abrir el carrusel en cualquier reinicio, cambie el `Exec` de `kiosk.desktop` a `/home/kiosk/kiosk/start.sh`. |
| Quiosco al iniciar sesión | `rm ~/.config/autostart/kiosk.desktop` y `~/kiosk/stop.sh` para detener lo que esté corriendo. |
| Firewall | `sudo ufw disable` (lo apaga) o `sudo ufw reset` (borra todas las reglas). Para quitar una sola regla: `sudo ufw status numbered` y `sudo ufw delete <número>`. |
| HDMI forzado | `sudo cp /etc/default/grub.bak-hdmi /etc/default/grub && sudo update-grub`, y luego reiniciar. |
| Suspensión e hibernación | `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target` y `sudo rm /etc/systemd/logind.conf.d/99-always-on.conf`. |
| Elementos de inicio automático | Borre el `.desktop` correspondiente en `~/.config/autostart/`. |
| Servicios desactivados | `sudo systemctl enable --now bluetooth cups cups-browsed avahi-daemon ModemManager` (y `cups.socket`, `avahi-daemon.socket`). |
| IP fija | `sudo nmcli connection modify "Wired connection 1" ipv4.method auto ipv4.ignore-auto-dns no ipv4.addresses "" ipv4.gateway "" ipv4.dns ""` y `sudo nmcli connection up "Wired connection 1"`. |
| Programas eliminados | `sudo apt install <paquete>`. Un kernel antiguo que se eliminó no debe reinstalarse. |
| SSH | `sudo systemctl disable --now ssh` y `sudo ufw delete <número>` de las reglas del puerto 22. Antes, confirme que RustDesk funciona. |
