<p align="center">
  <img src="https://res.cloudinary.com/dxewdbsyg/image/upload/v1757580779/vague_1_qolgvu.png" alt="Logo" />
</p>

# Spot Surf App

Création d'une application pour rechercher et ajouter des spots de surf. Ce projet vise à faciliter la découverte et le partage des meilleurs spots de surf via une application mobile intuitive.




## Fonctionnalités principales

- Recherche de spots de surf via une carte interactive et une barre de recherche.

- Ajout, modification et suppression de spots par les utilisateurs authentifiés.

- Gestion de favoris, historique, et profils utilisateurs.

- Consultation détaillée d’un spot (description, localisation, images, etc.).

- Connexion sécurisée & gestion du compte (création, modification de profil, changement de mot de passe).

- Navigation fluide grâce à la mise en cache des données et aux appels API optimisés.




## Installation

Installation
Prérequis
Flutter SDK & Dart (≥ 3.9.0)

Go (≥ 1.24)

PostgreSQL

Google Maps API Key (à renseigner dans un fichier .env)

## Configuration

Clonez le repo :

```bash
git clone https://github.com/Nelson-Tsa/SpotSurfApp.git
```

Configuration Backend :

Copiez api/exemple.env en .env et configurez la connexion PostgreSQL + clé secrète JWT.

Lancez le serveur depuis api/ :

```bash
go run main.go
```
Configuration Frontend :

Placez vos clés et variables dans surf_spots_app/.env d’après .env.example.

Installez les dépendances :

```bash
cd surf_spots_app
flutter pub get
```

Lancez l'app :

```bash
flutter run
```
    
## Utilisation

- Enregistrez-vous et connectez-vous pour accéder à toutes les fonctionnalités.

- Parcourez la carte et la liste des spots.

- Ajoutez un spot, renseignez ses infos et photos.

- Ajoutez aux favoris, marquez comme visité, etc



<p align="center"><b>Contributeurs</b></p>

<table>
<tr>
<td valign="top">
  
<ul>
  <li><a href="https://github.com/Nelson-Tsa">@Nelson-Tsa</a></li>
  <li><a href="https://github.com/ewhalgand">@ewhalgand</a></li>
  <li><a href="https://github.com/Mlheriteau">@Mlheriteau</a></li>
  <li><a href="https://github.com/LeoV0">@LeoV0</a></li>
</ul>
</td>
<td>
  <img src="https://res.cloudinary.com/dxewdbsyg/image/upload/v1757581132/SurfPlancheGOOD_1_e3y2sh.png" alt="Logo" width="140"/>
</td>
</tr>
</table>




