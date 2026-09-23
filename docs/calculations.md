# Calculs métier

**[IMPOSÉ — SUJET]** Au moins deux calculs métier significatifs et des tests unitaires sont requis.

**[DÉCIDÉ — FINDECK]** Les calculs ci-dessous vivent dans des services purs de `domain/services/`. Ils ne lisent ni l'API, ni SQLite, ni Riverpod et ne formatent pas l'interface.

## Réalisation au 23 septembre 2026

Les formules sont réalisées dans `PortfolioCalculator`. Il ne lit ni SQLite, ni l'API, ni l'écran. Un achat persisté ne l'atteint qu'après relecture et passage par `preparePurchaseValuation`. Les résultats calculés ne sont pas réécrits en base.

Le type numérique retenu est `double`. Il évite une dépendance supplémentaire et suffit aux quatre opérations des formules. Sa limite est le format binaire IEEE 754 : certains décimaux, comme 0,1 + 0,2, ne sont pas exacts. Les calculs ne rattrapent pas cet écart par un arrondi intermédiaire. L'arrondi d'affichage, en devise ou en pourcentage, reste hors du domaine et **[À DÉCIDER]** au moment des écrans.

Un résultat est un `CalculatedNumber` : soit `KnownNumber`, soit `UnavailableNumber` avec une raison. Zéro n'est utilisé que lorsqu'il est réellement connu, notamment pour un portefeuille vide ou un cours fourni à 0. Les raisons principales sont un cours absent, un cours invalide, une devise incompatible, des devises mixtes, une valorisation incomplète, un investi nul ou une valeur totale nulle. Une somme non finie, comme deux positions à `1e308` dans la même devise, rend la valorisation entière non calculable (`invalidInput`), même si un cours manque. Aucun infini n'est renvoyé comme montant connu. Les listes `positions`, `books` et `shares` sont des copies non modifiables.

Les achats d'un même symbole et d'une même devise sont agrégés. Le montant investi de chaque ligne est `quantité × prix unitaire`, puis les lignes sont sommées. Les devises différentes deviennent des sous-totaux séparés ; aucun total commun n'est produit et aucun taux de change n'est appliqué. Si une position d'une devise n'a pas de cours utilisable, le total de cette devise est incomplet : la somme des autres positions n'est pas présentée comme la valeur du groupe, et sa performance n'est pas calculée.

Le calculateur ne décide pas si un cours est ancien. Cette politique de fraîcheur reste **[À DÉCIDER]**.

## Formules retenues

### Montant investi

Pour chaque opération :

```text
montant investi = quantité × prix d'achat unitaire
```

Pour le portefeuille :

```text
montant total investi = Σ montants investis
```

### Valeur actuelle

```text
valeur actuelle d'une position = quantité totale × cours actuel
valeur du portefeuille = Σ valeurs actuelles des positions
```

### Plus-value ou moins-value

```text
gain/perte = valeur actuelle - montant investi
```

### Performance

```text
performance (%) = (gain/perte ÷ montant investi) × 100
```

Si le montant investi est nul, la performance est indéfinie : le domaine doit retourner un résultat explicite plutôt que diviser par zéro.

### Répartition

```text
poids (%) = valeur actuelle de l'élément ÷ valeur totale du portefeuille × 100
```

L'élément peut être un actif ou une catégorie selon le graphique choisi. Si la valeur totale est nulle, aucune répartition en pourcentage n'est calculable.

## Exemple de référence

Deux actions achetées 200 chacune et valant maintenant 227 :

```text
investi = 2 × 200 = 400
valeur actuelle = 2 × 227 = 454
gain = 454 - 400 = 54
performance = 54 ÷ 400 × 100 = 13,5 %
```

Cet exemple est couvert par `test/domain/portfolio_calculator_test.dart`.

## Règles de calcul

- ne pas arrondir les valeurs intermédiaires pour l'affichage ;
- séparer calcul et formatage de devise/pourcentage ;
- refuser les quantités et prix non finis, nuls ou négatifs pour un achat ;
- ne jamais substituer zéro à un cours manquant ;
- si une position ne peut pas être valorisée, signaler le résultat comme incomplet ; une somme partielle ne représente pas la valeur totale du portefeuille et ne permet pas d'afficher sa performance globale ;
- signaler un cours ancien lorsque la politique de fraîcheur sera décidée ; ce signal n'est pas encore calculé ;
- ne pas additionner sans explication des montants de devises différentes.

**[DÉCIDÉ — FINDECK]** Le calculateur sépare les sous-totaux par devise. Il n'additionne pas des devises différentes et n'applique pas de conversion.

**[À DÉCIDER]** La politique de fraîcheur déterminera quels cours anciens restent utilisables dans une valorisation.

## Cas limites à tester

- portefeuille vide ;
- une ou plusieurs positions ;
- montant investi nul ;
- cours actuel manquant ;
- quantité ou prix invalide ;
- gain positif, nul et négatif ;
- somme des poids proche de 100 % malgré la précision numérique ;
- historique vide ou dates incohérentes si une variation est ajoutée plus tard.

## Non retenu à ce stade

**[À DÉCIDER]** DCA, volatilité, drawdown, rendement composé, conversion de devise et score ne font pas partie des calculs engagés. Ils ne doivent pas être ajoutés uniquement parce qu'ils figurent comme exemples dans le sujet.
