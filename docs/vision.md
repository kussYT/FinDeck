# Vision et concept

## Promesse

**[DÉCIDÉ — FINDECK]**

> FinDeck — apprendre le marché en le collectionnant.

FinDeck utilise de vraies données d'entreprises et d'actions pour rendre les premiers concepts d'investissement concrets. La gamification sert l'engagement et la découverte ; elle ne transforme pas l'application en plateforme de trading.

## Objectifs

- rendre la lecture d'un prix, d'une variation et d'un historique plus accessible ;
- permettre de suivre quelques actifs sans enjeu financier réel ;
- montrer l'effet d'un cours actuel sur un portefeuille fictif ;
- illustrer la diversification par une répartition visuelle ;
- offrir une expérience motivante grâce aux cartes, packs et gemmes virtuelles ;
- rester utile avec les dernières données disponibles lorsque le réseau est absent.

## Concepts à ne pas confondre

### Actif et carte

**[DÉCIDÉ — FINDECK]** Un `Asset` représente l'entreprise/action et ses données financières. Une `CollectibleCard` est l'objet gamifié qui référence cet actif. Posséder la carte Apple ne signifie pas posséder Apple dans le portefeuille fictif.

### Catégorie et rareté

**[DÉCIDÉ — FINDECK]** La catégorie décrit le domaine de l'entreprise. La rareté décrit uniquement la carte à collectionner. Une rareté élevée ne constitue ni un score financier, ni une recommandation, ni une prévision de rendement.

### Collection et portefeuille

**[DÉCIDÉ — FINDECK]** La collection mémorise les cartes obtenues. Le portefeuille mémorise des opérations fictives avec quantités et prix d'achat. Les deux évoluent indépendamment.

## Périmètre retenu

**[DÉCIDÉ — FINDECK]**

- entreprises/actions réelles ;
- marché, recherche, fiche et historique ;
- favoris ;
- collection de cartes, catégories et raretés ;
- packs achetés avec des gemmes virtuelles ;
- portefeuille fictif et graphiques ;
- cache local et mode hors ligne dégradé ;
- calculs, animations et tests requis par le sujet.

## Hors périmètre

**[IMPOSÉ — SUJET]** Aucune transaction financière réelle et aucune connexion bancaire ou à un courtier.

**[DÉCIDÉ — FINDECK]** Pour la première version :

- aucun paiement réel ;
- aucun backend, compte distant ou synchronisation multi-appareil ;
- aucune authentification ;
- aucune prédiction de marché ;
- aucun score ou conseil personnalisé d'investissement ;
- aucune promesse de données temps réel ;
- aucun réseau social, classement entre utilisateurs ou échange de cartes.

Ces éléments ne doivent pas apparaître dans le code sans une nouvelle décision explicite.

## Questions encore ouvertes

**[À DÉCIDER]**

- liste exacte des actifs du catalogue initial ;
- taxonomie finale des catégories ;
- règle d'attribution et probabilités des raretés ;
- composition et prix exacts des packs ;
- solde initial et éventuel mécanisme d'obtention des gemmes ;
- comportement de l'ouverture de pack hors ligne ;
- charte graphique, textes pédagogiques exacts et langues prises en charge.
