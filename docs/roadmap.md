# Roadmap de développement

La roadmap ordonne le travail sans prétendre que les phases sont déjà réalisées. Chaque phase se termine par une vérification et une mise à jour de la documentation.

## Phase 0 — Cadrage

- faire valider la proposition de concept ;
- identifier les décisions à trancher avant chaque fonctionnalité : API et catalogue avant la phase 3, règles des packs et gemmes avant la phase 5 ;
- relire la traçabilité ;
- figer le premier périmètre démontrable.

**Sortie :** concept validé et périmètre du socle défini. La validation pédagogique n'est pas encore consignée dans ces documents. Les détails de l'API et des packs ne bloquent pas la création du socle.

## Phase 1 — Scaffold Flutter

- créer le projet Flutter et Git ;
- ajouter uniquement les dépendances nécessaires au socle ;
- créer `app`, `core`, `domain`, `data`, `features` ;
- configurer Riverpod, GoRouter et le thème ;
- afficher le shell vide Marché/Collection/Portefeuille.

**Sortie :** application lançable, navigation minimale, aucun métier inventé.

## Phase 2 — Domaine et persistance

- créer les modèles validés et services de calcul ;
- définir la base SQLite versionnée et ses DAO ;
- préparer les structures de persistance pour les favoris, la collection et les opérations ; initialiser les gemmes seulement après validation de leur règle ;
- écrire les premiers tests de calcul et de persistance.

**Sortie :** données utilisateur conservées après redémarrage.

## Phase 3 — Marché, API et cache

- valider le contrat Twelve Data et la clé locale ;
- implémenter DTO, mapping, source distante et repository ;
- construire catalogue/recherche, fiche et historique ;
- ajouter cache, fraîcheur, actualisation et erreurs ;
- ajouter le graphique d'historique.

**Sortie :** parcours Marché fonctionnel en ligne puis sur cache.

## Phase 4 — Favoris

- ajouter/retrait persistant ;
- liste ou filtre de favoris ;
- animation contrôlée ;
- tests d'état et de persistance.

**Sortie :** favori conservé après redémarrage.

## Phase 5 — Collection, packs et gemmes

- n'implémenter qu'après validation du barème et des probabilités ;
- créer collection et affichage des raretés ;
- réaliser l'ouverture atomique d'un pack ;
- intégrer l'animation de révélation et prévenir les doubles achats.

**Sortie :** débit et cartes cohérents, y compris si l'animation est interrompue.

## Phase 6 — Portefeuille fictif

- formulaire validé d'achat fictif ;
- positions dérivées des opérations ;
- valeur, gain/perte, performance et répartition ;
- graphique de répartition et animation de valeur ;
- tests des cas limites.

**Sortie :** calculs traçables, testés et explicables.

## Phase 7 — Offline et robustesse

- tester après fermeture complète et réseau coupé ;
- afficher fraîcheur/dernière actualisation ;
- gérer cache absent, cache ancien, quota et JSON invalide ;
- vérifier migrations et transactions locales.

**Sortie :** scénario offline de [data-flow.md](data-flow.md) validé.

## Phase 8 — Qualité et livraison

- accessibilité, états vides, responsive et polish ;
- analyse statique, formatage et tests ;
- captures, limites réelles et rapport ;
- répétition de démonstration et questions de soutenance.

**Sortie :** toutes les lignes de traçabilité ont une preuve ou un écart justifié.

## Règle de progression

Ne pas développer plusieurs features complètes d'un seul coup. Une phase n'est terminée que si le code, les tests, la documentation et la compréhension pour la soutenance concordent.

Les jalons et la méthode de publication sont décrits dans [versioning.md](versioning.md). Les tests et le comportement hors ligne se vérifient dès les fonctionnalités concernées ; la phase 7 sert à contrôler leur fonctionnement ensemble.
