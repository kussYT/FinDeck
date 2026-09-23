# FinDeck

Application Flutter pédagogique. Le cadrage fonctionnel et technique est dans [docs/README.md](docs/README.md).

Au 23 septembre 2026, le socle démarre et permet de naviguer entre Marché, Collection et Portefeuille. Ces écrans indiquent que leur contenu n'est pas encore développé. Il n'y a pas de données de marché, de persistance, de packs ni de calculs.

## Lancer

```text
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64
flutter devices
flutter run -d <id Android>
```

## Vérifier

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```
