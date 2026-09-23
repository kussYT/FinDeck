# Soutenance — fiche de révision

> Ce document décrit l'architecture cible avant développement. Après chaque phase, remplacer les formulations futures par la réalité vérifiée et ajouter les difficultés effectivement rencontrées.

## Présentation en 60 secondes

FinDeck est une application Flutter pédagogique et gamifiée destinée aux débutants en investissement. Elle permet d'explorer de vraies entreprises et leurs données de marché, de suivre des favoris, de collectionner des cartes avec des raretés, d'ouvrir des packs avec des gemmes virtuelles et de gérer un portefeuille fictif. L'application ne permet aucun investissement réel. Elle utilise une architecture en couches : les Widgets affichent l'état fourni par Riverpod ; les providers orchestrent les actions ; les repositories choisissent entre l'API Twelve Data et le cache SQLite ; les calculs financiers sont isolés dans le domaine et testés unitairement. Les données utilisateur sont persistées séparément du cache. Sans réseau, l'application affiche les dernières données disponibles avec leur date de mise à jour.

## Schéma à savoir refaire

```text
UI Flutter
    ↓ observe / déclenche
Riverpod
    ↓ orchestre
Repository ─────────→ Services métier purs
   ↙       ↘
API       SQLite
Twelve    données utilisateur + cache horodaté
Data
```

Phrase clé : **la vue ne connaît ni l'API ni SQLite ; le repository décide de la source et le domaine calcule.**

## Questions/réponses — architecture

### Pourquoi séparer l'application en couches ?

Pour donner une responsabilité claire à chaque partie, éviter de concentrer la logique dans les Widgets, tester les calculs sans interface et pouvoir remplacer une source de données sans réécrire les écrans. Cette séparation répond aussi directement au critère d'architecture du sujet.

### Quel est le rôle d'un repository ?

Il offre au reste de l'application une interface orientée métier et coordonne les sources. Pour une donnée de marché, il vérifie le cache, décide si l'API doit être appelée, persiste une réponse valide et applique le repli offline en cas d'échec.

### Pourquoi un Widget ne contacte-t-il pas directement l'API ?

Un Widget peut être reconstruit souvent. Y placer l'appel réseau couplerait affichage, asynchrone, parsing et cache, provoquerait potentiellement des appels répétés et rendrait les tests difficiles. Le Widget doit seulement représenter un état.

### Où se trouvent les calculs métier ?

Dans des services purs de la couche `domain`, sans dépendance Flutter, HTTP ou SQLite. Ils reçoivent des valeurs, retournent un résultat et sont testés avec des cas normaux et limites.

### Pourquoi ne pas utiliser une Clean Architecture plus complète ?

Le sujet demande une séparation cohérente, pas un nombre maximal d'abstractions. La structure choisie couvre les responsabilités importantes avec un coût compréhensible pour un projet étudiant.

### Que se passe-t-il lorsqu'un Widget est reconstruit ?

Sa méthode `build` est réexécutée à partir de l'état observé. Les données persistantes ne disparaissent pas et un appel réseau ne doit pas être relancé automatiquement à chaque rebuild, car l'opération appartient au provider/repository.

## Questions/réponses — état et asynchrone

### Pourquoi Riverpod ?

Riverpod sépare l'état des Widgets, facilite l'injection des repositories et représente clairement les états asynchrones. Il permet aussi de tester un notifier avec de fausses dépendances.

### Quelle différence entre loading et refreshing ?

`loading` signifie qu'aucune donnée n'est encore affichable. `refreshing` signifie qu'une actualisation est en cours mais que les données précédentes restent visibles. Cette distinction évite un écran vide à chaque rafraîchissement.

### Comment une erreur arrive-t-elle jusqu'à l'écran ?

La source produit une erreur technique, le repository la traduit en résultat ou erreur applicative, puis le provider publie un état d'erreur. Si un cache valable existe, il peut publier les données anciennes avec un avertissement au lieu d'un écran bloquant.

### Quels états métier sont importants ?

Favori oui/non, portefeuille vide/renseigné, collection vide/renseignée, gemmes suffisantes/insuffisantes, formulaire valide/invalide, ouverture de pack inactive/en cours/terminée et cache frais/ancien/absent.

## Questions/réponses — données, API et cache

### Quelle différence entre DTO et modèle du domaine ?

Le DTO reflète le JSON du fournisseur, y compris ses noms de champs et formats parfois imparfaits. Le modèle du domaine contient les valeurs validées utiles à FinDeck et ne dépend pas de Twelve Data.

### Qui décide d'utiliser l'API ou le cache ?

Le repository. La source distante sait appeler l'API et la source locale sait lire SQLite, mais aucune ne possède seule la politique complète.

### Comment fonctionne le cache ?

Les réponses utiles sont enregistrées avec un horodatage. Un cache suffisamment récent évite un nouvel appel. S'il doit être actualisé, l'API est tentée ; en cas de succès la base est mise à jour, en cas d'échec l'ancien cache reste disponible et est signalé comme tel.

### Comment évitez-vous de télécharger plusieurs fois le même historique ?

Les points ont une clé unique symbole/date/intervalle. Le repository regarde la dernière date enregistrée et, si l'API le permet, demande uniquement la plage manquante puis effectue un upsert.

### Que se passe-t-il hors ligne après fermeture complète ?

Les données utilisateur et le cache sont dans SQLite. Au redémarrage, favoris, portefeuille, collection et données de marché déjà téléchargées sont relus. L'écran affiche la dernière actualisation. Une donnée jamais récupérée produit une erreur claire avec possibilité de réessayer.

### Pourquoi SQLite ?

FinDeck possède des données structurées et liées ainsi que des mises à jour atomiques, par exemple débiter des gemmes et ajouter plusieurs cartes. SQLite convient aux requêtes, contraintes, transactions et migrations. SharedPreferences reste limité aux petites préférences.

### Comment le cache est-il invalidé ?

La règle cible utilise l'horodatage de récupération et la dernière date de marché. Les seuils exacts devront être fixés en fonction des données et quotas réellement disponibles ; il faut pouvoir justifier chaque seuil plutôt que choisir un nombre arbitraire.

### Pourquoi Twelve Data ?

Ce fournisseur a été retenu comme candidat principal pour les actions, la recherche et les séries temporelles, tout en étant isolé derrière la couche data. Ses endpoints et limites doivent être vérifiés juste avant l'intégration, car les offres changent.

### Où est stockée la clé API ?

Elle ne doit pas être commitée ni codée dans un Widget. Elle sera injectée par une configuration locale. Sans backend, une clé présente dans l'application compilée reste extractible : c'est une limite connue de cette V1.

## Questions/réponses — domaine et persistance

### Quelle différence entre un actif et une carte ?

L'actif est l'entreprise/action et ses données financières. La carte est un objet de collection qui référence cet actif. Posséder une carte n'ajoute pas de position au portefeuille.

### Catégorie et rareté sont-elles liées à la performance ?

Non. La catégorie décrit l'entreprise et la rareté appartient au jeu. Aucune des deux ne constitue une recommandation. La rareté n'entre dans aucun calcul financier.

### Pourquoi garder les opérations plutôt que seulement les positions ?

Les opérations constituent une trace persistante des achats fictifs. Les positions peuvent être agrégées à partir d'elles, ce qui évite de maintenir deux sources de vérité contradictoires.

### Comment sécuriser l'ouverture d'un pack ?

Le contrôle du solde, le débit des gemmes et l'ajout/incrément des cartes sont faits dans une transaction SQLite. Soit tout réussit, soit tout est annulé. L'animation ne déclenche pas un second achat.

## Questions/réponses — calculs

### Comment calculez-vous la valeur d'une position ?

Quantité totale multipliée par le cours actuel. La valeur totale du portefeuille nécessite un cours utilisable pour chaque position et des montants de même devise. Si un cours manque, une éventuelle somme partielle doit être présentée comme incomplète et ne sert pas à calculer la performance globale.

### Comment calculez-vous le gain et la performance ?

Le gain vaut valeur actuelle moins montant investi. La performance vaut gain divisé par montant investi, multiplié par 100. Si l'investi est nul, la performance est indéfinie et la division n'est pas exécutée.

### Comment calculez-vous la répartition ?

La valeur de l'élément est divisée par la valeur totale du portefeuille puis multipliée par 100. Si le total est nul, aucun pourcentage n'est produit.

### Que faites-vous si un cours est absent ?

On ne remplace jamais un cours absent par zéro. Le résultat est marqué non calculable ou incomplet et l'interface l'explique.

### Pourquoi ne pas additionner toutes les devises ?

Additionner des euros et dollars sans taux de change n'a pas de sens. La V1 affiche la devise et ne promet pas de conversion ; cette limitation doit être visible si le catalogue contient plusieurs devises.

## Questions/réponses — animations

### Quelles sont les trois animations ?

Ouverture de pack, bascule du favori et transition de la valeur du portefeuille. Leur comportement est contrôlé dans le code, par exemple avec `AnimationController`, `Tween` et `AnimatedBuilder` ou mécanisme Flutter équivalent.

### Pourquoi l'animation de pack est-elle séparée de la transaction métier ?

L'effet visuel peut être interrompu ou rejoué, tandis que le débit et les cartes doivent rester exacts. La transaction métier est d'abord confirmée une seule fois, puis son résultat est présenté.

## Questions/réponses — tests

### Que testez-vous en priorité ?

Les calculs purs et leurs cas limites : portefeuille vide, gain négatif, division par zéro et cours manquant. Ensuite les décisions du repository avec des fausses sources : cache frais, absent, ancien, API en succès ou erreur.

### Comment tester le réseau sans dépendre de l'API réelle ?

Le repository reçoit une source distante substituable. Les tests utilisent une fausse source qui retourne les données ou erreurs prévues, sans clé ni Internet.

### Quel test prouve le mode hors ligne ?

Un test du repository prouve le repli sur un cache ancien, mais il faut aussi une démonstration manuelle après fermeture complète et désactivation du réseau pour vérifier la persistance réelle.

## Questions pièges et réponses honnêtes

### L'application donne-t-elle des conseils d'investissement ?

Non. Elle explique et simule. Les données historiques, cartes et raretés ne prédisent aucune performance future.

### Les données sont-elles en temps réel ?

Pas nécessairement. Le sujet accepte des données quotidiennes ou hebdomadaires. FinDeck affiche la dernière actualisation et ne prétend pas être une plateforme de trading.

### Pourquoi pas de backend ?

La V1 est locale et mono-utilisateur. Un backend augmenterait fortement le périmètre sans être requis pour la persistance/cache demandés. Cela implique en contrepartie aucune synchronisation et une protection limitée de la clé côté client.

### Qu'est-ce qui reste encore à décider avant de coder certaines features ?

La liste exacte des actifs, les catégories finales, les règles/probabilités/prix des packs, le solde et l'acquisition des gemmes, les seuils de cache, ainsi que les endpoints et quotas vérifiés de l'API.

## Modifications simples à savoir faire en direct

- ajouter une validation à un champ du portefeuille ;
- modifier un seuil de fraîcheur centralisé ;
- ajouter un nouvel état vide à un écran ;
- expliquer et ajuster une formule de calcul ;
- remplacer une fausse réponse API dans un test ;
- ajouter un champ DTO puis son mapping sans contaminer l'UI ;
- montrer où une migration SQLite serait ajoutée ;
- identifier les widgets reconstruits lorsqu'un favori change.

## Checklist avant soutenance

- être capable de refaire le schéma d'architecture sans notes ;
- montrer une preuve pour chacune des 13 contraintes ;
- tester l'application en ligne puis hors ligne après arrêt complet ;
- connaître les tables, clés et transactions ;
- expliquer au moins deux calculs avec un exemple numérique ;
- montrer le contrôle de deux animations ;
- exécuter les tests et expliquer un cas limite ;
- connaître les limites réelles de l'API et des données ;
- distinguer clairement ce qui était prévu de ce qui a réellement été livré.
