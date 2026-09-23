# Stratégie API

## Fournisseur

**[DÉCIDÉ — FINDECK]** Twelve Data est le fournisseur principal envisagé pour les actions. Les capacités recherchées sont : recherche de symboles, liste/référence d'actions, cotation et série temporelle.

**[IMPOSÉ — SUJET]** Les offres et limitations évoluent et doivent être revérifiées avant le démarrage. Par conséquent, aucun endpoint, quota ou champ n'est garanti par ce document.

## Validation préalable obligatoire

Avant d'écrire l'intégration :

1. consulter la documentation officielle actuelle ;
2. confirmer les endpoints disponibles avec le plan utilisé ;
3. confirmer les marchés, symboles, intervalles et profondeurs d'historique ;
4. relever les codes d'erreur et réponses de quota ;
5. confirmer les conditions d'affichage, d'attribution et de cache ;
6. tester quelques symboles du catalogue initial ;
7. documenter les champs absents ou inconsistants.

## Chaîne de conversion

```text
Réponse HTTP JSON
  -> DTO spécifique à Twelve Data
  -> validation/mapping
  -> modèle de domaine Asset ou PricePoint
  -> cache SQLite
  -> provider Riverpod
  -> Widget
```

Le DTO peut refléter des nombres reçus sous forme de chaîne ; le modèle du domaine expose des valeurs déjà validées. Un champ obligatoire invalide produit une erreur de parsing contrôlée, pas une valeur financière silencieusement inventée.

## Données minimales attendues

| Usage | Données nécessaires |
|---|---|
| Catalogue/recherche | symbole, nom, place de cotation et devise si disponibles |
| Fiche actif | identité de l'actif et dernière valeur connue |
| Graphique | date et clôture ; OHLCV conservé lorsque fourni |
| Portefeuille | dernier cours utilisable et son horodatage |

La catégorie/secteur et le logo ne doivent être affichés comme données réelles que si une source autorisée les fournit ou si un catalogue local validé les contient.

## Robustesse

- timeouts réseau explicites ;
- gestion distincte des erreurs de connexion, HTTP, quota, parsing et données vides ;
- nombre de tentatives limité ;
- pas de boucle de retry automatique agressive ;
- limitation/débounce de la recherche ;
- cache consulté avant une requête redondante ;
- historique mis à jour par plage manquante si le fournisseur le permet ;
- cache existant conservé lors d'une réponse en erreur.

## Clé API

La clé ne doit jamais être commitée dans Git ni inscrite directement dans un Widget. La méthode d'injection locale sera choisie au scaffold et documentée. Une clé incluse dans une application mobile reste techniquement extractible ; sans backend, cette limite doit être assumée dans le rapport.

## Couplage au fournisseur

Seuls la source distante, ses DTO et ses mappers connaissent les noms de champs Twelve Data. Le repository et le reste de l'application manipulent des modèles du domaine. Un changement de fournisseur ne doit pas modifier les pages ni les calculs.

## Décisions ouvertes

**[À DÉCIDER]**

- endpoints et paramètres exacts après validation officielle ;
- fréquence et seuils de rafraîchissement ;
- stratégie précise de pagination/recherche ;
- traitement des fuseaux horaires des marchés ;
- catalogue local de secours ;
- politique pour les cours ajustés ou bruts, à documenter selon la réponse disponible.
