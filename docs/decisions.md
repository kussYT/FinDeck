# Décisions techniques — ADR simplifiées

Chaque décision indique son statut. « Acceptée » signifie retenue pour la cible, pas déjà implémentée.

## ADR-001 — Architecture en couches

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Contexte :** le sujet évalue la séparation des responsabilités.
- **Décision :** `app`, `core`, `domain`, `data`, `features`, avec repository entre état et sources.
- **Conséquence :** davantage de fichiers, mais calculs, cache et UI deviennent testables séparément.

## ADR-002 — Riverpod pour l'état

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** exposer les états asynchrones et métier via Riverpod.
- **Pourquoi :** modélisation claire de loading/data/error/refreshing, injection testable et état hors des Widgets.
- **Conséquence :** l'équipe doit comprendre providers, notifiers, observation et cycle de vie.

## ADR-003 — Repository responsable du cache

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** le repository choisit API, cache frais ou repli stale.
- **Pourquoi :** ni l'écran ni la source distante ne doivent connaître toute la politique de données.
- **Conséquence :** les résultats doivent porter les métadonnées de fraîcheur nécessaires.

## ADR-004 — SQLite et SharedPreferences

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** `sqflite` pour métier/cache ; SharedPreferences seulement pour préférences simples.
- **Pourquoi :** relations, requêtes, transactions atomiques et persistance après redémarrage.
- **Conséquence :** migrations à gérer explicitement.

## ADR-005 — Twelve Data derrière une abstraction locale

- **Statut :** Acceptée sous validation **[DÉCIDÉ — FINDECK]**
- **Décision :** fournisseur principal envisagé, connu uniquement de la couche distante.
- **Pourquoi :** actions, recherche et séries temporelles correspondent au concept.
- **Conséquence :** endpoints/quota/conditions actuels doivent être vérifiés avant codage ; changement de fournisseur possible sans modifier l'UI.

## ADR-006 — Aucun backend en V1

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** Flutter communique directement avec l'API et stocke localement.
- **Pourquoi :** périmètre universitaire, besoin explicite de persistance/cache local et absence de compte.
- **Conséquence :** pas de synchronisation multi-appareil ; une clé mobile reste extractible.

## ADR-007 — Actif, carte et position séparés

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** `Asset` pour la finance, `CollectibleCard` pour la collection, `PortfolioPosition` pour le fictif.
- **Pourquoi :** éviter de confondre possession ludique et investissement simulé.
- **Conséquence :** les liens utilisent le symbole/identifiant d'actif, sans fusionner les cycles de vie.

## ADR-008 — Gamification sans signal financier

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** rareté et catégorie de carte n'entrent dans aucun calcul de performance ni conseil.
- **Pourquoi :** éviter qu'une mécanique de jeu soit interprétée comme recommandation.
- **Conséquence :** textes et visuels doivent le rappeler clairement.

## ADR-009 — Calculs purs dans le domaine

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** valeur, gain, performance et allocation sont des fonctions/services sans Flutter ni I/O.
- **Pourquoi :** exactitude, tests unitaires et explication en soutenance.
- **Conséquence :** formatage et données manquantes sont traités hors formule.

## ADR-010 — GoRouter, Dio et fl_chart

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** GoRouter pour les routes, Dio pour HTTP, fl_chart pour les graphiques.
- **Conséquence :** versions et API exactes seront figées au scaffold, sans ajouter d'autres packages équivalents sans justification.

## Décisions en attente

- ADR futur : catalogue initial et catégories ;
- ADR futur : barème, probabilités et hasard des packs ;
- ADR futur : solde/acquisition des gemmes ;
- ADR futur : seuils de fraîcheur et rétention ;
- ADR futur : stratégie de code generation et modèles immuables.
