# Risques et limites

## Registre des risques

| Risque | Impact | Réponse prévue | Statut |
|---|---|---|---|
| Quotas, endpoints ou offre Twelve Data modifiés | blocage du marché ou de l'historique | vérifier l'offre avant intégration, limiter les appels, isoler le fournisseur | À surveiller |
| Clé API exposée dans l'application mobile | utilisation abusive possible | ne pas la committer, limiter la clé si possible, expliquer la limite sans backend | Accepté pour V1 |
| Données manquantes/incohérentes | graphique ou calcul faux | validation DTO, erreurs typées, ne jamais inventer zéro | À tester |
| Cache trop ancien | utilisateur induit en erreur | horodatage visible, statut stale/offline, actualisation manuelle | Traité par conception |
| Cache seulement en mémoire | échec du test après redémarrage | persistance SQLite de tout le contenu offline nécessaire | Traité par conception |
| Cours bruts non ajustés | performance historique trompeuse après split/dividende | identifier le type de série et documenter la limite | À vérifier API |
| Plusieurs devises additionnées | total sans sens | afficher la devise et ne pas agréger sans conversion | Hors périmètre conversion |
| Double achat de pack | perte de gemmes ou duplication | transaction atomique et verrou pendant l'action | À tester |
| Rareté perçue comme conseil financier | mauvaise interprétation pédagogique | séparer rareté et données de marché, avertissement clair | Traité par conception |
| Hasard de pack non défini | comportement impossible à expliquer/tester | valider probabilités et graine injectable avant implémentation | Décision bloquante phase 5 |
| Abstractions trop nombreuses ou mal justifiées | code difficile à comprendre et à maintenir | phases courtes, revue des responsabilités et documentation à jour | Processus |
| Périmètre trop large | retard et qualité insuffisante | prioriser exigences, ne pas ajouter de features hors scope | Processus |

## Limites assumées de la V1

**[DÉCIDÉ — FINDECK]**

- application locale mono-utilisateur ;
- aucune synchronisation, restauration cloud ou multi-appareil ;
- aucune transaction ni monnaie réelle ;
- données pas nécessairement temps réel ;
- aucune prédiction, recommandation ou garantie de performance ;
- aucune conversion automatique de devises ;
- aucune vente fictive engagée à ce stade ;
- couverture d'actifs limitée au catalogue et aux résultats compatibles de l'API ;
- précision dépendante de la qualité et de la nature brute/ajustée des données reçues.

## Données et licences

Avant livraison, vérifier les conditions d'utilisation de l'API, les obligations d'attribution, la durée de cache autorisée et le droit d'afficher logos ou marques. Si aucune source autorisée ne fournit un logo, utiliser une présentation textuelle plutôt que récupérer une image arbitraire.

## Avertissement pédagogique

L'interface et le rapport doivent préciser que FinDeck est une simulation pédagogique, que les performances passées ne préjugent pas des performances futures et qu'aucune carte, rareté ou animation n'est un conseil d'investissement.
