---
title: Painel de controlo
description: Use os cards do painel Quickshell.
---

O Control Panel é a superfície Quickshell de acesso rápido da sessão ativa. É o lugar para consultar status ou executar uma ação frequente sem abrir a aplicação completa de definições.

O painel usa o compartilhado `argvus-i18n` catálogos. Quando uma linguagem de interface diferente é selecionada em **Control Center → Preferências → Idioma & Região → Idioma**, o serviço do Painel de Controle é reiniciado automaticamente para que ele carregue o catálogo selecionado. Esta preferência é independente de `LANG`, que continua a ser o local regional para a formatação e aplicações de terceiros. Árabe e Urdu usam layout da direita para a esquerda.

O Control Panel compartilha a lateral da taskbar com ARGVUS Focus e ARGVUS Clock. Ao abrir o painel, os dois popups são fechados primeiro; ao abrir Focus ou Clock, o painel é fechado.

O card de aparência do Control Panel não gerencia mais uma Transparência global. Configure Transparência e Blur individualmente para o Control Panel em **Control Center → Aparência → Control Panel**. O controle geral **Ativar** continua controlando toda a superfície e seu serviço. O `cards-config.sh master set` só reinicia ou para o painel quando o interruptor muda; gravar o valor que ele já tem só garante que um painel ativado esteja a executar.

## Navegação por teclado

Ao abrir o painel, use **↑/↓** para rolar o conteúdo. **Tab** avança entre botões, controles e campos; **Shift+Tab** volta. Botões mostram o foco com uma borda destacada e podem ser acionados com **Enter** ou **Espaço**. Em sliders e campos de texto, as teclas continuam controlando ou editando o próprio campo. **Esc** fecha o painel.

## Control Panel ou Control Center?

Use o painel para status atual e ações rápidas. Use o [Control Center](/pt/docs/components/argvus-control-center/) quando quiser alterar uma configuração persistente do desktop. Por exemplo, o painel pode oferecer controles de aparência, display, rede, volume, brilho, notificações, energia e sessão; a configuração visual e de layout detalhada fica em **Control Center → Aparência**.

## Cartões

O registro atual de cards inclui:

* Utilizador;
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

Use a interface quando possível. O estado do painel é uma configuração do utilizador, separada dos ficheiros Hyprland gerados.

Desativar um card apenas o oculta do painel; não desinstala o provider por trás dele. Reordenar altera a ordem de apresentação. O helper atual não possui subcomando `reset`. Se a preferência dos cards for removida, o provider normaliza o estado novamente com os cards conhecidos, ativados por padrão e na ordem empacotada.

## Sincronização com o resto do desktop

O card **Notificações** oculta o histórico enquanto o Não Perturbe está ativo. O Dunst mantém as notificações recebidas nesse período, e elas voltam a aparecer no card depois que o Não Perturbe é desativado.

Os cards mostram o estado atual do desktop. Uma mudança feita em outro lugar (Control Center, taskbar, atalho de teclado ou linha de comando `argvus`) aparece no painel sem reiniciá-lo:

| Card | De onde vem o estado | Quando atualiza |
| --- | --- | --- |
| Utilizador | `getent passwd` | a cada 3 s com o painel aberto |
| Volume | sink padrão do PipeWire (`wpctl`) e eventos do `pactl subscribe` | na hora, a cada evento de áudio; a cada 2 s como reserva |
| Aparência (Telemetria, Animações e Efeitos) | seção `/effects` do `argvus config` | a cada 2 s com o painel aberto |
| Energia | `powerprofilesctl` | a cada 3 s com o painel aberto |
| Clima | ficheiro de localização e provedores wttr.in/Open-Meteo | ao abrir o painel e a cada 15 min; abas alternam entre condições atuais e previsão diária dos próximos sete dias |

O card de Aparência tem dois interruptores independentes. **Animações** executa `argvus effects-toggle animations toggle` e controla tudo que se move. **Efeitos** executa `argvus effects-toggle effects toggle` e alterna juntos o blur e a transparência de Terminal, Launcher, Widget Telemetry, Control Panel e Taskbar; aparece como ativo quando pelo menos uma delas está ativa. **SUPER + F6** (`argvus effects-toggle toggle`) alterna os dois juntos. Alterar qualquer um recarrega o Hyprland e os consumidores do tema no lugar: a Waybar relê as folhas de estilo, o painel recarrega por IPC e o Dunst recarrega a configuração, exceto quando o Não Perturbe está ativo; nesse caso, a recarga fica pendente até desativá-lo. Nada é reiniciado e nenhum ecrã de carregamento aparece.

O scroll no ícone de volume da taskbar e as teclas de mídia usam `argvus config audio`, que aplica a mudança no PipeWire e também grava o volume em `/audio`. Assim, um reload da configuração não restaura um volume antigo.

## Comportamento da sessão

`argvus-control-panel.service` é iniciado pelo `argvus-session`. Abrir e fechar o painel altera o estado do painel na sessão, mas não significa que toda ação dos cards seja uma configuração persistente. Ações de rede, áudio, energia e display podem ser encaminhadas aos providers ou à sessão desktop atual.

Veja [taskbar e painéis](/pt/docs/argvus-taskbar/taskbar/) para a relação entre painel, margens da taskbar e layout das janelas.

## Luz noturna

O cartão Display mostra uma chave liga/desliga de luz noturna e a temperatura ativa. Os cantos e as animações seguem os mesmos tokens de tema das outras chaves do painel, incluindo os modos Sticky e Spaced. A chave não tem borda e usa cursor de mão (pointer), como as outras chaves do painel. Usa `argvus config display night-light status|toggle`, consulta a cada dois segundos enquanto aberto e atualiza após uma ação. A linha fica oculta quando o backend está indisponível; falhas nas ações mostram um erro. Temperatura e programação ficam em **Central de Controle > ambiente de trabalho e entrada > Monitores > Luz noturna**. Com programação, o toggle manual vale até a próxima transição; sem ela, a ativação é persistente.

O calendário da taskbar, ARGVUS Focus, ARGVUS Clock e Control Panel são exclusivos entre si: abrir um fecha os demais.

## Rótulos multilíngues compactos

As abas da meteorologia usam o catálogo compartilhado (condições atuais e sete
dias). As medições têm colunas da mesma largura; os rótulos quebram linha e os
valores continuam alinhados. As abreviações dos dias são próprias de cada idioma,
com domingo primeiro, inclusive na previsão. Não são traduções literais das
abreviações inglesas.

Os botões limitam ícone e rótulo ao espaço disponível. Quando é preciso usar
reticências, passar o ponteiro ou focar o botão mostra o texto completo. Os perfis
de energia também oferecem a descrição em uma dica. Estados longos quebram linha,
e os campos numéricos e de edição reservam espaço para a fonte escolhida. A altura
dos cards acompanha o texto; use a rolagem vertical para acessar os cards abaixo.
A fonte selecionada e as ações dos cards são preservadas.
