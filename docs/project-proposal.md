# Proposition de concept — FinDeck

Ce document répond à la proposition d'une page demandée avant le développement dans la section 2 du cahier des charges.

## Problème et utilisateur cible

**[IMPOSÉ — SUJET]** L'application doit aider un novice à faire ses premiers pas dans l'investissement en apprenant par l'interaction avec des données, sans transaction financière réelle.

**[DÉCIDÉ — FINDECK]** FinDeck s'adresse à une personne débutante qui trouve les notions de marché abstraites. L'application rend la découverte plus accessible par une collection de cartes représentant de vraies entreprises et par un portefeuille entièrement fictif.

## Fonctionnalités principales envisagées

**[DÉCIDÉ — FINDECK]**

- catalogue initial d'environ 30 entreprises/actions réelles et recherche d'actifs via l'API ;
- fiche d'un actif avec données de marché, historique et graphique ;
- favoris persistés localement ;
- cartes à collectionner, séparées des actifs financiers, avec catégories et raretés ;
- packs de cartes achetés uniquement avec des gemmes virtuelles ;
- portefeuille fictif avec saisie validée des achats ;
- valeur actuelle, montant investi, gain/perte, performance et répartition ;
- cache local, indication de dernière actualisation et consultation dégradée hors ligne.

**[À DÉCIDER]** Le barème des packs, les probabilités de rareté, le solde initial et le mécanisme d'obtention des gemmes ne sont pas définis. Ils ne doivent pas être inventés pendant le développement.

## Données externes et API

**[IMPOSÉ — SUJET]** Au moins une API REST externe et une conversion JSON vers des objets Dart sont requises.

**[DÉCIDÉ — FINDECK]** Twelve Data est le fournisseur principal envisagé pour la recherche de symboles, les cotations et les séries historiques. Dio sera utilisé pour HTTP. Les écrans ne connaîtront jamais directement le fournisseur : un repository fera l'intermédiaire.

**[À DÉCIDER]** Avant l'intégration, vérifier dans la documentation officielle actuelle les endpoints, champs, quotas, conditions d'utilisation et contraintes de clé API. Aucun quota précis n'est considéré acquis dans cette documentation.

## Données conservées localement

**[DÉCIDÉ — FINDECK]**

- données utilisateur : favoris, cartes possédées, gemmes, opérations du portefeuille fictif ;
- cache API : métadonnées d'actifs, dernières valeurs connues, historiques de prix et date/heure d'actualisation ;
- préférences légères si elles deviennent nécessaires à l'interface.

SQLite avec `sqflite` est destiné aux données structurées ; `SharedPreferences` est réservé aux petites préférences, pas aux données métier principales.

## Principaux états

**[IMPOSÉ — SUJET]** État initial, chargement, données disponibles, erreur et actualisation doivent être représentés, ainsi que les états métier pertinents.

**[DÉCIDÉ — FINDECK]** Riverpod gérera notamment : catalogue chargé ou vide, actif favori ou non, collection vide ou renseignée, gemmes suffisantes ou insuffisantes, portefeuille vide ou renseigné, données fraîches ou anciennes et erreur réseau avec repli local.

## Calculs métier

**[DÉCIDÉ — FINDECK]** Les calculs indépendants de l'interface couvriront au minimum la valeur du portefeuille, le montant investi, la plus-value/moins-value, la performance en pourcentage et la répartition par actif ou catégorie. Les formules sont détaillées dans [calculations.md](calculations.md).

## Animations et visualisations

**[DÉCIDÉ — FINDECK]**

- graphique d'historique du prix d'un actif ;
- graphique de répartition du portefeuille ;
- ouverture de pack contrôlée par le code ;
- ajout/retrait d'un favori contrôlé par le code ;
- transition animée de la valeur du portefeuille contrôlée par le code.

Les durées, courbes et détails visuels restent à régler après les premiers prototypes.
