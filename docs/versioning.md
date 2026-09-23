# Versions et méthode de travail

**[DÉCIDÉ — FINDECK]** Le projet sera développé et publié progressivement sur GitHub. Chaque étape doit correspondre à un résultat identifiable, vérifié et explicable.

## État initial

À la date de cette revue, le dossier contient la documentation et les fichiers de l'environnement de développement. Git n'est pas encore initialisé et aucun dépôt GitHub distant n'est configuré. Le code Flutter reste à créer.

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
6. Enregistrer un commit cohérent, puis publier sur le dépôt GitHub prévu.

Les règles des packs ne bloquent pas la navigation ; elles doivent être validées avant les tirages et débits de gemmes. De même, l'API peut être vérifiée au moment du jalon Marché.

## Configuration de GitHub

Avant la première publication, préciser le dépôt cible et sa visibilité. Utiliser l'identité Git de l'auteur du travail et conserver les fichiers de configuration locale, secrets et sorties de compilation hors du suivi. Ne pas créer de dépôt distant ou choisir sa visibilité implicitement.

**[À DÉCIDER]** URL du dépôt, visibilité, identité Git si elle n'est pas configurée, convention de branches et numérotation des versions. Pour un travail individuel, une branche principale stable et des branches courtes par changement suffisent ; une organisation plus complexe doit répondre à un besoin réel.
