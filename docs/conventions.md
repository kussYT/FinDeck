# Conventions de code et de documentation

## Principes

**[DÉCIDÉ — FINDECK]**

- privilégier un code simple, lisible et explicable en soutenance ;
- une responsabilité principale par fichier ;
- aucune logique métier substantielle dans `build` ;
- aucun accès HTTP ou SQL depuis un Widget ;
- aucune abstraction sans usage concret ;
- préférer les objets immuables pour les états et modèles ;
- traiter explicitement les erreurs et valeurs manquantes.

## Nommage Dart

- fichiers et dossiers : `snake_case` ;
- classes, enums et typedefs : `UpperCamelCase` ;
- variables, méthodes et providers : `lowerCamelCase` ;
- constantes : conventions Dart standard, sans préfixe global arbitraire ;
- suffixes explicites : `Dto`, `Repository`, `Dao`, `Page`, `Notifier` selon le rôle réel.

## Modèles et données

- les DTO reflètent le contrat externe ;
- les modèles du domaine n'exposent pas les particularités JSON/SQL ;
- les conversions sont centralisées dans des mappers ;
- les dates techniques et dates de marché restent distinctes ;
- les symboles sont normalisés avant comparaison ;
- les montants ne sont arrondis que pour l'affichage ;
- une devise doit accompagner toute valeur monétaire affichée.

## Asynchrone et états

- tout `Future` important est attendu ou explicitement géré ;
- loading, error, data et refreshing sont distingués ;
- une erreur technique est transformée en erreur applicative compréhensible ;
- ne pas vider des données valides pendant une actualisation ;
- éviter les appels réseau causés par chaque rebuild.

## Widgets

- extraire un widget lorsqu'il a une responsabilité ou une réutilisation claire ;
- préférer `const` lorsqu'il est réellement possible ;
- ne pas stocker dans un Widget un état qui appartient à l'application ;
- conserver localement uniquement les états éphémères de présentation.

## Commentaires

Les commentaires expliquent le « pourquoi », une contrainte externe ou un compromis. Ils ne paraphrasent pas une ligne évidente. Chaque couche importante est documentée, mais tous les fichiers n'ont pas besoin d'un commentaire artificiel.

## Dépendances et secrets

- ajouter une dépendance seulement pour un besoin identifié ;
- consigner son rôle dans la décision correspondante ;
- épingler des versions compatibles au moment du scaffold ;
- ne jamais committer une clé API ou un fichier local de secrets ;
- ne jamais loguer la clé ou des réponses sensibles.

## Documentation

- utiliser la légende **IMPOSÉ / DÉCIDÉ / À DÉCIDER** ;
- mettre à jour la traçabilité après chaque phase ;
- ne jamais écrire « implémenté » sans preuve ;
- garder les diagrammes Mermaid synchronisés avec le code ;
- noter les écarts entre cible et réalisation dans le rapport.

## Qualité de l'interface

- définir une palette, une échelle typographique et des espacements cohérents avant de détailler les écrans ;
- réutiliser ces choix dans le thème et les composants partagés ;
- privilégier la lisibilité des prix, dates, devises et états d'erreur ;
- réserver les effets visuels aux actions où ils apportent un retour utile ;
- vérifier chaque parcours sur l'émulateur, avec les états vide, chargé et en erreur ;
- faire évoluer le rendu à partir de ces vérifications, avec des changements limités et motivés.

La direction graphique définitive reste à valider. Le premier socle sert à vérifier la navigation et la structure des écrans.

## Langue

**[DÉCIDÉ — FINDECK]** Les identifiants techniques sont en anglais. Les textes du socle sont en français, comme la documentation.

**[À DÉCIDER]** La langue définitive des futurs écrans métier reste à confirmer avant leur rédaction.
