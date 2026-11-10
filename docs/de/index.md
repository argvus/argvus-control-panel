---
title: Systemsteuerung
description: Verwenden Sie die Quickshell-Steuerfeldkarten.
---
Die Systemsteuerung ist die Schnellzugriffs-Quickshell-Oberfläche für die aktive Sitzung. Sie ist der Ort, um den Status zu prüfen oder eine häufige Aktion auszuführen, ohne die vollständige Einstellungsanwendung zu öffnen.

Das Panel verwendet die gemeinsamen `argvus-i18n`-Kataloge. Wenn eine andere Sprache in **Systemsteuerung → Gebietsschema & Region** angewendet wird, wird der Systemsteuerungsdienst automatisch neu gestartet, damit der ausgewählte Katalog geladen wird.

Die Systemsteuerung teilt den Taskleistenrand mit ARGVUS Focus und ARGVUS Clock. Das Öffnen des Panels schließt zunächst beide Popups; das Öffnen von Focus oder Clock schließt das Panel.

## Systemsteuerung oder Kontrollzentrum?

Verwenden Sie das Panel für den aktuellen Status und schnelle Aktionen. Verwenden Sie [Control Center](/docs/components/argvus-control-center/), wenn Sie die dauerhafte Desktop-Konfiguration ändern möchten. Zum Beispiel kann das Panel Steuerungen für Aussehen, Anzeige, Netzwerk, Lautstärke, Helligkeit, Benachrichtigungen, Energie und Sitzung anzeigen; die detaillierte visuelle und Layout-Konfiguration gehört in **Control Center → Appearance**.

## Karten

Das aktuelle Kartenregister enthält:

- Benutzer;
- Benachrichtigungen;
- Kalender;
- Wetter;
- Lautstärke;
- Helligkeit;
- Netzwerk;
- Bluetooth;
- System;
- Aussehen;
- Sitzung;
- Anzeige;
- Energie.

Einige Karten sind bedingt. Bluetooth wird ausgeblendet, wenn die Bluetooth-Funktionalität nicht verfügbar ist. Helligkeit wird ausgeblendet, wenn weder die unterstützte Hintergrundbeleuchtung noch ein Monitorsteuerungs-Tool verfügbar ist. Die Kartenliste spiegelt daher die aktuelle Maschine wider, anstatt Steuerungen zu versprechen, die jede Maschine bieten kann.

## Sichtbarkeit und Reihenfolge

Die Seite **Erscheinungsbild → Systemsteuerung** des Panels ermöglicht es Ihnen, Karten zu aktivieren, zu deaktivieren und neu anzuordnen. Der mitgelieferte Helfer zeigt ebenfalls denselben Status an:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```
Verwenden Sie die Benutzeroberfläche, wann immer möglich. Der Zustand des Panels wird als Benutzerkonfiguration gespeichert; er ist getrennt von den erzeugten Hyprland-Layout-Dateien.

Das Deaktivieren einer Karte blendet sie im Panel aus; es wird nicht der dahinterstehende Anbieter deinstalliert. Durch das Neuanordnen wird die Reihenfolge geändert, in der die Karten angezeigt werden. Es gibt keinen `reset`-Unterbefehl im aktuellen Helfer. Wenn die Benutzerkartenpräferenz entfernt wird, normalisiert der Anbieter den Zustand zurück zu den bekannten Karten, die standardmäßig aktiviert und in der verpackten Reihenfolge sind.

Die Kartenanzeige des Control Panels verwaltet nicht mehr eine globale Transparenzeinstellung. Konfigurieren Sie Transparenz und Unschärfe unabhängig für das Control Panel unter **Control Center → Appearance → Control Panel**. Der Hauptschalter **Enable** des Control Panels steuert weiterhin die gesamte Oberfläche und ihren Dienst. `cards-config.sh master set` startet oder stoppt das Panel nur, wenn sich der Schalter ändert; das Setzen des Werts, den es bereits hat, stellt nur sicher, dass ein aktiviertes Panel läuft.

## Tastaturnavigation

Wenn das Panel geöffnet wird, verwenden Sie **↑/↓**, um seinen Inhalt zu scrollen. **Tab** bewegt sich vorwärts durch Schaltflächen, Steuerelemente und Felder; **Shift+Tab** bewegt sich rückwärts. Schaltflächen zeigen den Fokus mit einem hervorgehobenen Rahmen und können mit **Enter** oder **Leertaste** aktiviert werden. Schieberegler und Textfelder behalten diese Tasten für ihre eigene Anpassung oder Bearbeitung. **Esc** schließt das Panel.

## Synchronisation mit dem Rest des Desktops

Die Benachrichtigungskarte blendet ihre Historie aus, während der Modus "Nicht stören" aktiv ist. Benachrichtigungen, die in dieser Zeit empfangen werden, bleiben in Dunst und erscheinen in der Karte wieder, nachdem "Nicht stören" deaktiviert wurde.

Die Karten zeigen den aktuellen Zustand des Desktops. Eine Änderung, die anderswo vorgenommen wird (Systemsteuerung, Taskleiste, Tastenkombination oder der `argvus`-Kommandozeilenbefehl), wird im Panel angezeigt, ohne dass es neu gestartet werden muss:

| Karte | Woher der Zustand kommt | Wann er aktualisiert wird |
| --- | --- | --- |
| Benutzer | `getent passwd` | alle 3 s, während das Panel geöffnet ist |
| Lautstärke | der Standard-Ausgang von PipeWire (`wpctl`) und `pactl subscribe`-Ereignisse | sofort bei jedem Audioereignis; alle 2 s als Sicherheitsnetz |
| Erscheinung (Telemetrie, Animationen und Effekte) | der `/effects`-Bereich von `argvus config` | alle 2 s, während das Panel geöffnet ist |
| Energie | `powerprofilesctl` | alle 3 s, während das Panel geöffnet ist |
| Wetter | die Standortdatei und die Anbieter wttr.in/Open-Meteo | beim Öffnen des Panels und alle 15 Minuten; die Tabs wechseln zwischen den aktuellen Bedingungen und der Tagesvorhersage für die nächsten sieben Tage |

Die Karte "Aussehen" hat zwei unabhängige Schalter. **Animationen** führt `argvus effects-toggle animations toggle` aus und steuert alles, was sich bewegt. **Effekte** führt `argvus effects-toggle effects toggle` aus und schaltet Unschärfe sowie die Transparenz von Terminal, Launcher, Widget Telemetrie, Systemsteuerung und Taskleiste zusammen; es wird als eingeschaltet angezeigt, wenn mindestens eines davon eingeschaltet ist. **SUPER + F6** (`argvus effects-toggle toggle`) schaltet beide zusammen. Das Ändern eines der beiden lädt Hyprland und die Theme-Consumer vor Ort neu: Waybar liest seine Stylesheets erneut ein, das Panel wird über IPC neu geladen und Dunst lädt seine Konfiguration neu, es sei denn, "Nicht stören" ist aktiv, in diesem Fall wird das Neuladen verschoben, bis DND deaktiviert wird. Nichts wird neu gestartet und kein Ladebildschirm erscheint.

Das Scrollen über das Lautstärkesymbol in der Taskleiste und die Medien-Tasten verwendet `argvus config audio`, das die Änderung auf PipeWire anwendet und auch die Lautstärke in `/audio` speichert. Ein Neuladen der Konfiguration stellt daher keine alte Lautstärke wieder her.

## Sitzungsverhalten

`argvus-control-panel.service` wird von `argvus-session` gestartet. Das Öffnen und Schließen des Panels ändert den Zustand des Sitzungspanels, bedeutet jedoch nicht, dass jede Kartenaktion eine persistente Konfiguration ist. Netzwerk-, Audio-, Energie- und Anzeigeaktionen können an ihre Anbieter oder an die aktuelle Desktop-Sitzung übergeben werden.

Siehe [Taskleiste und Panels](/docs/argvus-taskbar/taskbar/) für die Beziehung zwischen Panel, Taskleistenrändern und Fensterlayout.

## Nachtlicht

Die Anzeige zeigt einen Nachtlicht-An/Aus-Schalter und die aktuelle Temperatur. Ihre Ecken und Animationen folgen denselben Themen-Tokens wie die anderen Panelschalter, einschließlich Sticky- und Spaced-Layouts. Der Schalter hat keinen Rahmen und verwendet einen Zeiger-Hand-Cursor, wie die anderen Panelschalter. Er verwendet `argvus config display night-light status|toggle`, prüft alle zwei Sekunden, während er geöffnet ist, und ruft nach einer Aktion erneut ab. Die Zeile wird ausgeblendet, wenn das Backend nicht verfügbar ist; eine fehlgeschlagene Aktion zeigt einen Fehler an. Zeitplanung und Temperatur werden unter **Systemsteuerung > Desktop & Eingabe > Bildschirme > Nachtlicht** konfiguriert. Ein manuelles Zeitplan-Umschalten dauert bis zur nächsten Umstellung; andernfalls ist die Aktivierung dauerhaft.

Die Kalenderleiste, ARGVUS Focus, ARGVUS Clock und das Kontrollpanel schließen sich gegenseitig aus: Wird eines geöffnet, schließen sich die anderen.

## Kompakte mehrsprachige Beschriftungen

Wetter-Tabs verwenden den gemeinsamen Katalog (aktuelle Bedingungen und sieben Tage). Wettermessungen belegen Spalten gleicher Breite; Beschriftungen umbrechen und Werte bleiben ausgerichtet. Kalender-Wochentag-Abkürzungen sind sprachspezifisch und beginnen mit Sonntag, einschließlich der Vorhersagetags-Beschriftungen. Sie sind keine wörtlichen Übersetzungen der englischen Abkürzungen.

Schaltflächen binden ihre Icon/Label-Gruppe an die verfügbare Breite. Wenn eine Beschriftung gekürzt werden muss, zeigt ein Hover oder Fokus auf die Schaltfläche den vollständigen Text an. Schaltflächen für das Energieprofil zeigen ihren Beschreibungstext ebenfalls in einem Tooltip. Lange Schaltflächenbeschreibungen umbrechen, und numerische Felder sowie Benutzereingaben reservieren genügend Platz für die gewählte Schriftart. Die Kartenhöhe wächst mit umgebrochenem Text; verwenden Sie vertikales Scrollen, um die unteren Karten zu sehen. Diese Änderungen bewahren die gewählte Schriftart und die vorhandenen Kartenaktionen.
