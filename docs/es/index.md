---
title: Panel de control
description: Usa las tarjetas del panel de control Quickshell.
---
El Panel de Control es la superficie de Quickshell de acceso rápido para la sesión activa. Es el lugar para inspeccionar el estado o realizar una acción frecuente sin abrir la aplicación completa de configuración.

El panel utiliza el compartido `argvus-i18n` catálogos. Cuando se selecciona un idioma de interfaz diferente en **Centro de control → Preferencias → Idioma & Region → Idioma**, el servicio del panel de control se reinicia automáticamente para cargar el catálogo seleccionado. Esta preferencia es independiente de `LANG`, que sigue siendo el local regional para el formato y aplicaciones de terceros. El árabe y el urdu utilizan el diseño derecho a izquierda.

El Panel de Control comparte el borde de la barra de tareas con ARGVUS Focus y ARGVUS Clock. Abrir el panel cierra primero ambos pop-ups; abrir Focus o Clock cierra el panel.

## ¿Panel de Control o Centro de Control?

Use el panel para ver el estado actual y realizar acciones rápidas. Use [Control Center](/docs/components/argvus-control-center/) cuando quiera cambiar la configuración persistente del escritorio. Por ejemplo, el panel puede mostrar controles de apariencia, pantalla, red, volumen, brillo, notificaciones, energía y sesión; la configuración detallada de apariencia y diseño pertenece a **Control Center → Appearance**.

## Tarjetas

El registro actual de tarjetas incluye:

- Usuario;
- Notificaciones;
- Calendario;
- Clima;
- Volumen;
- Brillo;
- Red;
-Bluetooth;
- Sistema;
- Apariencia;
- Sesión;
- Pantalla;
- Energía.

Algunas tarjetas son condicionales. Bluetooth se oculta cuando la capacidad de Bluetooth no está disponible. Brillo se oculta cuando no está disponible ni la retroiluminación compatible ni la herramienta de control de monitor. Por lo tanto, la lista de tarjetas refleja la máquina actual en lugar de prometer controles que cada máquina pueda proporcionar.

## Visibilidad y orden

La página **Apariencia → Panel de control** del panel te permite habilitar, deshabilitar y reordenar tarjetas. El asistente empaquetado también expone el mismo estado:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```
Usa la interfaz de usuario cuando sea posible. El estado del panel se almacena como configuración del usuario; es independiente de los archivos de diseño generados de Hyprland.

Deshabilitar una tarjeta la oculta del panel; no desinstala el proveedor detrás de ella. Reordenar cambia el orden en que se presentan las tarjetas. No hay un subcomando `reset` en el asistente actual. Si se elimina la preferencia de tarjeta del usuario, el proveedor normaliza el estado de vuelta a las tarjetas conocidas, habilitadas por defecto y en el orden empaquetado.

La tarjeta de apariencia del Panel de Control ya no gestiona un ajuste global de Transparencia. Configura Transparencia y Desenfoque independientemente para el Panel de Control en **Centro de Control → Apariencia → Panel de Control**. El interruptor principal **Habilitar** del Panel de Control todavía controla toda la superficie y su servicio. `cards-config.sh master set` reinicia o detiene el panel solo cuando el interruptor cambia; establecer el valor que ya tiene solo asegura que un panel habilitado esté funcionando.

## Navegación con teclado

Cuando se abre el panel, utiliza **↑/↓** para desplazarte por su contenido. **Tab** avanza entre botones, controles y campos; **Shift+Tab** retrocede. Los botones muestran el foco con un borde resaltado y se pueden activar con **Enter** o **Espacio**. Los deslizadores y campos de texto conservan esas teclas para su propio ajuste o edición. **Esc** cierra el panel.

## Mantenerse sincronizado con el resto del escritorio

La tarjeta de Notificaciones oculta su historial mientras No Molestar está activo. Las notificaciones recibidas durante ese tiempo permanecen en Dunst y vuelven a aparecer en la tarjeta después de que se desactive No Molestar.

Las tarjetas muestran el estado en vivo del escritorio. Un cambio realizado en otro lugar (Centro de Control, la barra de tareas, un atajo de teclado o la línea de comandos `argvus`) aparece en el panel sin necesidad de reiniciarlo:

| Tarjeta | De dónde proviene el estado | Cuándo se actualiza |
| --- | --- | --- |
| Usuario | `getent passwd` | cada 3 s mientras el panel está abierto |
| Volumen | el sumidero predeterminado de PipeWire (`wpctl`) y los eventos `pactl subscribe` | inmediatamente con cada evento de audio; cada 2 s como red de seguridad |
| Apariencia (Telemetría, Animaciones y Efectos) | la sección `/effects` de `argvus config` | cada 2 s mientras el panel está abierto |
| Energía | `powerprofilesctl` | cada 3 s mientras el panel está abierto |
| Clima | el archivo de ubicación y los proveedores wttr.in/Open-Meteo | cuando se abre el panel y cada 15 min; las pestañas cambian entre las condiciones actuales y el pronóstico diario para los próximos siete días |

La tarjeta de Apariencia tiene dos interruptores independientes. **Animaciones** ejecuta `argvus effects-toggle animations toggle` y controla todo lo que se mueve. **Efectos** ejecuta `argvus effects-toggle effects toggle` y alterna el desenfoque y la transparencia de Terminal, Lanzador, Telemetría de Widget, Panel de Control y Barra de tareas juntos; se muestra como activado cuando al menos uno de ellos está encendido. **SUPER + F6** (`argvus effects-toggle toggle`) alterna ambos juntos. Cambiar cualquiera de ellos recarga Hyprland y los consumidores de temas en su lugar: Waybar vuelve a leer sus hojas de estilo, el panel se recarga a través de IPC y Dunst recarga su configuración a menos que No Molestar esté activo, en cuyo caso su recarga se pospone hasta que se desactiva DND. Nada se reinicia y no aparece ninguna pantalla de carga.

Desplazarse sobre el ícono de volumen de la barra de tareas y usar las teclas de medios utiliza `argvus config audio`, que aplica el cambio a PipeWire y también registra el volumen en `/audio`. Por lo tanto, una recarga de configuración no restaura un volumen antiguo.

## Comportamiento de la sesión

`argvus-control-panel.service` es iniciado por `argvus-session`. Abrir y cerrar el panel cambia el estado del panel de la sesión, pero no significa que cada acción de la tarjeta sea una configuración persistente. Las acciones de red, audio, energía y pantalla pueden ser manejadas por sus proveedores o por la sesión de escritorio actual.

Ver [barra de tareas y paneles](/docs/argvus-taskbar/taskbar/) para la relación entre el panel, los márgenes de la barra de tareas y la disposición de las ventanas.

## Luz nocturna

La tarjeta de pantalla muestra un interruptor de Luz Nocturna encendido/apagado y la temperatura activa. Sus esquinas y animaciones siguen los mismos tokens de tema que los otros interruptores del panel, incluidos los diseños Sticky y Spaced. El interruptor no tiene borde y utiliza un cursor de mano señalando, como los otros interruptores del panel. Usa `argvus config display night-light status|toggle`, sondeando cada dos segundos mientras está abierto y volviendo a consultar después de una acción. La fila se oculta cuando el backend no está disponible; una acción fallida muestra un error. La programación y la temperatura se configuran en **Centro de control > Escritorio e entrada > Pantallas > Luz Nocturna**. Un cambio manual programado dura hasta la siguiente transición; de lo contrario, la activación es persistente.

El calendario de la barra de tareas, ARGVUS Focus, ARGVUS Clock y el Panel de control son mutuamente excluyentes: abrir uno cierra los demás.

## Etiquetas multilingües compactas

Las pestañas del clima usan el catálogo compartido (condiciones actuales y siete días). Las mediciones del clima ocupan columnas de ancho igual; las etiquetas se ajustan y los valores permanecen alineados. Las abreviaturas de los días de la semana en el calendario son específicas de la localidad y comienzan en domingo, incluyendo las etiquetas de los días del pronóstico. No son traducciones literales de las abreviaturas en inglés.

Los botones vinculan su grupo de ícono/etiqueta al ancho disponible. Si una etiqueta necesita puntos suspensivos, al pasar el cursor o enfocar el botón se muestra su texto completo. Los botones del perfil de energía también muestran su texto descriptivo en una información sobre herramientas. Las descripciones largas de interruptores se ajustan, y los campos numéricos y entradas del usuario reservan espacio suficiente para la fuente elegida. La altura de la tarjeta crece con el texto ajustado; usa el desplazamiento vertical para ver las tarjetas inferiores. Estos cambios preservan la fuente seleccionada y las acciones existentes de la tarjeta.
