---
title: Control Panel
description: Use the Quickshell control panel cards.
---

The Control Panel is the quick-access Quickshell surface for the active session. It is the place to inspect status or perform a frequent action without opening the full settings application.

The panel uses the shared `argvus-i18n` catalogs. When a different language is applied in **Control Center → Locale & Region**, the Control Panel service is restarted automatically so it loads the selected catalog.

## Control Panel or Control Center?

Use the panel for current status and quick actions. Use [Control Center](/docs/argvus-control-center/) when you want to change persistent desktop configuration. For example, the panel can expose appearance, display, network, volume, brightness, notification, power and session controls; the detailed visual and layout configuration belongs in **Control Center → Appearance**.

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
- Spaces, Borders & Position;
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

The Control Panel appearance card no longer manages a global Transparency setting. Configure Transparency and Blur independently for the Control Panel in **Control Center → Appearance → Control Panel**. The Control Panel master **Enable** switch still controls the whole surface and its service.

## Session behavior

`argvus-control-panel.service` is started by `argvus-session`. Opening and closing the panel changes the session panel state, but does not mean that every card action is persistent configuration. Network, audio, power and display actions may be handed to their providers or to the current desktop session.

See [taskbar and panels](/docs/argvus-taskbar/taskbar/) for the relationship between the panel, taskbar margins and window layout.
