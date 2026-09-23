# Animations prévues

**[IMPOSÉ — SUJET]** Au moins trois animations pertinentes sont nécessaires, dont au moins deux au comportement explicitement contrôlé dans le code.

## Plan retenu

| Animation | Intérêt utilisateur | Implémentation cible | Codée ? |
|---|---|---|---|
| Ouverture de pack | matérialiser l'action et révéler les cartes progressivement | `AnimationController`, `Tween`, `AnimatedBuilder` ou équivalent | Oui |
| Favori | confirmer immédiatement l'ajout/retrait | échelle + légère rotation contrôlées | Oui |
| Valeur du portefeuille | rendre lisible le passage d'une ancienne à une nouvelle valeur | interpolation numérique contrôlée | Oui |

Les trois sont prévues comme animations codées ; l'exigence minimale de deux sera donc couverte sans dépendre d'un package d'animation.

## Ouverture de pack

Séquence cible :

1. pack au repos ;
2. réaction au déclenchement validé ;
3. ouverture/éclat ;
4. révélation séquentielle des cartes ;
5. état final stable et accessible.

Le débit des gemmes et l'ajout des cartes sont une opération métier atomique distincte de l'animation. Une animation interrompue ne doit ni doubler le débit ni perdre les cartes obtenues.

## Favori

Le cœur change d'état avec une courte interpolation d'échelle et de rotation. L'état final vient de la persistance confirmée. En cas d'échec, l'icône revient à un état cohérent et un message est présenté.

## Valeur du portefeuille

Lorsqu'une nouvelle valeur calculée remplace l'ancienne, le nombre affiché est interpolé entre les deux. Le calcul final reste exact ; seule la présentation est animée.

## Tests et démonstration

- vérifier le début, la fin et l'état stable de chaque animation ;
- empêcher les doubles déclenchements pendant une ouverture de pack ;
- tester l'action métier indépendamment de l'animation ;
- présenter le code de contrôle pendant la soutenance ;
- vérifier que l'interface reste compréhensible lorsque les animations sont réduites.

## À décider

**[À DÉCIDER]** Durées, courbes, effets graphiques, sons et vibrations ne sont pas définis. Les sons/vibrations ne sont pas requis et ne doivent pas être ajoutés automatiquement.
