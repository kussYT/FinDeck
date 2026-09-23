# Guide de développement

Ce guide résume le périmètre, l'architecture et les critères de validation à respecter pendant le développement. Les documents thématiques détaillent chaque choix.

## Avant toute modification

1. Lire `docs/README.md` et les documents liés à la phase demandée.
2. Vérifier `docs/requirements-traceability.md`.
3. Ne traiter qu'une phase de `docs/roadmap.md` à la fois.
4. Signaler toute contradiction ou décision marquée **[À DÉCIDER]** avant de l'implémenter.
5. Ne jamais présenter un élément comme réalisé avant que le code et les tests existent.

## Contexte fonctionnel immuable sans nouvelle décision

FinDeck est une application Flutter pédagogique et gamifiée pour débutants. Elle utilise de vraies entreprises/actions et données de marché, mais aucune transaction ni monnaie réelle. Les cartes, raretés, packs et gemmes appartiennent à la collection ; le portefeuille est une simulation distincte. La rareté n'est jamais un signal financier.

Le périmètre engagé comprend Marché, fiche/historique, favoris, Collection, packs/gemmes, Portefeuille fictif, graphiques, cache/offline, calculs, animations et tests. N'ajouter ni authentification, backend, social, classement, scoring, prédiction, paiement, vente fictive ou autre fonctionnalité non validée.

## Architecture à respecter

```text
Widget
  -> Provider Riverpod
    -> Repository
      -> source distante Dio / Twelve Data
      -> source locale SQLite
    -> service de calcul du domaine
```

- pas d'appel API ou SQL depuis un Widget ;
- pas de calcul financier dans l'UI ;
- le repository décide API/cache/offline ;
- DTO externes séparés des modèles du domaine ;
- données utilisateur séparées du cache API ;
- tout état asynchrone couvre loading, data, error et refreshing ;
- code simple, testable et explicable en soutenance.

## Stack retenue

Flutter/Dart, Riverpod, GoRouter, Dio, SQLite avec sqflite, SharedPreferences pour petites préférences, fl_chart et flutter_test. Les versions et éventuels générateurs de code ne sont pas encore décidés.

## Décisions à valider

Les éléments suivants demandent une décision explicite avant la fonctionnalité concernée : liste finale d'actifs, catégories finales, prix/composition/probabilités des packs, solde initial ou mécanisme d'obtention des gemmes, seuils de cache, contrat API, langue et charte finale.

## Travail par jalons

Le développement suit les phases de [roadmap.md](roadmap.md). Chaque changement cohérent est vérifié puis enregistré dans Git. Les jalons prêts à être montrés sont publiés sur GitHub selon [versioning.md](versioning.md).

## Définition de terminé pour une phase

- code formaté et analysé ;
- tests pertinents verts ;
- scénario manuel vérifié ;
- documentation et traçabilité mises à jour ;
- aucune décision implicite restée cachée dans le code.
