
        ██╗    ██╗ █████╗ ██╗  ██╗███████╗███████╗███████╗██╗  ██╗
        ██║    ██║██╔══██╗██║ ██╔╝██╔════╝██╔════╝██╔════╝██║  ██║
        ██║ █╗ ██║███████║█████╔╝ █████╗  ███████╗███████╗███████║
        ██║███╗██║██╔══██║██╔═██╗ ██╔══╝  ╚════██║╚════██║██╔══██║
        ╚███╔███╔╝██║  ██║██║  ██╗███████╗███████║███████║██║  ██║
         ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝


## Description
Servers Manager est un outil en ligne de commande qui permet de gérer facilement vos connexions à distance vers différents serveurs. Ce script bash offre une interface utilisateur conviviale pour gérer les connexions SSH et les fonctionnalités Wake-on-LAN (WOL).

## Fonctionnalités

- **Interface utilisateur interactive** avec menus colorés et formatés
- **Gestion des connexions SSH** vers vos serveurs distants
- **Fonctionnalité Wake-on-LAN** pour allumer vos serveurs à distance
- **Gestion complète des serveurs** (ajout, suppression, visualisation)
- **Organisation des serveurs** par type (SSH ou WOL)

## Prérequis

- Système d'exploitation Linux ou macOS avec Bash
- Pour la fonctionnalité Wake-on-LAN : package `wakeonlan` installé
  ```
  sudo apt-get install wakeonlan  # Pour Debian/Ubuntu
  ```

## Installation

1. Téléchargez le script `Server.bash`
2. Rendez-le exécutable :
   ```
   chmod +x Server.bash
   ```
3. Exécutez-le :
   ```
   ./Server.bash
   ```

## Utilisation

### Menu principal

Le script affiche un menu principal avec les options suivantes :
1. Connexion SSH à un serveur
2. Wake-on-LAN pour démarrer un serveur
3. Édition de la liste des serveurs
4. Quitter

### Gestion des serveurs

Dans le menu "Édition de la liste des serveurs", vous pouvez :
1. Ajouter un nouveau serveur (SSH ou WOL)
2. Supprimer un serveur existant
3. Afficher la liste des serveurs actuels
4. Retourner au menu principal

#### Ajout d'un serveur SSH

Pour ajouter un serveur SSH, vous devrez fournir :
- Nom du serveur
- Adresse IP
- Port (par défaut : 22)
- Nom d'utilisateur

#### Ajout d'un serveur WOL

Pour ajouter un serveur compatible Wake-on-LAN, vous devrez fournir :
- Nom du serveur
- Adresse MAC
- Adresse IP
- Nom d'hôte

## Fichiers de données

Le script crée et utilise les fichiers suivants :
- `servers.txt` : Liste de tous les serveurs
- `serversSSH.txt` : Détails des serveurs SSH
- `serversWOL.txt` : Détails des serveurs Wake-on-LAN

## Personnalisation

Le script utilise des codes de couleur ANSI pour l'interface utilisateur. Vous pouvez modifier ces couleurs en éditant les variables au début du script :
- `ORANGE`
- `DARK_ORANGE`
- `BOLD`
- `UNDERLINE`
- `RESET`
- `BG_BLACK`
- `RED`

## Dépannage

### Problèmes avec Wake-on-LAN

Si la fonctionnalité Wake-on-LAN ne fonctionne pas :
1. Vérifiez que le package `wakeonlan` est installé
2. Assurez-vous que l'adresse MAC est correctement formatée
3. Vérifiez que votre serveur cible est configuré pour accepter les paquets WOL

### Problèmes avec SSH

Si la connexion SSH échoue :
1. Vérifiez que l'adresse IP et le port sont corrects
2. Assurez-vous que le nom d'utilisateur est valide
3. Vérifiez que le serveur cible est accessible sur le réseau

## Licence

Ce script est fourni tel quel, sans garantie. Vous êtes libre de le modifier et de le distribuer selon vos besoins.