# Stratégie de tests

## Priorité

**[IMPOSÉ — SUJET]** Des tests unitaires doivent porter sur la logique métier et ses cas limites.

**[DÉCIDÉ — FINDECK]** La priorité est de tester les services du domaine, puis les décisions de repository et enfin les états critiques. Les tests ne doivent pas dépendre d'une vraie clé API.

## Pyramide cible

| Niveau | Objet | Exemples |
|---|---|---|
| Unitaire — obligatoire | calculs purs | valeur, investi, gain, performance, répartition |
| Unitaire — important | mapping et validation | JSON valide/invalide, valeurs numériques en chaîne, formulaire |
| Unitaire — important | repository avec doublures | cache frais, cache absent, API en erreur, cache ancien |
| Widget — ciblé | rendu des états | loading, data, error, portefeuille vide |
| Intégration — ciblé | persistance et offline | redémarrage avec DB, transaction d'ouverture de pack |

## Matrice minimale des calculs

| Cas | Résultat attendu |
|---|---|
| 2 × 200, cours 227 | investi 400, valeur 454, gain 54, performance 13,5 % |
| valeur égale à l'investi | gain 0, performance 0 % |
| valeur inférieure | gain et performance négatifs |
| portefeuille vide | valeur 0 et aucune division |
| montant investi nul | performance indéfinie/erreur métier contrôlée |
| cours absent | résultat non calculable, jamais zéro inventé |
| plusieurs positions | somme correcte et poids cohérents |

## Matrice du repository

| Cache | Réseau/API | Attendu |
|---|---|---|
| frais | non nécessaire | cache retourné, pas d'appel inutile |
| absent | succès | API convertie, persistée et retournée |
| ancien | succès | données mises à jour |
| ancien | échec | ancien cache retourné avec statut stale |
| absent | échec | erreur typée et réessayable |
| présent | JSON invalide | cache conservé, erreur gérée |

## Persistance

- favori conservé après recréation du repository ;
- opération fictive conservée après redémarrage simulé ;
- clé unique d'historique empêche les doublons ;
- ouverture de pack : débit et cartes réussissent ensemble ou échouent ensemble ;
- migration conserve les données de la version précédente.

## Qualité des tests

- un test vérifie un comportement lisible ;
- noms en français ou anglais, mais cohérents dans tout le projet ;
- Arrange/Act/Assert visible ;
- horloge et hasard injectables lorsqu'ils influencent un résultat ;
- aucune attente arbitraire ni réseau réel ;
- couverture utile plutôt qu'objectif de pourcentage isolé.

## Critère de fin

Avant livraison : analyse statique sans erreur, formatage appliqué, tests verts et scénario offline manuel exécuté après fermeture complète. Les commandes exactes seront ajoutées lorsque le projet Flutter existera.
