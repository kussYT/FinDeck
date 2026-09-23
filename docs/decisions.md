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

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]** ; partiellement implémentée pour les données utilisateur
- **Décision :** `sqflite` pour métier/cache ; SharedPreferences seulement pour préférences simples.
- **Pourquoi :** relations, requêtes, transactions atomiques et persistance après redémarrage.
- **Conséquence :** migrations à gérer explicitement. `sqflite` 2.3.2 stocke aujourd'hui les achats fictifs et les favoris. Le cache et SharedPreferences ne sont pas des dépendances utilisées.

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
- **Conséquence :** le formatage reste hors des formules. Une donnée manquante est un résultat explicite, pas une valeur inventée. Les formules sont implémentées dans `PortfolioCalculator` ; l'écran ne les affiche pas encore.

## ADR-010 — GoRouter, Dio et fl_chart

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** GoRouter pour les routes, Dio pour HTTP, fl_chart pour les graphiques.
- **Conséquence :** GoRouter 14.2.3 est épinglé avec le socle. Dio et fl_chart seront épinglés lors de leur phase, sans ajouter d'autres packages équivalents sans justification.

## ADR-011 — Socle sans génération de code

- **Statut :** Acceptée pour le socle **[DÉCIDÉ — FINDECK]**
- **Contexte :** l'usage d'un générateur Riverpod ou JSON devait être tranché au scaffold.
- **Décision :** providers écrits à la main, sans `riverpod_generator`, Freezed ni `json_serializable`.
- **Pourquoi :** ces outils n'ont aucun usage tant qu'il n'y a ni modèle ni JSON.
- **Conséquence :** le choix pourra être rouvert avant la création du domaine, sans changer les responsabilités.

## ADR-012 — Shell de navigation provisoire

- **Statut :** Acceptée pour le socle, révisable avec les maquettes **[DÉCIDÉ — FINDECK]**
- **Décision :** barre inférieure, routes `/market`, `/collection`, `/portfolio`, départ sur `/market`.
- **Pourquoi :** les trois espaces étaient déjà retenus et le socle devait permettre de passer de l'un à l'autre.
- **Conséquence :** les routes enfants ne sont pas anticipées. Le regroupement Favoris/Marché reste ouvert.

## ADR-013 — Français pour les textes du socle

- **Statut :** Acceptée pour les textes existants **[DÉCIDÉ — FINDECK]**
- **Décision :** les trois écrans provisoires sont rédigés en français. Les identifiants techniques restent en anglais.
- **Pourquoi :** la documentation et la demande de réalisation sont en français, et ces écrans devaient expliquer leur état.
- **Conséquence :** la langue des écrans métier reste à confirmer avant leur rédaction.

## ADR-014 — Versions et identifiant du socle

- **Statut :** Acceptée **[DÉCIDÉ — FINDECK]**
- **Décision :** Flutter 3.16.4, Dart 3.2.3, contrainte SDK `>=3.2.3 <4.0.0`, `flutter_riverpod` 2.6.1, `go_router` 14.2.3 et `flutter_lints` 2.0.3. L'identifiant d'application est `fr.uphf.findeck`. Le nom affiché est FinDeck.
- **Pourquoi :** ce sont les versions les plus récentes compatibles avec le SDK installé. Les majeures suivantes de Riverpod, GoRouter et des lints ne le sont pas.
- **Conséquence :** `sqflite` 2.3.2 est une dépendance de l'application. `sqflite_common_ffi` 2.3.2+1 est limité aux tests sur ordinateur. Dio, SharedPreferences et fl_chart ne sont pas des dépendances. La valeur `1.0.0+1` du pubspec vient du modèle Flutter et n'est pas un numéro de version publié.

## ADR-015 — `double` et résultat non calculable

- **Statut :** Implémentée pour les calculs **[DÉCIDÉ — FINDECK]**
- **Contexte :** le type numérique et la représentation d'un cours manquant devaient être choisis avant les formules.
- **Décision :** les montants sont des `double`. Un résultat est `KnownNumber` ou `UnavailableNumber`. Les calculs n'arrondissent pas les valeurs intermédiaires.
- **Pourquoi :** aucun package supplémentaire, formules explicables, et distinction visible entre zéro connu et valeur absente.
- **Conséquence :** 0,1 + 0,2 n'est pas exactement 0,3. Un dépassement vers l'infini rend la valorisation non calculable au lieu de produire un montant connu infini. L'affichage devra arrondir plus tard, sans modifier le résultat du domaine. La fraîcheur d'un cours n'est pas encore classée.

## ADR-016 — Sous-totaux par devise

- **Statut :** Implémentée pour les calculs **[DÉCIDÉ — FINDECK]**
- **Contexte :** il fallait choisir entre un portefeuille à devise unique et des sous-totaux séparés.
- **Décision :** une devise produit son propre sous-total. Des devises différentes ne sont pas additionnées et aucun taux de change n'est appliqué. Une position sans cours rend le sous-total de sa devise incomplet.
- **Pourquoi :** une somme d'euros et de dollars n'a pas de sens, et une somme partielle ne doit pas être présentée comme un total.
- **Conséquence :** le futur écran devra montrer chaque devise séparément. La fraîcheur des cours reste à décider.

## ADR-017 — Identité locale d'un instrument

- **Statut :** Implémentée pour les favoris et les achats **[DÉCIDÉ — FINDECK]**
- **Contexte :** un symbole peut exister sur plusieurs places. Le calculateur, lui, ne connaît que le symbole et la devise.
- **Décision :** chaque instrument suivi reçoit un identifiant local. L'unicité métier est le couple symbole et place. Une place vide signifie qu'elle est inconnue, pas qu'une place a été inventée. Aucune métadonnée de marché absente n'est complétée.
- **Pourquoi :** deux instruments différents ne doivent pas être confondus, et un symbole seul ne suffit pas.
- **Conséquence :** `preparePurchaseValuation` refuse d'envoyer au calculateur des identifiants locaux distincts qui partageraient le même symbole et la même devise. Plusieurs achats du même identifiant restent agrégeables. Le futur cache pourra choisir une autre clé.

## ADR-018 — Base utilisateur SQLite version 1

- **Statut :** Implémentée **[DÉCIDÉ — FINDECK]**
- **Contexte :** les achats fictifs et les favoris devaient survivre à la fermeture du fichier, sans cache ni données de démonstration.
- **Décision :** le fichier normal est `findeck.db`, version 1, dans le répertoire persistant de sqflite. Les tables sont `user_asset`, `favorite` et `portfolio_purchase`. Les clés étrangères sont activées, sans suppression en cascade. Les dates sont des chaînes ISO 8601 UTC. Une écriture liée passe par une transaction, après la validation de `Purchase` pour un achat. Une version cible non prise en charge, une base plus récente et une migration inconnue sont refusées sans supprimer ni réécrire le fichier.
- **Pourquoi :** séparer les données utilisateur du futur cache, éviter une seconde source de vérité pour les résultats calculés, et rendre une évolution de schéma explicite.
- **Conséquence :** l'application ne crée pas encore cette base au démarrage. La collection, les gemmes et le cache restent hors de ce schéma. Les tests sur ordinateur passent par `sqflite_common_ffi`, uniquement en dépendance de développement, et écrivent un vrai fichier temporaire.

## Décisions en attente

- ADR futur : catalogue initial et catégories ;
- ADR futur : barème, probabilités et hasard des packs ;
- ADR futur : solde/acquisition des gemmes ;
- ADR futur : seuils de fraîcheur et rétention ;
- ADR futur : génération de code et modèles immuables, à reconsidérer avec le domaine ;
- ADR futur : langue définitive des écrans métier, charte graphique finale, maquettes de navigation ;
- Convention des branches de travail et numérotation des versions. Le dépôt public `kussYT/FinDeck` et la branche principale `main` sont définis dans [versioning.md](versioning.md).
