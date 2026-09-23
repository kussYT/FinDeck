# Arborescence cible

**[DÉCIDÉ — FINDECK]** Cette arborescence reste la cible. Elle ne doit pas être confondue avec les fichiers réellement créés.

## État réel

Au 23 septembre 2026, le socle et les calculs existent. `core/`, `data/` et les fonctionnalités encore vides ne sont pas créés.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── provisional_section_page.dart
│   ├── router.dart
│   ├── shell.dart
│   └── theme.dart
├── domain/
│   ├── models/
│   │   ├── calculated_number.dart
│   │   ├── market_quote.dart
│   │   ├── portfolio_valuation.dart
│   │   └── purchase.dart
│   └── services/
│       └── portfolio_calculator.dart
└── features/
    ├── collection/collection_page.dart
    ├── market/market_page.dart
    └── portfolio/portfolio_page.dart
test/
├── app/navigation_test.dart
└── domain/portfolio_calculator_test.dart
```

## Cible

```text
FinDeck/
├── docs/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   └── utils/
│   ├── domain/
│   │   ├── models/
│   │   └── services/
│   ├── data/
│   │   ├── remote/
│   │   │   └── dto/
│   │   ├── local/
│   │   │   └── dao/
│   │   ├── mappers/
│   │   └── repositories/
│   └── features/
│       ├── market/
│       ├── asset_detail/
│       ├── favorites/
│       ├── collection/
│       ├── packs/
│       └── portfolio/
├── test/
│   ├── domain/
│   ├── data/
│   └── features/
└── pubspec.yaml
```

## Règles de placement

- Un fichier utilisé par une seule fonctionnalité reste dans cette fonctionnalité.
- Un calcul financier va dans `domain/services/`, jamais dans un Widget.
- Un modèle du domaine ne contient pas de logique SQL ou JSON.
- Un DTO externe reste dans `data/remote/dto/` et est converti vers un modèle du domaine.
- Une requête SQL reste dans `data/local/dao/`.
- Un repository coordonne les sources ; il ne contient pas de présentation.
- `core/` n'est pas un dossier « divers » : un élément n'y entre que s'il est réellement partagé.

## Découpage interne d'une feature

Selon sa taille, une fonctionnalité peut contenir :

```text
feature_name/
├── presentation/
│   ├── pages/
│   └── widgets/
└── providers/
```

**[À DÉCIDER]** Ne pas créer automatiquement tous ces sous-dossiers s'ils resteraient vides. Le découpage doit suivre le code réel, pas anticiper des abstractions inutiles.
