---
title: Control Panel
description: Use os cards do painel Quickshell.
slug: pt/0.4.0/docs/user-guide/desktop/control-panel
---

O Control Panel é a superfície Quickshell de acesso rápido da sessão ativa. É o lugar para consultar status ou executar uma ação frequente sem abrir o aplicativo completo de configurações.

Os textos do painel usam os catálogos compartilhados do `argvus-i18n`. Ao aplicar outro idioma em **Control Center → Localidade e região**, o serviço do Control Panel é reiniciado automaticamente para carregar o catálogo selecionado.

O card de aparência do Control Panel não gerencia mais uma Transparência global. Configure Transparência e Blur individualmente para o Control Panel em **Control Center → Aparência → Control Panel**. O controle geral **Ativar** continua controlando toda a superfície e seu serviço.

## Control Panel ou Control Center?

Use o painel para status atual e ações rápidas. Use o [Control Center](../control-center/) quando quiser alterar uma configuração persistente do desktop. Por exemplo, o painel pode oferecer controles de aparência, display, rede, volume, brilho, notificações, energia e sessão; a configuração visual e de layout detalhada fica em **Control Center → Aparência**.

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
* Espaços, bordas e posição;
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

## Comportamento da sessão

`argvus-control-panel.service` é iniciado pelo `argvus-session`. Abrir e fechar o painel altera o estado do painel na sessão, mas não significa que toda ação dos cards seja uma configuração persistente. Ações de rede, áudio, energia e display podem ser encaminhadas aos providers ou à sessão desktop atual.

Veja [taskbar e painéis](./taskbar/) para a relação entre painel, margens da taskbar e layout das janelas.
