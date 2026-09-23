# Versions et méthode de travail

**[DÉCIDÉ — FINDECK]** Le projet sera développé et publié progressivement sur GitHub. Chaque étape doit correspondre à un résultat identifiable, vérifié et explicable.

## État au 23 septembre 2026

La branche principale est `main`. Le dépôt distant `origin` pointe vers le dépôt public [kussYT/FinDeck](https://github.com/kussYT/FinDeck). L'identité d'auteur provient de la configuration globale déjà présente. Aucun tag de livraison n'est posé.

Le cadrage documentaire et le socle Flutter sont deux commits distincts. Le socle a été vérifié par le formatage, l'analyse statique, les tests de démarrage et de navigation, puis un lancement sur l'émulateur Android Pixel 3a API 34. `flutter doctor` signale toutefois l'absence des cmdline-tools Android et un statut de licences inconnu ; cet avertissement n'a pas empêché ce lancement. Aucun appareil physique n'était connecté.

## Jalons de publication

Ces jalons sont prévisionnels. Un jalon peut comprendre plusieurs commits ; un changement de documentation ou une correction ne justifie pas à lui seul une nouvelle version de l'application.

| Jalon | Contenu | Vérification avant publication |
|---|---|---|
| Cadrage | concept, exigences, architecture et décisions ouvertes | cohérence documentaire et liens internes |
| Socle | démarrage Flutter, thème provisoire, Riverpod et navigation | analyse, test de navigation et lancement sur Android |
| Domaine et stockage | modèles utiles, premiers calculs et persistance versionnée | cas limites des calculs et relecture des données persistées |
| Marché | API, mapping, historique, graphique et cache | chargement réel, erreurs et repli sur cache |
| Favoris | ajout/retrait persistant et animation | conservation après redémarrage |
| Collection | cartes, gemmes, ouverture de pack après validation des règles | transaction atomique et double déclenchement |
| Portefeuille | formulaire, positions, résultats et répartition | validation, calculs et traitement des cours manquants |
| Livraison | parcours complets, offline, présentation et rapport | critères du sujet, démonstration et limites documentées |

Les numéros de version et les tags seront fixés lorsque des versions exécutables seront effectivement prêtes. Aucun tag de livraison n'est créé pour une fonctionnalité encore prévue.

## Commits

Les commits et les push sont exécutés manuellement par Marius, sauf demande explicite pour une opération précise. À la fin d'une étape de développement, laisser les modifications disponibles pour revue et proposer un message de commit. La fin d'une phase n'autorise pas une publication automatique. Un push reste une action distincte d'un commit local.

Un commit regroupe une intention cohérente : une fonctionnalité avec ses tests, une correction, ou une mise à jour documentaire. Éviter les commits mélangeant une réorganisation générale avec un changement de comportement.

Exemples de messages à adapter aux changements réellement réalisés :

- `docs: cadrer le concept et l'architecture de FinDeck`
- `chore: initialiser le projet Flutter`
- `feat: ajouter la navigation principale`
- `test: couvrir les cas limites de valorisation`
- `fix: conserver le cache après un échec réseau`

Les dates et les auteurs correspondent au travail effectué. Ne pas antidater les commits ni découper artificiellement une application terminée pour simuler plusieurs semaines de développement.

## Cycle d'une étape

1. Choisir une tâche de la roadmap avec un résultat vérifiable.
2. Consulter les documents correspondants et résoudre les décisions nécessaires à cette tâche.
3. Réaliser le changement, puis examiner les fichiers modifiés.
4. Exécuter les vérifications pertinentes. Dès que le socle existe : formatage, analyse statique, tests et essai du parcours modifié.
5. Mettre à jour la documentation selon le résultat obtenu.
6. Présenter les changements et les vérifications à Marius, qui effectue le commit et le push manuellement après sa revue.

Les règles des packs ne bloquent pas la navigation ; elles doivent être validées avant les tirages et débits de gemmes. De même, l'API peut être vérifiée au moment du jalon Marché.

## Configuration de GitHub

Le dépôt est public et sa branche principale est `main`. Utiliser l'identité Git de l'auteur du travail et conserver les fichiers de configuration locale, secrets et sorties de compilation hors du suivi.

**[À DÉCIDER]** Convention des branches de travail et numérotation des versions. L'identité Git globale est déjà configurée. La valeur `1.0.0+1` de `pubspec.yaml` est celle générée par Flutter ; elle n'est pas une version publiée. Pour un travail individuel, une branche principale stable et des branches courtes par changement suffisent ; une organisation plus complexe doit répondre à un besoin réel.
