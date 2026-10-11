# Hoja de ruta

[Português](ROADMAP.md) · [English](ROADMAP.en.md) · **Español (Honduras)**

Mejoras previstas para el proyecto y lo que hemos aprendido hasta ahora. Son ideas, sin fechas garantizadas, y el orden no es definitivo.

## Corto plazo

Mejoras pequeñas que caben en los scripts y la configuración actuales.

- [ ] **Feriados.** Cron solo conoce los días de la semana: el carrusel enciende y las pantallas de aviso aparecen cualquier día hábil, incluidos los feriados. Crear una lista de fechas (`holidays.txt`) que `auto.sh` y `start.sh` consulten antes de encender.
- [ ] **Actualizaciones automáticas de seguridad.** Con `mintupdate` desactivado, las actualizaciones son manuales. Evaluar `unattended-upgrades` solo para seguridad, con reinicio controlado fuera del horario de trabajo.
- [ ] **Configuración en un solo lugar.** Hoy el horario está en el crontab y en `auto.sh`, y el intervalo en `kiosk.sh`. Reunir todo en un archivo `kiosk.conf` (horario, intervalo, idioma, lista de feriados).
- [ ] **Reinicio periódico de Chrome.** En carruseles que pasan muchos días encendidos, Chrome puede consumir más memoria con el tiempo. Reiniciar solo el quiosco (no el equipo) una vez al día, fuera del horario.
- [ ] **Pantalla de reposo fuera del horario.** Al detener el carrusel, el escritorio de Linux aparece en la TV. Reemplazarlo por una pantalla negra o una imagen sencilla.
- [ ] **Atajo de teclado de salida.** Un atajo que ejecute `stop.sh`, para quien tenga un teclado conectado al equipo.
- [ ] **Tiempo por página.** Permitir un intervalo distinto para cada URL (por ejemplo, `url;60`).
- [ ] **Pruebas automáticas.** Ejecutar `shellcheck` en los scripts con cada cambio (GitHub Actions).

## Largo plazo

Cambios mayores que requieren un proyecto propio.

- [ ] **Encender y apagar la TV automáticamente.** Hoy la TV se enciende y se apaga a mano. Probar HDMI-CEC (`libcec`) para que el mini PC controle la TV, en los modelos que lo soporten.
- [ ] **Servidor RustDesk propio.** Hoy RustDesk usa los servidores públicos del proyecto. Un servidor propio da más control sobre los accesos y los registros.
- [ ] **Varios equipos.** Estandarizar la implementación en otros mini PC idénticos: un script `install.sh` que aplique todo, o un playbook de Ansible, y una configuración por equipo (IP, páginas, horario).
- [ ] **Monitorear el propio carrusel.** Una señal de "sigo vivo" (heartbeat) enviada a una herramienta de monitoreo, con alerta si el carrusel se detiene o la página se cae.
- [ ] **Menos dependencias.** Reemplazar `xdotool` (que simula teclas) por control directo de Chrome (puerto de depuración), y evaluar un entorno gráfico mínimo en lugar de Xfce completo.
- [ ] **Contenido por horario.** Páginas distintas según el período del día o de la semana, y un mensaje de aviso urgente que se superponga al carrusel.

## Lo que aprendimos

- **Reutilizar equipo parado vale la pena.** Los mini PC olvidados en un armario fueron una mejor solución que una laptop: más pequeños, más fríos, con puerto de red por cable y sin piezas móviles. Antes de comprar o adaptar algo, busque lo que ya existe.
- **Pruebe el HDMI con alguien junto al equipo.** Un kernel más nuevo congeló el sistema al conectar el cable (y cortó el acceso remoto). Fijar el kernel que funciona lo resolvió. Descarte las causas una por una, con pruebas, en lugar de culpar al cable, a la TV o al navegador.
- **Simule antes de eliminar.** `apt -s purge` muestra qué se irá junto con el paquete. Cree un punto de restauración (Timeshift) antes de tocar el sistema.
- **Mantenga una sesión SSH abierta al activar el firewall.** Si una regla está mal, aún puede deshacerla.
- **Cambie una cosa a la vez y valide con un reinicio.** En un equipo sin teclado y sin pantalla de apoyo, el reinicio es la prueba que importa.
- **Cron solo conoce minutos y un entorno reducido.** Use `sleep` para ajustar los segundos, y pruebe el script con el entorno mínimo (`env -i`) antes de confiar en él.
- **Un carrusel tiene que reiniciarse solo.** Si Chrome se cierra, el script vuelve a empezar; fuera del horario, `auto.sh` evita que abra sin necesidad.
- **Los tokens y las URL de los paneles son secretos.** Mantenga el `urls.txt` real fuera del repositorio (`.gitignore`) y publique solo `urls.txt.example`.
- **No todo es un problema de Linux.** Una imagen cortada en los bordes (overscan) se arregla en la propia TV.
- **Documente mientras lo hace.** La guía paso a paso, lo que salió mal y cómo revertirlo son lo que vuelve repetible el proyecto en otro equipo.
