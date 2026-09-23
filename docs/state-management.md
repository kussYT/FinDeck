# Gestion des états avec Riverpod

## Choix

**[IMPOSÉ — SUJET]** Les traitements asynchrones doivent représenter les états initial, chargement, données, erreur et actualisation. Les états métier doivent également être explicites.

**[DÉCIDÉ — FINDECK]** Riverpod porte l'état de l'application. Les pages observent des providers et déclenchent leurs actions ; elles n'accèdent pas directement à Dio ou SQLite.

## États asynchrones

| État demandé | Représentation cible | Affichage attendu |
|---|---|---|
| Initial | provider non encore sollicité ou état métier initial explicite | écran neutre/placeholder utile |
| Loading | `AsyncLoading` sans données | indicateur ou squelette |
| Data | `AsyncData<T>` | contenu |
| Error | `AsyncError` sans repli disponible | message clair + réessayer |
| Refreshing | chargement avec données précédentes conservées | contenu visible + indicateur discret |

Ne pas remplacer l'écran complet par un spinner lors d'une simple actualisation si des données utilisables sont déjà présentes.

## États métier à représenter

- catalogue vide ou renseigné ;
- requête de recherche vide, en cours, sans résultat ou réussie ;
- actif favori ou non ;
- collection vide ou renseignée ;
- solde suffisant ou insuffisant pour un pack ;
- ouverture de pack inactive, en cours ou terminée ;
- portefeuille vide ou renseigné ;
- formulaire valide ou invalide ;
- cache frais, ancien ou absent ;
- données locales affichées après une erreur réseau.

## Providers cibles

Les noms sont indicatifs et pourront suivre les conventions exactes retenues au scaffold.

| Provider | Responsabilité |
|---|---|
| catalogue/recherche | charger et filtrer les actifs, gérer recherche et actualisation |
| détail d'actif paramétré par symbole | charger métadonnées, dernière valeur et historique |
| favoris | exposer l'ensemble local et basculer un favori |
| collection | exposer les cartes possédées |
| packs/profil | vérifier les gemmes, ouvrir un pack atomiquement, publier le résultat |
| portefeuille | gérer opérations, prix connus et résultats calculés |

## Flux d'une mutation

Exemple : ajouter un favori.

1. Le Widget déclenche `toggleFavorite(symbol)`.
2. Le notifier demande au repository de persister la nouvelle valeur.
3. Le repository écrit dans SQLite.
4. Le notifier publie l'état confirmé.
5. Les seuls widgets qui observent cette donnée sont reconstruits.
6. Une erreur d'écriture restaure ou conserve un état cohérent et affiche un message.

## Rebuild Flutter

Un rebuild réexécute `build`, pas la persistance ni les appels réseau par défaut. Les effets asynchrones et l'état durable vivent dans les providers/repositories. Les providers sont observés à la granularité utile pour éviter de reconstruire toute l'application lorsqu'un seul favori change.

## Cycle de vie

**[À DÉCIDER]** L'emploi de `autoDispose`, de familles de providers et de conservation temporaire sera décidé provider par provider. Les données durables restent dans SQLite ; conserver un provider en mémoire ne remplace jamais la persistance.

## Réalisé dans le socle

Seul `appRouterProvider` existe. Il expose le routeur de l'application et le libère à sa disposition. Aucun état asynchrone de catalogue, de collection ou de portefeuille n'est publié.
