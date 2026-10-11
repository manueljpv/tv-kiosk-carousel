# Acceso remoto

Orden de uso:

1. **SSH (acceso principal).** Permite administrar el equipo sin interferir con lo que se ve en la TV: quien está mirando la pantalla no nota nada.
2. **RustDesk (último recurso).** Muestra la pantalla real. Úselo cuando necesite ver lo que muestra la TV o cuando SSH no responda.

Valores de ejemplo: usuario `kiosk`, IP `192.0.2.20`, rangos de confianza `192.0.2.0/24`, `198.51.100.0/24` y `203.0.113.0/24`.

## 1. SSH

### Instalación

```
sudo apt install openssh-server
sudo systemctl enable --now ssh
systemctl is-active ssh
```

### Firewall: SSH solo desde los rangos de confianza

```
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
```

Cualquier otro origen queda bloqueado (vea [install-and-tuning.md](install-and-tuning.md), sección 7).

### Acceso

```
ssh kiosk@192.0.2.20
```

### Buena práctica (opcional): llave SSH en lugar de contraseña

En su computadora:

```
ssh-keygen -t ed25519
ssh-copy-id kiosk@192.0.2.20
```

Pruebe el inicio de sesión con la llave. Solo después de confirmar que funciona, desactive la contraseña en `/etc/ssh/sshd_config.d/99-key-only.conf`:

```
PasswordAuthentication no
```

y aplíquelo con `sudo systemctl reload ssh`. Mantenga una sesión abierta durante la prueba.

### Cambiar el quiosco sin que se note en la TV

Los scripts ya usan `export DISPLAY=:0`, así que funcionan por SSH sin abrir ventanas en la terminal.

Lo que **no** interfiere con lo que se ve en pantalla:

- editar `~/kiosk/urls.txt`;
- editar la programación (`crontab -e`);
- ajustar configuraciones, instalar paquetes y revisar registros;
- consultar el estado (`pgrep -fa kiosk.sh`, `crontab -l`, `sudo ufw status`).

Lo que hace parpadear la TV:

- **Reiniciar el carrusel** (`~/kiosk/stop.sh` y luego `~/kiosk/start.sh`), necesario después de cambiar `urls.txt`. Hágalo cuando nadie esté mirando o avise antes.
- **Mostrar una pantalla de aviso** (`~/kiosk/notice.sh`). Aparece durante 20 segundos.

Consejo: para mostrar algo de prueba en la TV sin salir de SSH, use `notice.sh` en lugar de abrir Chrome a mano.

## 2. RustDesk

Paquete `.deb` oficial del proyecto RustDesk (releases de GitHub):

```
sudo apt install ./rustdesk-<versión>-x86_64.deb
sudo systemctl enable --now rustdesk
```

Defina una contraseña fija para el acceso desatendido (escriba la contraseña en la terminal, nunca en un script versionado):

```
sudo rustdesk --password
```

Para obtener el ID del equipo:

```
sudo rustdesk --get-id
```

Notas:

- Por defecto, RustDesk usa los servidores públicos del propio proyecto, por lo que solo hace conexiones salientes y no necesita regla de entrada en el firewall. Un servidor propio se puede montar después, como mejora.
- Guarde el ID y la contraseña en el administrador de contraseñas del equipo, no en documentos ni en el repositorio.
- Para conexión directa por IP en la red interna, RustDesk escucha en los puertos UDP 21119 y 41216; ábralos en ufw solo para los rangos de confianza, y únicamente si es realmente necesario.
- Si el servicio está `active` pero la conexión se cae, SSH sigue siendo el camino para reiniciar el servicio: `sudo systemctl restart rustdesk`.
