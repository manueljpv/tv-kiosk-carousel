# Alternativas y lecciones aprendidas

## Por qué no usamos una laptop

La primera versión del proyecto corrió en una laptop vieja conectada a la TV, con la tapa cerrada y la pantalla interna apagada. Funcionó, pero el arreglo era malo: la laptop se calentaba incluso después de mantenimiento y limpieza, y dejar una laptop cerrada detrás de la TV no es práctico ni seguro. Lo que lo resolvió fue buscar equipos sin uso dentro de la propia empresa. Había mini PC de un uso anterior en red guardados en un armario. Son pequeños, se calientan poco, tienen puerto de red por cable y ya traen salidas de video listas para la TV. Reutilizar equipo parado resultó más simple, más barato y más confiable que adaptar una laptop.

## Dos problemas que pueden aparecer en otro equipo

En la laptop, que usaba gráficos Intel de 10.ª generación (Ice Lake), conectar el cable HDMI con el sistema encendido congelaba la máquina por completo, al punto de cortar el acceso remoto. La causa era una regresión en un kernel más nuevo (serie 7.x) con el controlador de video de Intel; un kernel anterior (6.14) funcionaba. La solución fue fijar en GRUB el kernel que funcionaba y retener los paquetes de kernel que lo actualizarían. Quien reutilice un equipo parecido debe probar el HDMI con alguien junto al equipo y, si se congela, probar otro kernel antes de culpar al cable, a la TV o al navegador. Chrome y la aceleración por GPU se descartaron como causa.

El segundo problema fue el Wi-Fi, que por defecto tiene el ahorro de energía activado y puede volverse inestable en un equipo que nunca descansa. Apagar el ahorro de energía del Wi-Fi en NetworkManager y mantener activos los intentos de reconexión estabilizó la conexión. Siempre que sea posible, prefiera cable de red para un equipo que debe estar encendido todos los días sin supervisión.
