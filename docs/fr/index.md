---
title: Panneau de configuration
description: Utilisez les cartes du panneau de contrôle Quickshell.
---
Le Panneau de configuration est la surface Quickshell à accès rapide pour la session active. C'est l'endroit pour vérifier le statut ou effectuer une action fréquente sans ouvrir l'application de paramètres complète.

Le panneau utilise le partage `argvus-i18n` catalogues. Lorsqu'un langage d'interface différent est sélectionné dans **Control Center → Préférences → Langue et région → Langue**, le service de panneau de configuration est redémarré automatiquement pour charger le catalogue sélectionné. Cette préférence est indépendante de `LANG`, qui reste le local régional pour le formatage et les applications tierces. Arabe et Urdu utilisent la disposition de droite à gauche.

Le Panneau de configuration partage le bord de la barre des tâches avec ARGVUS Focus et ARGVUS Clock. L'ouverture du panneau ferme d'abord les deux fenêtres contextuelles ; l'ouverture de Focus ou Clock ferme le panneau.

## Panneau de configuration ou Centre de contrôle ?

Utilisez le panneau pour l'état actuel et les actions rapides. Utilisez [Centre de Contrôle](/docs/components/argvus-control-center/) lorsque vous souhaitez modifier la configuration persistante du bureau. Par exemple, le panneau peut exposer les contrôles d'apparence, d'affichage, de réseau, de volume, de luminosité, de notification, d'alimentation et de session ; la configuration détaillée visuelle et de mise en page se trouve dans **Centre de Contrôle → Apparence**.

## Cartes

Le registre actuel des cartes comprend :

- Utilisateur ;
- Notifications ;
- Calendrier ;
- Météo ;
- Volume ;
- Luminosité ;
- Réseau ;
- Bluetooth ;
- Système ;
- Apparence ;
- Session ;
- Affichage ;
- Alimentation.

Certaines cartes sont conditionnelles. Bluetooth est caché lorsque la capacité Bluetooth n'est pas disponible. La luminosité est cachée lorsque ni le rétroéclairage pris en charge ni l'outil de contrôle du moniteur n'est disponible. La liste des cartes reflète donc la machine actuelle plutôt que de promettre les contrôles que chaque machine peut fournir.

## Visibilité et ordre

La page **Apparence → Panneau de configuration** du panneau vous permet d'activer, de désactiver et de réorganiser les cartes. L'assistant fourni expose également le même état :

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```
Utilisez l'interface utilisateur lorsque cela est possible. L'état du panneau est enregistré comme configuration utilisateur ; il est séparé des fichiers de mise en page Hyprland générés.

Désactiver une carte la masque dans le panneau ; cela ne désinstalle pas le fournisseur associé. Réorganiser les cartes change l'ordre dans lequel elles sont présentées. Il n'y a pas de sous-commande `reset` dans l'assistant actuel. Si la préférence utilisateur pour une carte est supprimée, le fournisseur normalise l'état en revenant aux cartes connues, activées par défaut et dans l'ordre fourni.

La carte d'apparence du Panneau de configuration ne gère plus le réglage global de Transparence. Configurez la Transparence et le Flou indépendamment pour le Panneau de configuration dans **Centre de contrôle → Apparence → Panneau de configuration**. L'interrupteur principal **Activer** du Panneau de configuration contrôle toujours toute la surface et son service. `cards-config.sh master set` redémarre ou arrête le panneau uniquement lorsque l'interrupteur change ; définir la valeur qu'il a déjà garantit seulement qu'un panneau activé fonctionne.

## Navigation au clavier

Lorsque le panneau s'ouvre, utilisez **↑/↓** pour faire défiler son contenu. **Tab** permet d'avancer à travers les boutons, les contrôles et les champs ; **Shift+Tab** permet de reculer. Les boutons montrent le focus avec une bordure surlignée et peuvent être activés avec **Enter** ou **Espace**. Les curseurs et les champs de texte conservent ces touches pour leurs propres réglages ou modifications. **Esc** ferme le panneau.

## Rester synchronisé avec le reste du bureau

La carte des Notifications cache son historique pendant que Ne Pas Déranger est actif. Les notifications reçues pendant ce temps restent dans Dunst et réapparaissent dans la carte après que Ne Pas Déranger est désactivé.

Les cartes montrent l'état en direct du bureau. Un changement effectué ailleurs (Centre de Contrôle, la barre des tâches, un raccourci clavier ou la ligne de commande `argvus`) apparaît dans le panneau sans le redémarrer :

| Carte | D'où provient l'état | Quand il se rafraîchit |
| --- | --- | --- |
| Utilisateur | `getent passwd` | toutes les 3 s pendant que le panneau est ouvert |
| Volume | le périphérique de sortie par défaut de PipeWire (`wpctl`) et les événements `pactl subscribe` | immédiatement à chaque événement audio ; toutes les 2 s comme filet de sécurité |
| Apparence (Télémetrie, Animations et Effets) | la section `/effects` de `argvus config` | toutes les 2 s pendant que le panneau est ouvert |
| Alimentation | `powerprofilesctl` | toutes les 3 s pendant que le panneau est ouvert |
| Météo | le fichier de localisation et les fournisseurs wttr.in/Open-Meteo | à l'ouverture du panneau et toutes les 15 min ; les onglets alternent entre les conditions actuelles et les prévisions quotidiennes pour les sept prochains jours |

La carte Apparence a deux interrupteurs indépendants. **Animations** exécute `argvus effects-toggle animations toggle` et contrôle tout ce qui bouge. **Effets** exécute `argvus effects-toggle effects toggle` et active ou désactive le flou et la transparence du Terminal, du Lanceur, de la Télémétrie des widgets, du Panneau de configuration et de la Barre des tâches ensemble ; il apparaît comme activé dès qu'au moins l'un d'entre eux est activé. **SUPER + F6** (`argvus effects-toggle toggle`) active ou désactive les deux en même temps. Modifier l'un ou l'autre recharge Hyprland et les consommateurs de thèmes en place : Waybar relit ses feuilles de style, le panneau se recharge via IPC et Dunst recharge sa configuration sauf si le mode Ne pas déranger est actif, auquel cas son rechargement est différé jusqu'à ce que le mode Ne pas déranger soit désactivé. Rien n'est redémarré et aucun écran de chargement n'apparaît.

Faire défiler l'icône de volume de la barre des tâches et utiliser les touches multimédia utilisent `argvus config audio`, qui applique la modification à PipeWire et enregistre également le volume dans `/audio`. Un rechargement de la configuration ne restaure donc pas un ancien volume.

## Comportement de la session

`argvus-control-panel.service` est lancé par `argvus-session`. Ouvrir et fermer le panneau modifie l'état du panneau de la session, mais ne signifie pas que chaque action sur une carte est une configuration persistante. Les actions réseau, audio, alimentation et affichage peuvent être transmises à leurs fournisseurs ou à la session de bureau actuelle.

Voir [barre des tâches et panneaux](/docs/argvus-taskbar/taskbar/) pour la relation entre le panneau, les marges de la barre des tâches et la disposition des fenêtres.

## Lumière nocturne

La carte d'affichage montre un interrupteur Nuit blanche activé/désactivé et la température active. Ses coins et ses animations suivent les mêmes jetons de thème que les autres interrupteurs du panneau, y compris les dispositions Collé et Espacé. L'interrupteur n'a pas de bordure et utilise un curseur en forme de main pointant, comme les autres interrupteurs du panneau. Il utilise `argvus config display night-light status|toggle`, sondant toutes les deux secondes lorsqu'il est ouvert et refaisant une requête après une action. La ligne est masquée lorsque le backend est indisponible ; une action échouée affiche une erreur. La planification et la température sont configurées dans **Centre de contrôle > Bureau et saisie > Affichages > Lumière nocturne**. Un basculement manuel programmé dure jusqu'à la prochaine transition ; sinon, l'activation est persistante. 

Le calendrier de la barre des tâches, ARGVUS Focus, ARGVUS Clock et le Panneau de contrôle sont mutuellement exclusifs : l'ouverture de l'un ferme les autres.

## Étiquettes multilingues compactes

Les onglets météo utilisent le catalogue partagé (conditions actuelles et sept jours). Les mesures météorologiques occupent des colonnes de largeur égale ; les étiquettes se renvoient à la ligne et les valeurs restent alignées. Les abréviations des jours de la semaine du calendrier sont spécifiques à la langue locale et commencent par dimanche, y compris les étiquettes des jours de prévision. Ce ne sont pas des traductions littérales des abréviations anglaises.

Les boutons lient leur groupe icône/étiquette à la largeur disponible. Si une étiquette nécessite des points de suspension, passer la souris dessus ou sélectionner le bouton affiche son texte complet. Les boutons de profil d'alimentation exposent également leur texte descriptif dans une info-bulle. Les longues descriptions de commutateur se renvoient à la ligne, et les champs numériques ainsi que les entrées utilisateur réservent suffisamment de place pour la police choisie. La hauteur de la carte augmente avec le texte renvoyé à la ligne ; utilisez le défilement vertical pour voir les cartes inférieures. Ces changements préservent la police sélectionnée et les actions existantes de la carte.
