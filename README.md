
# Backend Golang

## Groupe 8

- **Nom** : Antoine Chabernaud 5IW2  
  - **Pseudo** : [senex127](https://github.com/senex127)
- **Nom** : Laila Charaoui 5IW2  
  - **Pseudo** : [lailacha](https://github.com/lailacha)
- **Nom** : Vivian Ruhlmann 5IW2  
  - **Pseudo** : [Loviflo](https://github.com/Loviflo)
- **Nom** : Lucas Ramis 5IW2  
  - **Pseudo** : [RamisL](https://github.com/RamisL)

## Fonctionnalités du projet et répartition du travail

### Antoine Chabernaud
- **User Principal** : Affichage des tournois, jeux, historique des matchs.
- **Authentification** : Système de login/logout, gestion des tokens JWT.
- **Admin** : Dashboard admin, CRUD pour utilisateurs, tournois, jeux, et tags.
- **Frontend Guild** : Correction et amélioration de l'interface des guildes.
- **Mode Invité** : Fonctionnalités limitées pour les utilisateurs non enregistrés.

### Laila Charaoui
- **Backend** :
  - **Models** : Définition des schémas de données.
  - **Controllers** : Gestion des requêtes et des réponses HTTP.
  - **Middleware** : Gestion de la sécurité et des autorisations.
  - **DB** : Connexion et requêtes à la base de données.
  - **Routes** : Définition des routes API.
  - **Services** : Logique métier et interactions avec la base de données.
- **Map des Tournois** : Affichage des tournois sur une carte interactive.
- **Guilde** : Gestion des guildes, création et modification des guildes.
- **OAuth2 avec Google** : Intégration de l'authentification via Google.
- **Swagger** : Intégration du swagger.

### Vivian Ruhlmann
- **User Bracket** : Interface de visualisation des brackets de tournois.
- **Settings User** : Gestion des paramètres utilisateur (thème, traduction).
- **gRPC** : Mise en place des services gRPC pour la communication interservices.
- **Production** : Déploiement du projet en production.
- **Classement Global** : Affichage des classements globaux des joueurs.

### Lucas Ramis
- **Organisateur** :
  - **Création de Tournoi** : Interface pour créer de nouveaux tournois.
  - **Modification de Tournoi** : Modifier les détails des tournois existants.
  - **Gestion des Scores** : Mise à jour des scores des matchs.
  - **Gestion des Horaires** : Planification et modification des horaires des matchs.
  - **Lancement du Tournoi** : Gestion du début et du déroulement des tournois.

## Mise en production

Le projet est mis en production et sera disponible durant au moins deux semaines. Nous utilisons les services suivants :
- **Backend** : Hébergé sur un VPS
- **Frontend** : Hébergé sur Firebase

## Dépôt Git

Le code source du backend est disponible sur GitHub :
https://github.com/js-suck/card-conquest.git

## Liste des binaires et fonctionnalités

### Binaires

- `backend` : Serveur principal de l'application

### Fonctionnalités

- Authentification et gestion des utilisateurs
- Gestion des tournois, jeux, guildes
- Intégration OAuth2 avec Google
- Services gRPC
- API RESTful

## Procédure de compilation et d’exécution

### Compilation

Assurez-vous d'avoir Go installé sur votre machine. Clonez le dépôt et exécutez :

```sh
git clone https://github.com/js-suck/card-conquest.git
cd back
go build 
```

### Exécution

Pour exécuter le binaire :

```sh
./back
```


## Exemple de configuration pour lancement sur poste de travail local

Créez un fichier `.env` à la racine du projet avec les variables d'environnement nécessaires :

```env
API_URL="http://localhost:8080/api"
DATABASE_USERNAME="postgres"
DATABASE_PASSWORD="root"
DATABASE_NAME="api_golang"
DATABASE_HOST="127.0.0.1"
DATABASE_PORT="5432"
# Pour la Prod
SOCKET_PATH=
INSTANCE_CONNECTION_NAME=
```

## Éléments tiers nécessaires

- **Configuration** : Fichier `.env` avec les variables d'environnement
- **Certificats** : Certificat SSL pour HTTPS (si nécessaire)

# Frontend Flutter

## Procédure d'installation et d’exécution

### Installation

Assurez-vous d'avoir Flutter installé sur votre machine. Clonez le dépôt et exécutez :

```sh
git clone https://github.com/js-suck/card-conquest.git
cd front
flutter pub get
```

### Exécution

Pour exécuter l'application sur un émulateur ou un appareil physique :

```sh
flutter run
```

## Build APK

Pour créer un APK de production signé et installable :

```sh
flutter build apk --release
```

## Éléments tiers nécessaires

- **Configuration** : Fichier `env` avec les variables d'environnement
- **Certificats** : Certificat pour signer l'APK

## Exemple de configuration pour lancement sur poste de travail local

Créez un fichier `env` à la racine du projet avec les variables d'environnement nécessaires :

```env
API_URL=
API_IP=
MEDIA_URL=
```

