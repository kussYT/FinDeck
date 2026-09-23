# Arborescence cible

**[DÉCIDÉ — FINDECK]** Cette arborescence décrit la cible de départ. Elle n'existe pas encore et ne doit pas être confondue avec l'état actuel du dossier.

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
