---
title: Control Panel
description: Use os cards do painel Quickshell.
---

O Control Panel é a superfície Quickshell de acesso rápido da sessão ativa. É o lugar para consultar status ou executar uma ação frequente sem abrir o aplicativo completo de configurações.

Os textos do painel usam os catálogos compartilhados do `argvus-i18n`. Ao aplicar outro idioma em **Control Center → Localidade e região**, o serviço do Control Panel é reiniciado automaticamente para carregar o catálogo selecionado.

O Control Panel compartilha a lateral da taskbar com ARGVUS Focus e ARGVUS Clock. Ao abrir o painel, os dois popups são fechados primeiro; ao abrir Focus ou Clock, o painel é fechado.

O card de aparência do Control Panel não gerencia mais uma Transparência global. Configure Transparência e Blur individualmente para o Control Panel em **Control Center → Aparência → Control Panel**. O controle geral **Ativar** continua controlando toda a superfície e seu serviço. O `cards-config.sh master set` só reinicia ou para o painel quando o interruptor muda; gravar o valor que ele já tem só garante que um painel ativado esteja rodando.

## Navegação por teclado

Ao abrir o painel, use **↑/↓** para rolar o conteúdo. **Tab** avança entre botões, controles e campos; **Shift+Tab** volta. Botões mostram o foco com uma borda destacada e podem ser acionados com **Enter** ou **Espaço**. Em sliders e campos de texto, as teclas continuam controlando ou editando o próprio campo. **Esc** fecha o painel.

## Control Panel ou Control Center?

Use o painel para status atual e ações rápidas. Use o [Control Center](/pt/docs/components/argvus-control-center/) quando quiser alterar uma configuração persistente do desktop. Por exemplo, o painel pode oferecer controles de aparência, display, rede, volume, brilho, notificações, energia e sessão; a configuração visual e de layout detalhada fica em **Control Center → Aparência**.

## Cards

O registro atual de cards inclui:

* Usuário;
* Notificações;
* Calendário;
* Clima;
* Volume;
* Brilho;
* Rede;
* Bluetooth;
* Sistema;
* Aparência;
* Sessão;
* Display;
* Energia.

Alguns cards são condicionais. Bluetooth fica oculto quando o recurso não está disponível. Brilho fica oculto quando nenhuma ferramenta compatível de backlight ou controle de monitor está disponível. Portanto, a lista reflete a máquina atual e não promete controles que todo hardware possa oferecer.

## Visibilidade e ordem

A página **Aparência → Control Panel** permite ativar, desativar e reordenar cards. O helper incluído também expõe o mesmo estado:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```

Use a interface quando possível. O estado do painel é uma configuração do usuário, separada dos arquivos Hyprland gerados.

Desativar um card apenas o oculta do painel; não desinstala o provider por trás dele. Reordenar altera a ordem de apresentação. O helper atual não possui subcomando `reset`. Se a preferência dos cards for removida, o provider normaliza o estado novamente com os cards conhecidos, habilitados por padrão e na ordem empacotada.

## Sincronização com o resto do desktop

Os cards mostram o estado atual do desktop. Uma mudança feita em outro lugar (Control Center, taskbar, atalho de teclado ou linha de comando `argvus`) aparece no painel sem reiniciá-lo:

| Card | De onde vem o estado | Quando atualiza |
| --- | --- | --- |
| Usuário | `getent passwd` | a cada 3 s com o painel aberto |
| Volume | sink padrão do PipeWire (`wpctl`) e eventos do `pactl subscribe` | na hora, a cada evento de áudio; a cada 2 s como reserva |
| Aparência (Telemetria, Animações e Efeitos) | seção `/effects` do `argvus config` | a cada 2 s com o painel aberto |
| Energia | `powerprofilesctl` | a cada 3 s com o painel aberto |
| Clima | arquivo de localização | ao abrir o painel e a cada 15 min |

O card de Aparência tem dois interruptores independentes. **Animações** executa `argvus effects-toggle animations toggle` e controla tudo que se move. **Efeitos** executa `argvus effects-toggle effects toggle` e alterna juntos o blur e a transparência de Terminal, Launcher, Widget Telemetry, Control Panel e Taskbar; aparece como ativo quando pelo menos uma delas está ativa. **SUPER + F6** (`argvus effects-toggle toggle`) alterna os dois juntos. Alterar qualquer um recarrega o Hyprland e os consumidores do tema no lugar: a Waybar relê as folhas de estilo, o painel recarrega por IPC e o Dunst recarrega a configuração. Nada é reiniciado e nenhuma tela de carregamento aparece.

O scroll no ícone de volume da taskbar e as teclas de mídia usam `argvus config audio`, que aplica a mudança no PipeWire e também grava o volume em `/audio`. Assim, um reload da configuração não restaura um volume antigo.

## Comportamento da sessão

`argvus-control-panel.service` é iniciado pelo `argvus-session`. Abrir e fechar o painel altera o estado do painel na sessão, mas não significa que toda ação dos cards seja uma configuração persistente. Ações de rede, áudio, energia e display podem ser encaminhadas aos providers ou à sessão desktop atual.

Veja [taskbar e painéis](/pt/docs/argvus-taskbar/taskbar/) para a relação entre painel, margens da taskbar e layout das janelas.

## Luz noturna

O cartão Display mostra uma chave liga/desliga de luz noturna e a temperatura ativa. Os cantos e as animações seguem os mesmos tokens de tema das outras chaves do painel, incluindo os modos Sticky e Float. A chave não tem borda e usa cursor de mão (pointer), como as outras chaves do painel. Usa `argvus config display night-light status|toggle`, consulta a cada dois segundos enquanto aberto e atualiza após uma ação. A linha fica oculta quando o backend está indisponível; falhas nas ações mostram um erro. Temperatura e programação ficam em **Central de Controle > Área de trabalho e entrada > Monitores > Luz noturna**. Com programação, o toggle manual vale até a próxima transição; sem ela, a ativação é persistente.

O calendário da taskbar, ARGVUS Focus, ARGVUS Clock e Control Panel são exclusivos entre si: abrir um fecha os demais.
