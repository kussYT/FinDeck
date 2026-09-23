# Calculs métier

**[IMPOSÉ — SUJET]** Au moins deux calculs métier significatifs et des tests unitaires sont requis.

**[DÉCIDÉ — FINDECK]** Les calculs ci-dessous vivent dans des services purs de `domain/services/`. Ils ne lisent ni l'API, ni SQLite, ni Riverpod et ne formatent pas l'interface.

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

Cet exemple doit apparaître dans les tests afin de relier documentation, code et soutenance.

## Règles de calcul

- ne pas arrondir les valeurs intermédiaires pour l'affichage ;
- séparer calcul et formatage de devise/pourcentage ;
- refuser les quantités et prix non finis, nuls ou négatifs pour un achat ;
- ne jamais substituer zéro à un cours manquant ;
- si une position ne peut pas être valorisée, signaler le résultat comme incomplet ; une somme partielle ne représente pas la valeur totale du portefeuille et ne permet pas d'afficher sa performance globale ;
- signaler si une valeur de portefeuille repose sur un cours ancien ;
- ne pas additionner sans explication des montants de devises différentes.

**[À DÉCIDER]** Avant le portefeuille, choisir entre un périmètre à devise unique et des sous-totaux séparés par devise. Cette décision n'ajoute pas de conversion de change. La politique de fraîcheur déterminera également quels cours anciens restent utilisables dans une valorisation.

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
