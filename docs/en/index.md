---
title: Control Panel
description: Use the Quickshell control panel cards.
---

The Control Panel is the quick-access Quickshell surface for the active session. It is the place to inspect status or perform a frequent action without opening the full settings application.

The panel uses the shared `argvus-i18n` catalogs. When a different language is applied in **Control Center → Locale & Region**, the Control Panel service is restarted automatically so it loads the selected catalog.

## Control Panel or Control Center?

Use the panel for current status and quick actions. Use [Control Center](/docs/components/argvus-control-center/) when you want to change persistent desktop configuration. For example, the panel can expose appearance, display, network, volume, brightness, notification, power and session controls; the detailed visual and layout configuration belongs in **Control Center → Appearance**.

## Cards

The current card registry includes:

- User;
- Notifications;
- Calendar;
- Weather;
- Volume;
- Brightness;
- Network;
- Bluetooth;
- System;
- Appearance;
- Session;
- Display;
- Power.

Some cards are conditional. Bluetooth is hidden when the Bluetooth capability is unavailable. Brightness is hidden when neither the supported backlight nor monitor-control tool is available. The card list therefore reflects the current machine rather than promising controls every machine can provide.

## Visibility and order

The panel's **Appearance → Control Panel** page lets you enable, disable and reorder cards. The packaged helper also exposes the same state:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```

Use the UI when possible. The panel state is stored as user configuration; it is separate from the generated Hyprland layout files.

Disabling a card hides it from the panel; it does not uninstall the provider behind it. Reordering changes the order in which cards are presented. There is no `reset` subcommand in the current helper. If the user card preference is removed, the provider normalizes the state back to the known cards, enabled by default and in packaged order.

The Control Panel appearance card no longer manages a global Transparency setting. Configure Transparency and Blur independently for the Control Panel in **Control Center → Appearance → Control Panel**. The Control Panel master **Enable** switch still controls the whole surface and its service. `cards-config.sh master set` restarts or stops the panel only when the switch changes; setting the value it already has only makes sure an enabled panel runs.

## Keyboard navigation

When the panel opens, use **↑/↓** to scroll its content. **Tab** moves forward through buttons, controls and fields; **Shift+Tab** moves backward. Buttons show focus with a highlighted border and can be activated with **Enter** or **Space**. Sliders and text fields keep those keys for their own adjustment or editing. **Esc** closes the panel.

## Staying in sync with the rest of the desktop

The cards show the live state of the desktop. A change made elsewhere (Control Center, the taskbar, a keyboard shortcut or the `argvus` command line) shows up in the panel without restarting it:

| Card | Where the state comes from | When it refreshes |
| --- | --- | --- |
| User | `getent passwd` | every 3 s while the panel is open |
| Volume | the PipeWire default sink (`wpctl`) and `pactl subscribe` events | immediately on each audio event; every 2 s as a safety net |
| Appearance (Telemetry, Animations and Effects) | the `/effects` section of `argvus config` | every 2 s while the panel is open |
| Power | `powerprofilesctl` | every 3 s while the panel is open |
| Weather | the location file | when the panel opens and every 15 min |

The Appearance card has two independent switches. **Animations** runs `argvus effects-toggle animations toggle` and controls everything that moves. **Effects** runs `argvus effects-toggle effects toggle` and switches blur and the transparency of Terminal, Launcher, Widget Telemetry, Control Panel and Taskbar together; it shows as on when at least one of them is on. **SUPER + F6** (`argvus effects-toggle toggle`) switches both together. Changing either reloads Hyprland and the theme consumers in place: Waybar re-reads its stylesheets, the panel reloads over IPC and Dunst reloads its configuration. Nothing is restarted and no loading screen appears.

Scrolling on the taskbar volume icon and the media keys use `argvus config audio`, which applies the change to PipeWire and also records the volume in `/audio`. A configuration reload therefore does not restore an old volume.

## Session behavior

`argvus-control-panel.service` is started by `argvus-session`. Opening and closing the panel changes the session panel state, but does not mean that every card action is persistent configuration. Network, audio, power and display actions may be handed to their providers or to the current desktop session.

See [taskbar and panels](/docs/argvus-taskbar/taskbar/) for the relationship between the panel, taskbar margins and window layout.

## Night Light

The Display card shows a Night Light on/off switch and the active temperature. Its corners and animations follow the same theme tokens as the other panel switches, including Sticky and Float layouts. The switch has no border and uses a pointing-hand cursor, like the other panel switches. It uses `argvus config display night-light status|toggle`, polling every two seconds while open and refetching after an action. The row is hidden when the backend is unavailable; a failed action shows an error. Scheduling and temperature are configured in **Control Center > Desktop & Input > Displays > Night Light**. A scheduled manual toggle lasts until the next transition; otherwise activation is persistent.
