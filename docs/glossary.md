# Glossaire

| Terme | Définition dans FinDeck |
|---|---|
| Actif (`Asset`) | Entreprise/action réelle identifiée notamment par un symbole de marché. |
| API REST | Service HTTP externe qui fournit les données de marché au format JSON. |
| Cache | Copie locale horodatée de données issues de l'API, réutilisable et renouvelable. |
| Carte | Objet de collection qui représente un actif sans constituer une position financière. |
| Catégorie | Regroupement descriptif d'une entreprise ; distinct de la rareté. |
| Cours de clôture | Dernier prix d'une période de marché ; utilisé pour les historiques si disponible. |
| DAO | Composant qui encapsule les opérations de lecture/écriture SQLite. |
| DTO | Objet dont la structure correspond à une réponse externe avant conversion vers le domaine. |
| État stale/ancien | Donnée locale utilisable mais dont une actualisation aurait été souhaitable. |
| Favori | Actif suivi par l'utilisateur et enregistré localement. |
| Gemmes | Monnaie strictement virtuelle, locale et sans valeur réelle, utilisée pour les packs. |
| JSON | Format textuel retourné par l'API et converti vers des objets Dart. |
| Mapping | Conversion entre DTO, enregistrement local et modèle du domaine. |
| OHLCV | Open, High, Low, Close, Volume : ouverture, plus haut, plus bas, clôture, volume. |
| Pack | Conteneur virtuel acheté avec des gemmes et révélant un nombre défini de cartes. |
| Persistance | Conservation des données après fermeture complète de l'application. |
| Portefeuille fictif | Simulation locale d'opérations et positions, sans argent réel. |
| Provider | Point d'accès Riverpod qui expose une dépendance ou un état observable. |
| Rareté | Niveau ludique Common/Rare/Epic/Legendary, sans signification financière. |
| Repository | Composant qui coordonne les sources distante et locale et applique la politique de cache. |
| Rebuild | Nouvelle exécution de la méthode de construction d'un Widget lorsque ses dépendances changent. |
| Source distante | Partie de la couche data qui appelle Twelve Data et parse le JSON. |
| Source locale | Partie de la couche data qui accède à SQLite ou aux préférences. |
| Transaction SQLite | Groupe d'écritures exécutées entièrement ou annulées ensemble. |
| Twelve Data | Fournisseur d'API envisagé pour la recherche, les cotations et historiques d'actions. |
