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

Réalisé pour les achats fictifs et les favoris, sur un fichier SQLite réel :

- création de la base et version initiale ;
- relecture fidèle d'un achat, puis de plusieurs achats indépendants ;
- ajout, retrait et absence de doublon d'un favori ;
- refus d'une donnée invalide sans écriture ;
- clé étrangère : échec complet de la transaction et refus de supprimer une référence utilisée ;
- fermeture, puis réouverture du même fichier avec de nouvelles instances ;
- migration inconnue refusée sans suppression du fichier ;
- version cible inconnue refusée avant création du fichier ;
- base future, préparée hors de `AppDatabase`, refusée sans changer ses données ni son numéro ;
- création et réouverture normales en version 1.

Encore prévus : clé unique d'historique de marché, ouverture atomique d'un pack, et scénario hors ligne de l'application.

## Qualité des tests

- un test vérifie un comportement lisible ;
- noms en français ou anglais, mais cohérents dans tout le projet ;
- Arrange/Act/Assert visible ;
- horloge et hasard injectables lorsqu'ils influencent un résultat ;
- aucune attente arbitraire ni réseau réel ;
- couverture utile plutôt qu'objectif de pourcentage isolé.

## Critère de fin

Avant livraison : analyse statique sans erreur, formatage appliqué, tests verts et scénario offline manuel exécuté après fermeture complète.

## Commandes du socle

Vérifiées le 23 septembre 2026 avec Flutter 3.16.4 et Dart 3.2.3 :

```text
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/sqlite_android_probe_test.dart -d <id Android>
```

Lancement Android :

```text
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64
flutter devices
flutter run -d <id Android>
```

`flutter test` couvre le démarrage, la navigation, les cas limites de `PortfolioCalculator` et la conservation des achats et favoris dans un fichier temporaire. Le moteur SQLite de ces tests est `sqflite_common_ffi`, en dépendance de développement seulement. Le test `integration_test/sqlite_android_probe_test.dart` vérifie sqflite sur Android avec un fichier sonde distinct. Le 23 septembre 2026, il a réussi sur l'émulateur `emulator-5554`. Il ne prouve pas le mode hors ligne de l'application.
