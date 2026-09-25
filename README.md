# Application Full-Stack Flutter — Certification Mobile

[![Flutter CI/CD Pipeline](https://github.com/mamafadel/ffsc26_certif4/actions/workflows/ci.yml/badge.svg)](https://github.com/mamafadel/ffsc26_certif4/actions/workflows/ci.yml)

Application mobile Flutter complète connectée à une API REST réelle, intégrant l'authentification JWT, la gestion du refresh token, la mise en cache locale, le mode hors-ligne, la gestion des erreurs réseau et une suite de tests unitaires avec intégration continue CI/CD GitHub Actions.

---

## 🌟 Fonctionnalités Principales

- 🔐 **Authentification Réelle (JWT & OAuth Flow)**
  - Connexion avec identifiants réels via API REST.
  - Inscription d'utilisateurs.
  - Déconnexion et suppression sécurisée des tokens.
  - Injection automatique du token JWT (`Authorization: Bearer <token>`) dans les requêtes via un **Intercepteur Dio**.
  - **Gestion automatique du Refresh Token** : intercepte les erreurs 401 et renouvelle le jeton de session de manière transparente.

- 🛍️ **Catalogue Produits (API REST)**
  - Liste dynamique des produits avec images, prix, notes et stocks.
  - Recherche en temps réel.
  - Écran de détail complet avec galerie d'images, avis, marques et statut de stock.

- 📰 **Flux d'Articles / Actu (API REST)**
  - Consultation des articles de blog / posts avec tags, réactions (likes/dislikes) et nombres de vues.

- 💾 **Persistance & Mode Hors-ligne**
  - Sauvegarde locale automatique des données (Produits, Articles, Profil).
  - Basculement automatique en **Mode Hors-ligne** en cas de coupure réseau ou d'échec serveur.
  - Bannière visuelle indiquant l'affichage des données depuis le cache local.

- ⚠️ **Gestion des Erreurs Utilisateur**
  - Retours visuels personnalisés (SnackBars, états d'erreur avec bouton *Réessayer*).

---

## 🏗️ Architecture du Projet : Clean Architecture

Le projet respecte rigoureusement les principes de la **Clean Architecture** (découplage strict entre la logique métier, la couche de données et la présentation) :

```text
lib/
├── core/                        # Composants transversaux
│   ├── errors/                  # Exceptions et Failures centralisés
│   ├── network/                 # Client Dio, AuthInterceptor (Refresh Token), Network Info
│   ├── theme/                   # Thématisation Material 3
│   └── utils/                   # Constantes globales
│
├── features/
│   ├── auth/                    # Module Authentification
│   │   ├── data/                # Models, DataSources (Remote & Local), RepositoryImpl
│   │   ├── domain/              # Entities, Repository Interface, UseCases
│   │   └── presentation/        # AuthProvider, Login, Register & Profile Screens
│   │
│   ├── products/                # Module Catalogue Produits
│   │   ├── data/                # Models, DataSources (Remote & Local), RepositoryImpl
│   │   ├── domain/              # Entities, Repository Interface, UseCases
│   │   └── presentation/        # ProductProvider, Products & ProductDetail Screens
│   │
│   └── posts/                   # Module Articles & Actualités
│       ├── data/                # Models, DataSources (Remote & Local), RepositoryImpl
│       ├── domain/              # Entities, Repository Interface, UseCases
│       └── presentation/        # PostProvider, Posts Screen
│
├── home_page.dart               # Navigation principale (BottomNavigationBar)
└── main.dart                    # Point d'entrée de l'application & Injection de dépendances
```

---

## 🌐 API REST Utilisée

L'application communique avec l'API publique **[DummyJSON REST API](https://dummyjson.com)** :

| Fonctionnalité | Endpoints REST |
| :--- | :--- |
| **Authentification** | `POST /auth/login`, `POST /auth/refresh`, `GET /auth/me` |
| **Inscription** | `POST /users/add` |
| **Produits** | `GET /products`, `GET /products/search?q={query}`, `GET /products/{id}` |
| **Articles/Posts** | `GET /posts` |

### Identifiants de Démo Préréglés :
- **Nom d'utilisateur** : `emilys`
- **Mot de passe** : `emilyspass`
*(L'écran de connexion propose un bouton "Remplir" automatique pour faciliter les tests)*.

---

## 🧪 Tests Unitaires & Couverture

L'application inclut une suite complète de **tests unitaires** vérifiant la couche repository et le comportement en mode en-ligne et hors-ligne :

1. `auth_repository_test.dart` :
   - Connexion réussie, réception et stockage local des jetons JWT.
   - Gestion des échecs d'authentification (`AuthFailure`).
2. `product_repository_test.dart` :
   - Récupération en-ligne des produits et mise en cache.
   - Basculement hors-ligne vers le cache local en cas de panne réseau.
3. `post_repository_test.dart` :
   - Chargement et sauvegarde des articles en cache.
   - Récupération fluide des articles depuis le cache en mode déconnecté.
4. `widget_test.dart` :
   - Test d'intégration d'affichage UI du formulaire de connexion.

### Exécution des tests :
```bash
flutter test
```

---

## ⚙️ Intégration Continue (CI/CD GitHub Actions)

Le fichier `.github/workflows/ci.yml` automatise les étapes suivantes à chaque `push` ou `pull request` :
1. Installation de l'environnement Flutter & Java SDK.
2. Résolution des dépendances (`flutter pub get`).
3. Analyse statique du code (`flutter analyze`).
4. Exécution de tous les tests unitaires (`flutter test`).
5. Build de l'application Android APK Release (`flutter build apk`).

---

## 🚀 Installation et Lancement

### Prérequis
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ≥ 3.12.0)
- Dart SDK (version ≥ 3.0.0)

### Étapes
1. **Cloner le projet** :
   ```bash
   git clone https://github.com/mamafadel/ffsc26_certif4.git
   cd ffsc26_certif4
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'analyse du code** :
   ```bash
   flutter analyze
   ```

4. **Lancer les tests** :
   ```bash
   flutter test
   ```

5. **Exécuter l'application** :
   ```bash
   flutter run
   ```

---

## 🛠️ Technologies & Packages Utilisés

- **Flutter & Dart** (Material 3)
- **[Dio](https://pub.dev/packages/dio)** : Client HTTP avec intercepteurs personnalisés pour JWT et Refresh Token.
- **[Provider](https://pub.dev/packages/provider)** : Gestion de l'état réactive et propre.
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** : Persistance locale et cache JSON.
- **[Mocktail](https://pub.dev/packages/mocktail)** & **Flutter Test** : Frameworks de mock et tests unitaires.

---

## 📝 Auteur
Projet développé dans le cadre de la certification **FFSC26 — Master App Fullstack Flutter**.
