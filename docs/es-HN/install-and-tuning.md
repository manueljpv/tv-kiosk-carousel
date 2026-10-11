# Instalación y optimización del mini PC

Guía paso a paso para convertir un mini PC reutilizado en una pantalla de TV que enciende sola y ejecuta un carrusel de páginas en Chrome. Todas las direcciones, nombres y usuarios de abajo son ejemplos ficticios.

Valores de ejemplo usados en este documento:

| Elemento | Ejemplo |
|---|---|
| Usuario | `kiosk` |
| Nombre de la computadora | `tv-kiosk` |
| IP fija del mini PC | `192.0.2.20/24` |
| Puerta de enlace (gateway) | `192.0.2.1` |
| DNS interno | `192.0.2.53` (más `8.8.8.8` como respaldo) |
| Sitio que muestra el carrusel | `http://192.0.2.10:8080` |
| Rangos de confianza (SSH) | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` |
| MAC (ficticia) | `02:00:00:00:00:01` |

## 1. Sistema

- Linux Mint 21.3 Xfce (base Ubuntu 22.04), X11, inicio de sesión automático del usuario `kiosk` (LightDM).
- Zona horaria correcta y reloj sincronizado (verifique con `timedatectl`).
- Un disco pequeño es suficiente: después de la optimización quedan en uso unos 10 GB.

## 2. Red con IP fija

Reserve la IP en el DHCP del router o firewall (usando la MAC de la tarjeta de red) y fije la misma IP en Linux:

```
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.0.2.20/24 \
  ipv4.gateway 192.0.2.1 \
  ipv4.dns "192.0.2.53 8.8.8.8" \
  ipv4.ignore-auto-dns yes
sudo nmcli connection up "Wired connection 1"
```

Verificación: `ip -4 -brief addr show` debe mostrar la IP fija.

## 3. Acceso remoto

SSH como acceso principal y RustDesk como último recurso. Los detalles están en [remote-access.md](remote-access.md). Configúrelo al inicio, para hacer el resto sin necesitar teclado ni mouse en el equipo.

## 4. Optimización del sistema

### 4.1 Energía y pantalla: el equipo nunca se duerme

Bloquee los objetivos de suspensión de systemd:

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Instale el archivo [`config/logind-99-always-on.conf`](../../config/logind-99-always-on.conf) como `/etc/systemd/logind.conf.d/99-always-on.conf`.

En Xfce, apague los temporizadores del administrador de energía y el bloqueo de pantalla (canal `xfce4-power-manager`):

```
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 14
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -s true
```

(`inactivity-on-ac = 14` significa "nunca" en esa interfaz.) Si alguna de esas propiedades aún no existe, créela con `-n -t <tipo>`.

El script `start.sh` también ejecuta `xset s off -dpms s noblank` al iniciar el carrusel.

### 4.2 Programas que inician solos: desactivar

Para cada elemento de abajo, cree `~/.config/autostart/<nombre>.desktop` con solo las líneas siguientes (esto reemplaza el comportamiento predeterminado del sistema):

```
[Desktop Entry]
Type=Application
Name=<nombre>
Hidden=true
```

Elementos: mintwelcome, mintupdate, mintreport, blueman, warpinator-autostart, print-applet, onboard-autostart, orca-autostart, caribou-autostart, geoclue-demo-agent, org.gnome.Evolution-alarm-notify, sticky, xscreensaver y light-locker.

Atención: sin `mintupdate` no aparece el aviso de actualizaciones. Las actualizaciones pasan a ser manuales (`sudo apt update && sudo apt upgrade`).

### 4.3 Servicios innecesarios: desactivar

```
sudo systemctl disable --now bluetooth blueman-mechanism cups.socket cups.path cups cups-browsed ModemManager avahi-daemon.socket avahi-daemon kerneloops
```

Si el equipo tiene ZFS instalado, desactive también: `zfs-zed`, `zfs-share`, `zfs-mount`, `zfs-volume-wait`, `zfs-import-cache`, `zfs-load-module`.

### 4.4 Programas innecesarios: eliminar

Simule siempre antes de eliminar:

```
sudo apt-get -s purge <paquete>
sudo apt-get purge <paquete>
```

Eliminados en este proyecto: Firefox, Thunderbird, LibreOffice (todos los paquetes), Rhythmbox, Celluloid, Hypnotix, Transmission, HexChat, Pix, Drawing, Document Scanner, Redshift, Warpinator, Onboard, OpenVPN y sus complementos, y kernels antiguos. Esto liberó cerca de 3.4 GB.

Se mantienen a propósito: Python, fuentes, temas, Timeshift y Synaptic.

## 5. Video

### Sin monitor, el acceso remoto muestra "No Displays"

Una salida "fantasma" (VGA) aparece como conectada, pero no mantiene la pantalla activa. Solución: forzar HDMI-1 como siempre activo con un parámetro del kernel. En `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=HDMI-A-1:1920x1080@60e"
```

Después:

```
sudo cp /etc/default/grub /etc/default/grub.bak-hdmi
sudo update-grub
```

(Haga la copia de seguridad antes de editar.) Sin monitor, la pantalla virtual inicia en 1024x768, lo cual basta para el acceso remoto.

La TV debe quedar siempre en el mismo puerto HDMI (HDMI-1). En otro puerto, el sistema vería dos pantallas y las imágenes pueden superponerse.

### Resolución

El sistema puede quedarse con 1024x768 después de una prueba sin monitor. El script [`display.sh`](../../scripts/display.sh) vuelve a aplicar 1920x1080 en HDMI-1 al iniciar el carrusel y en cada vuelta.

### Imagen cortada en los bordes (overscan)

En la propia TV, ajuste el formato de imagen al modo que no recorta (en muchas marcas: "Just Scan", "Pantalla completa" o "1:1"). No es un problema de Linux.

## 6. Google Chrome y llavero

```
sudo apt install ./google-chrome-stable_current_amd64.deb
sudo apt install xdotool unclutter
```

En la primera apertura, Chrome pide una contraseña de llavero ("Choose password for new keyring"), por el inicio de sesión automático. Deje la contraseña en blanco y confirme "Use Unsafe Storage". El quiosco también usa `--password-store=basic` y un perfil propio en `~/kiosk/chrome-profile`. No guarde contraseñas personales en este Chrome.

## 7. Firewall (ufw)

Política: bloquear lo que entra y permitir lo que sale. Chrome y los sitios del carrusel solo usan conexiones salientes, por eso no se ven afectados.

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
sudo ufw enable
```

Antes de activarlo, mantenga una sesión SSH abierta como respaldo. Estado: `sudo ufw status verbose`.

RustDesk, usando los servidores públicos, solo hace conexiones salientes y no necesita regla de entrada.

## 8. El carrusel

Cree la carpeta `~/kiosk` y copie en ella:

| Origen | Destino |
|---|---|
| `scripts/kiosk.sh`, `display.sh`, `stop.sh`, `start.sh`, `auto.sh`, `notice.sh` | `~/kiosk/` (hágalos ejecutables con `chmod +x ~/kiosk/*.sh`) |
| `web/welcome.html` | `~/kiosk/welcome.html` |
| `config/urls.txt.example` | `~/kiosk/urls.txt` (edítelo con sus URL) |
| `config/kiosk.desktop` | `~/.config/autostart/kiosk.desktop` |
| `config/crontab.example` | péguelo en el `crontab -e` del usuario |

Cómo funciona:

- **`kiosk.sh`:** espera la red, ajusta la pantalla, abre Chrome a pantalla completa con las URL de `urls.txt` y, cada 45 segundos, enfoca la ventana, pasa a la siguiente pestaña (`Ctrl+Tab`, si hay más de una) y recarga (`F5`). Si Chrome se cierra, el script vuelve a empezar solo.
- **`start.sh`:** inicia el carrusel si todavía no está corriendo. Sirve para el cron, para SSH y para horas extra.
- **`stop.sh`:** lo detiene todo. Lo usa el cron al terminar la jornada y sirve como salida de emergencia.
- **`auto.sh`:** se ejecuta al iniciar sesión. Solo inicia dentro del horario (lunes a viernes, de 08:00 a 18:00). Si el equipo se reinicia fuera de horario, el carrusel no abre.
- **`notice.sh` + `welcome.html`:** muestran una pantalla de bienvenida o despedida durante 20 segundos sobre el carrusel, abriendo la página como pestaña nueva y cerrándola con `Ctrl+W`. Mientras tanto, `kiosk.sh` pausa el cambio de pestañas mediante el archivo `/tmp/kiosk-pause`. El idioma de los mensajes viene de la variable `KIOSK_LANG` (`en`, `pt` o `es`), definida al inicio del crontab.
- **Cron:** enciende y apaga en el horario y dispara las pantallas de aviso. Para cambiar el horario, use `crontab -e`.

Después de cambiar `urls.txt`, reinicie el carrusel: `~/kiosk/stop.sh` y luego `~/kiosk/start.sh`. El archivo `urls.txt` solo se lee al iniciar.

### Uso del día a día

- **Encender a mano (horas extra, fin de semana):** `~/kiosk/start.sh`. Fuera del horario normal no aparece la pantalla de bienvenida. Un carrusel encendido después del horario queda encendido hasta que alguien ejecute `~/kiosk/stop.sh`.
- **Mostrar una pantalla de aviso en el momento:** `~/kiosk/notice.sh welcome` o `~/kiosk/notice.sh goodbye`. Solo funciona con el carrusel corriendo.
- **Encender y apagar la TV:** lo hace a mano el equipo. El mini PC no controla la TV. Al cerrar el carrusel, el escritorio de Linux aparece en la TV.

## 9. Cómo validar

Reinicie el equipo con la TV conectada en HDMI-1, sin tocar nada. Lo esperado es que Chrome abra solo a pantalla completa, con las páginas cambiando cada 45 segundos, la imagen completa y nítida.

Comandos de verificación:

```
DISPLAY=:0 xrandr --listmonitors                        # HDMI-1 en 1920x1080
systemctl is-active ssh rustdesk NetworkManager cron    # todos "active"
pgrep -fa kiosk.sh                                      # quiosco en ejecución (dentro del horario)
ip -4 -brief addr show                                  # IP fija
sudo ufw status verbose                                 # activo, SSH solo desde los rangos permitidos
crontab -l                                              # programación
timedatectl                                             # zona horaria y reloj sincronizado
```

Los disparos del propio cron solo se pueden validar el primer día hábil: bienvenida a las 08:00 y a las 13:00, y despedida a las 17:59:40. Para simular el entorno reducido del cron sin tocar la programación:

```
env -i HOME=$HOME PATH=/usr/bin:/bin /bin/sh -c '/home/kiosk/kiosk/notice.sh goodbye'
```

## 10. Problemas comunes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| El acceso remoto muestra "No Displays" | Sin monitor no hay salida activa | Aplicar el parámetro `video=HDMI-A-1:1920x1080@60e` (sección 5) |
| Imagen cortada en los bordes | Overscan de la TV | Cambiar el formato de imagen en la TV |
| Resolución 1024x768 aunque la TV esté en Full HD | Modo guardado de una prueba sin monitor | `display.sh` ya vuelve a aplicar 1920x1080; verifique con `xrandr --listmonitors` |
| Chrome pide contraseña de llavero | Inicio automático sin llavero desbloqueado | Contraseña en blanco y "Use Unsafe Storage" (sección 6) |
| Imágenes superpuestas en dos pantallas | TV conectada en otro puerto HDMI | Volver a poner la TV en HDMI-1 |
| El carrusel no abre después de reiniciar | Se reinició fuera del horario | `~/kiosk/start.sh` |
| Alt+F4 o F11 y Chrome vuelve solo | `kiosk.sh` vuelve a abrir Chrome | Use `~/kiosk/stop.sh` |
| Una página con token deja de abrir | Token vencido o eliminado | Generar otro token y actualizar `urls.txt` |
| Aparecen avisos del sistema sobre el carrusel | `mintupdate` u otra aplicación | Desactivar el elemento en `~/.config/autostart` (sección 4.2) |
