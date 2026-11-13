---
title: Pannello di controllo
description: Usa le schede del pannello di controllo Quickshell.
---
Il Pannello di Controllo è la superficie Quickshell ad accesso rapido per la sessione attiva. È il luogo dove controllare lo stato o eseguire un'azione frequente senza aprire l'applicazione completa delle impostazioni.

Il pannello utilizza il condiviso `argvus-i18n` cataloghi. Quando una lingua di interfaccia diversa viene selezionata in **Control Center → Preferenze → Lingua & Regione → Lingua**, il servizio Pannello di controllo viene riavviato automaticamente in modo da caricare il catalogo selezionato. Questa preferenza è indipendente `LANG`, che rimane il locale regionale per la formattazione e applicazioni di terze parti. Arabo e Urdu usano il layout di destra a sinistra.

Il Pannello di Controllo condivide il bordo della barra delle applicazioni con ARGVUS Focus e ARGVUS Clock. Aprire il pannello chiude prima entrambi i popup; aprire Focus o Clock chiude il pannello.

## Pannello di Controllo o Centro di Controllo?

Usa il pannello per lo stato corrente e le azioni rapide. Usa [Centro di Controllo](/docs/components/argvus-control-center/) quando vuoi modificare la configurazione persistente del desktop. Ad esempio, il pannello può mostrare controlli per aspetto, display, rete, volume, luminosità, notifiche, alimentazione e sessione; la configurazione dettagliata di visualizzazione e layout appartiene a **Centro di Controllo → Aspetto**.

## Schede

Il registro delle schede attuale include:

- Utente;
- Notifiche;
- Calendario;
- Meteo;
- Volume;
- Luminosità;
- Rete;
- Bluetooth;
- Sistema;
- Aspetto;
- Sessione;
- Visualizzazione;
- Alimentazione.

Alcune schede sono condizionali. Il Bluetooth è nascosto quando la funzionalità Bluetooth non è disponibile. La luminosità è nascosta quando non sono disponibili né il supporto retroilluminazione né lo strumento di controllo del monitor. La lista delle schede riflette quindi la macchina attuale piuttosto che promettere controlli che ogni macchina può fornire.

## Visibilità e ordine

La pagina **Aspetto → Pannello di Controllo** del pannello ti permette di abilitare, disabilitare e riordinare le schede. L'assistente incluso espone anche lo stesso stato:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```
Usa l'interfaccia utente quando possibile. Lo stato del pannello viene memorizzato come configurazione utente; è separato dai file di layout Hyprland generati.

Disabilitare una scheda la nasconde dal pannello; non disinstalla il provider dietro di essa. Riordinare cambia l'ordine in cui le schede sono presentate. Non esiste un sottocomando `reset` nell'attuale helper. Se la preferenza della scheda utente viene rimossa, il provider normalizza lo stato tornando alle schede conosciute, abilitate per impostazione predefinita e nell'ordine incluso nel pacchetto.

La scheda Aspetto del Pannello di Controllo non gestisce più un'impostazione globale di Trasparenza. Configura Trasparenza e Sfocatura indipendentemente per il Pannello di Controllo in **Centro di Controllo → Aspetto → Pannello di Controllo**. L'interruttore principale **Abilita** del Pannello di Controllo controlla ancora l'intera superficie e il suo servizio. `cards-config.sh master set` riavvia o ferma il pannello solo quando l'interruttore cambia; impostare il valore già presente garantisce solo che il pannello abilitato funzioni.

## Navigazione con tastiera

Quando il pannello si apre, usa **↑/↓** per scorrere il suo contenuto. **Tab** muove in avanti tra pulsanti, controlli e campi; **Shift+Tab** muove all'indietro. I pulsanti mostrano il focus con un bordo evidenziato e possono essere attivati con **Enter** o **Space**. Slider e campi di testo mantengono quei tasti per il loro regolamento o modifica. **Esc** chiude il pannello.

## Sincronizzazione con il resto del desktop

La scheda Notifiche nasconde la sua cronologia mentre Non disturbare è attivo. Le notifiche ricevute in quel periodo restano in Dunst e appaiono nuovamente nella scheda dopo che Non disturbare viene disattivato.

Le schede mostrano lo stato live del desktop. Una modifica effettuata altrove (Centro di Controllo, la barra delle applicazioni, una scorciatoia da tastiera o la linea di comando `argvus`) appare nel pannello senza bisogno di riavviarlo:

| Scheda | Da dove proviene lo stato | Quando si aggiorna |
| --- | --- | --- |
| Utente | `getent passwd` | ogni 3 s mentre il pannello è aperto |
| Volume | l'uscita predefinita di PipeWire (`wpctl`) e gli eventi `pactl subscribe` | immediatamente ad ogni evento audio; ogni 2 s come rete di sicurezza |
| Aspetto (Telemetria, Animazioni ed Effetti) | la sezione `/effects` di `argvus config` | ogni 2 s mentre il pannello è aperto |
| Alimentazione | `powerprofilesctl` | ogni 3 s mentre il pannello è aperto |
| Meteo | il file della posizione e i provider wttr.in/Open-Meteo | quando si apre il pannello e ogni 15 min; le schede alternano tra condizioni attuali e previsione giornaliera per i prossimi sette giorni |

La scheda Aspetto ha due interruttori indipendenti. **Animazioni** esegue `argvus effects-toggle animations toggle` e controlla tutto ciò che si muove. **Effetti** esegue `argvus effects-toggle effects toggle` e commuta contemporaneamente sfocatura e trasparenza di Terminal, Launcher, Widget Telemetry, Pannello di Controllo e Barra delle Applicazioni; appare attivo quando almeno uno di essi è attivo. **SUPER + F6** (`argvus effects-toggle toggle`) commuta entrambi insieme. Modificare uno qualsiasi dei due ricarica Hyprland e i consumatori di tema sul posto: Waybar rilegge i suoi fogli di stile, il pannello si ricarica tramite IPC e Dunst ricarica la sua configurazione a meno che Non Disturbare sia attivo, nel qual caso la sua ricarica è differita fino a quando DND è disattivato. Nulla viene riavviato e non appare alcuna schermata di caricamento.

Scorrere sull'icona del volume nella barra delle applicazioni e usare i tasti multimediali utilizza `argvus config audio`, che applica la modifica a PipeWire e registra anche il volume in `/audio`. Un ricaricamento della configurazione quindi non ripristina un vecchio volume.

## Comportamento della sessione

`argvus-control-panel.service` viene avviato da `argvus-session`. Aprire e chiudere il pannello cambia lo stato del pannello della sessione, ma non significa che ogni azione della scheda sia una configurazione persistente. Azioni relative a rete, audio, energia e display possono essere affidate ai loro provider o alla sessione desktop corrente.

Vedi [barra delle applicazioni e pannelli](/docs/argvus-taskbar/taskbar/) per la relazione tra il pannello, i margini della barra delle applicazioni e il layout delle finestre.

## Luce notturna

La scheda Display mostra un interruttore Notte On/Off e la temperatura attiva. I suoi angoli e le animazioni seguono gli stessi token del tema degli altri interruttori del pannello, inclusi i layout Sticky e Spaced. L'interruttore non ha bordo e utilizza un cursore a mano indicante, come gli altri interruttori del pannello. Usa `argvus config display night-light status|toggle`, interrogando ogni due secondi mentre è aperto e rifacendo la richiesta dopo un'azione. La riga è nascosta quando il backend non è disponibile; un'azione fallita mostra un errore. La pianificazione e la temperatura sono configurate in **Centro di Controllo > Desktop e Input > Display > Luce Notturna**. Un interruttore manuale programmato dura fino alla transizione successiva; altrimenti l'attivazione è persistente.

Il calendario della barra delle applicazioni, ARGVUS Focus, ARGVUS Clock e il Pannello di Controllo sono mutuamente esclusivi: aprirne uno chiude gli altri.

## Etichette multilingue compatte

Le schede del meteo utilizzano il catalogo condiviso (condizioni attuali e sette giorni). Le misurazioni meteorologiche occupano colonne a larghezza uguale; le etichette vanno a capo e i valori restano allineati. Le abbreviazioni dei giorni della settimana del calendario sono specifiche della località e con domenica come primo giorno, comprese le etichette dei giorni delle previsioni. Non sono traduzioni letterali delle abbreviazioni inglesi.

I pulsanti legano il loro gruppo icona/etichetta alla larghezza disponibile. Se un'etichetta necessita di ellissi, passando il mouse o concentrandosi sul pulsante viene mostrato il testo completo. I pulsanti del profilo energetico mostrano anche il testo descrittivo in un tooltip. Le descrizioni lunghe degli interruttori vanno a capo, e i campi numerici e gli input dell'utente riservano spazio sufficiente per il font scelto. L'altezza della scheda aumenta con il testo a capo; usa lo scorrimento verticale per vedere le schede inferiori. Queste modifiche preservano il font selezionato e le azioni esistenti della scheda.
