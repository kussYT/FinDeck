# Exigences et traçabilité

Source normative : *Projet Flutter — Investment Companion*, année universitaire 2025-2026. Les numéros de section ci-dessous renvoient au PDF conservé dans `references/`.

## Contraintes imposées

| ID | Exigence **[IMPOSÉ — SUJET]** | Réponse cible FinDeck **[DÉCIDÉ]** | Preuve attendue | Réalisé |
|---|---|---|---|---|
| R01 | Au moins 3 écrans significatifs et navigation (§11) | Marché, Collection, Portefeuille, plus fiches et flux associés | Démonstration + routes | Non |
| R02 | Formulaire avec validation (§11) | Ajout d'une opération fictive : actif, quantité, prix, date | Tests de validation + démo | Non |
| R03 | Liste dynamique (§11) | Catalogue/recherche de marché ; favoris et collection sont aussi dynamiques | Démo avec données chargées | Non |
| R04 | API REST et JSON vers objets Dart (§4, §11) | Twelve Data derrière une source distante et des DTO | Test de mapping + appel contrôlé | Non |
| R05 | Persistance de données métier (§5, §11) | Favoris, collection, gemmes et portefeuille dans SQLite | Redémarrage de l'application | Partiel : achats fictifs et favoris relus depuis un fichier SQLite ; collection, gemmes et redémarrage de l'application non faits |
| R06 | Cache local de données API (§5, §11) | Actifs, dernières valeurs et historiques horodatés dans SQLite | Inspection DB + test repository | Non |
| R07 | Fonctionnement partiel hors connexion (§6, §11) | Repli sur cache avec date de dernière actualisation après fermeture complète | Scénario sans réseau | Non |
| R08 | États chargement, données et erreur (§7, §11) | Riverpod/AsyncValue et états métier explicites | Démo des différents états | Non |
| R09 | Visualisation graphique significative (§11) | Courbe historique et répartition du portefeuille | Démonstration | Non |
| R10 | Au moins 2 calculs métier (§8, §11) | Valeur, gain/perte, performance et répartition | Tests unitaires | Oui pour les formules ; affichage non fait |
| R11 | Au moins 3 animations, dont 2 codées (§10, §11) | Pack, favori, valeur de portefeuille ; comportements contrôlés | Code + démonstration | Non |
| R12 | Tests unitaires de logique métier (§13, §11) | Calculateurs financiers et cas limites | Résultat de `flutter test` | Oui pour les calculs et pour la relecture SQLite des achats et favoris |
| R13 | Séparation UI, état, métier, distant et local (§12) | Architecture en couches et repositories | Schéma + explication + code | Partiel : SQL limité à `data/local`, repositories séparés du domaine et des Widgets ; API et état Riverpod des données absents |

Au 23 septembre 2026, R10 est couvert pour les formules, sans affichage. R12 couvre aussi la conservation des achats et des favoris dans un fichier SQLite. R05 ne couvre ni la collection, ni les gemmes, ni le redémarrage de l'application. R01 reste non réalisé : les trois écrans sont encore provisoires. R13 est commencé par la séparation SQL / repository / domaine, sans source distante ni provider de données.

## Exigences transversales

| ID | Source | Attente | Décision/traitement |
|---|---|---|---|
| T01 | §2 | Proposition validée avant développement | [project-proposal.md](project-proposal.md) est prête ; validation externe encore requise. |
| T02 | §3 | Un catalogue initial de 30 instruments est possible, sans être une limite | Environ 30 actions + recherche API. Liste exacte **[À DÉCIDER]**. |
| T03 | §5 | Séparer données utilisateur et données Internet | Tables et responsabilités séparées dans [persistence.md](persistence.md). |
| T04 | §5 | Ne pas retélécharger sans raison ; expliquer invalidation/actualisation | Stratégie définie dans [data-flow.md](data-flow.md), seuils exacts **[À DÉCIDER]**. |
| T05 | §6 | Signaler une donnée potentiellement ancienne | Afficher date/heure de dernière actualisation et statut hors ligne. |
| T06 | §6 | Mode hors ligne testable après arrêt complet | Aucun cache uniquement en mémoire ; données nécessaires persistées. |
| T07 | §7 | États initial, chargement, données, erreur, actualisation | Modèle Riverpod détaillé dans [state-management.md](state-management.md). |
| T08 | §9 | Tout score/recommandation doit être explicable | Aucun scoring ou recommandation dans le périmètre actuel. |
| T09 | §14 | Rapport justifiant les choix | Les docs constituent la base ; captures et bilan réel seront ajoutés après implémentation. |
| T10 | §15 | Discussion technique et possibles modifications en direct | Révision et scénarios dans [soutenance.md](soutenance.md). |

## Matrice de périmètre

| Élément | Statut | Commentaire |
|---|---|---|
| Données quotidiennes/hebdomadaires acceptables | **[IMPOSÉ — SUJET]** | Le temps réel n'est pas requis. |
| Actions/entreprises réelles | **[DÉCIDÉ — FINDECK]** | Les ETF et cryptomonnaies ne font pas partie du périmètre initial. |
| Twelve Data | **[DÉCIDÉ — FINDECK]** | Faisabilité actuelle à revalider avant intégration. |
| Riverpod, GoRouter, Dio, sqflite, SharedPreferences, fl_chart | **[DÉCIDÉ — FINDECK]** | Riverpod 2.6.1, GoRouter 14.2.3 et sqflite 2.3.2 sont épinglés. Dio, SharedPreferences et fl_chart ne sont pas encore des dépendances. |
| Raretés Common/Rare/Epic/Legendary | **[DÉCIDÉ — FINDECK]** | Les probabilités et règles d'affectation restent ouvertes. |
| Nombre, contenu et prix des packs | **[À DÉCIDER]** | Les exemples précédents ne sont pas des spécifications. |
| Gains quotidiens, missions ou récompenses | **[À DÉCIDER]** | Aucune mécanique n'est validée ; ne pas implémenter. |
| Profil et paramètres avancés | **[À DÉCIDER]** | Non requis pour le MVP documenté. |
