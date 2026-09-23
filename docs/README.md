# Documentation FinDeck

Ce dossier rassemble le cadrage fonctionnel et technique de FinDeck, les choix de conception et les critères de validation. Il sert de référence pendant le développement et de base au rapport et à la soutenance.

> État du projet au 23 septembre 2026 : le socle Flutter est lançable. Il affiche une navigation provisoire entre Marché, Collection et Portefeuille, sans données de marché, persistance, packs ni calculs. Le reste de ce dossier décrit encore une **cible**, pas une fonctionnalité réalisée.

## Légende de décision

Chaque document distingue trois niveaux :

- **[IMPOSÉ — SUJET]** : exigence explicite du cahier des charges *Projet Flutter — Investment Companion*.
- **[DÉCIDÉ — FINDECK]** : choix retenu pour FinDeck dans le cadrage du projet.
- **[À DÉCIDER]** : détail non validé qui ne doit pas être inventé par l'implémentation.

En cas de contradiction, le cahier des charges prévaut. Une décision FinDeck peut évoluer, mais sa modification doit être consignée dans [decisions.md](decisions.md) et répercutée dans les documents concernés.

## Résumé du périmètre

FinDeck est une application mobile pédagogique et gamifiée pour débutants. Elle permet d'explorer de vraies entreprises et actions, de suivre des favoris, de consulter des cours et historiques, de collectionner des cartes obtenues dans des packs achetés avec des gemmes virtuelles et de gérer un portefeuille fictif. Les données de marché proviennent d'une API, sont mises en cache localement et restent partiellement consultables hors connexion.

FinDeck ne permet ni investissement réel, ni paiement réel, ni connexion bancaire ou à un courtier. La rareté d'une carte est une mécanique de collection et ne représente jamais la qualité d'un investissement.

## Ordre de lecture recommandé

1. [project-proposal.md](project-proposal.md) — proposition synthétique demandée avant développement.
2. [vision.md](vision.md) — concept, cible et limites fonctionnelles.
3. [requirements-traceability.md](requirements-traceability.md) — exigences du sujet et preuve attendue.
4. [architecture.md](architecture.md) puis [target-tree.md](target-tree.md) — architecture cible et responsabilités.
5. [domain-model.md](domain-model.md), [persistence.md](persistence.md), [api.md](api.md) et [data-flow.md](data-flow.md) — modèles et données.
6. [state-management.md](state-management.md), [navigation.md](navigation.md), [calculations.md](calculations.md) et [animations.md](animations.md) — comportement de l'application.
7. [testing.md](testing.md), [conventions.md](conventions.md) et [roadmap.md](roadmap.md) — règles de réalisation.
8. [decisions.md](decisions.md), [risks-and-limits.md](risks-and-limits.md) et [glossary.md](glossary.md) — justification et vocabulaire.
9. [soutenance.md](soutenance.md) — fiche de révision et questions/réponses.
10. [development-guide.md](development-guide.md) — règles de travail à consulter avant chaque phase.
11. [versioning.md](versioning.md) — jalons, commits, vérifications et publication sur GitHub.

Le cahier des charges original est conservé dans `references/Projet_Flutter_Investment_Companion.pdf`.

## Règle de mise à jour

Après chaque phase, mettre à jour :

- la colonne « réalisé » de la traçabilité ;
- les décisions réellement prises ;
- les schémas si les responsabilités changent ;
- la FAQ de soutenance avec l'implémentation réelle ;
- les risques et limites observés.

La documentation ne doit jamais présenter une intention comme une réalisation.
