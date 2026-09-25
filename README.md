# Application Full-Stack Flutter — Certification Mobile

[![Flutter CI/CD Pipeline](https://github.com/mamafadel/ffsc26_certif4/actions/workflows/ci.yml/badge.svg)](https://github.com/mamafadel/ffsc26_certif4/actions/workflows/ci.yml)

Application mobile Flutter complète connectée à une API REST réelle, intégrant l'authentification JWT avec Refresh Token, 3 écrans de données distincts (Produits, Articles, Recettes), la mise en cache locale, le mode hors-ligne avec basculement automatique, et une suite exhaustive de tests unitaires (61 tests) avec intégration continue CI/CD GitHub Actions.

---

## 🌟 Fonctionnalités Principales

### 1. 🔐 Authentification & Cycle de Vie des Jetons (JWT & RFC 6749)
- **Connexion & Inscription** : Authentification réelle via l'API REST avec validation des entrées.
- **Tokens JWT Bearer** : Injection automatique du token d'accès (`Authorization: Bearer <token>`) sur toutes les requêtes via un intercepteur réseau Dio.
- **Mécanisme de Refresh Token à deux niveaux** :
  - **Automatique / Transparent** : Intercepteur réseau interceptant les codes HTTP 401 pour renouveler le token et rejouer la requête d'origine sans interruption.
  - **Programmatique / Métier** : Méthode `refreshToken()` explicite exposée dans le Repository et le UseCase Clean Architecture.
- **Déconnexion sécurisée** : Nettoyage atomique des tokens et des données utilisateur en stockage local.

> [!NOTE]
> **Clarification sur le flux d'authentification (OAuth vs JWT) :**
> L'API utilisée ([DummyJSON](https://dummyjson.com)) est une API REST qui fournit une authentification par **jetons JWT** (`/auth/login`, `/auth/refresh`, `/auth/me`).
> Elle n'héberge pas de serveur d'autorisation tiers OAuth 2.0 (pas de redirection web à 3 tiers avec écran de consentement type Google/GitHub). Cependant, la gestion des tokens implémentée dans l'application respecte rigoureusement les standards **OAuth 2.0 Token Refresh (RFC 6749 Section 6)** et **Bearer Token Usage (RFC 6750)** :
> 1. Jeton d'accès à courte durée (`accessToken`) transmis dans l'en-tête `Authorization`.
> 2. Jeton de rafraîchissement à longue durée (`refreshToken`) stocké localement.
> 3. Échange transparent du refresh token contre un nouveau couple de jetons en cas d'expiration (401).

---

### 2. 📱 3 Écrans de Données REST Distincts (+ Profil & Auth)
L'application implémente **3 écrans de données REST distincts** dédiés à la consultation de collections indépendantes, en plus du module d'authentification et de profil :

1. 🛍️ **Écran 1 : Catalogue Produits (`/products`)**
   - Grille dynamique des produits avec images, prix, notes, marques et stock.
   - Recherche en temps réel en ligne et filtrage intelligent hors-ligne.
   - Écran de détail complet (`/products/{id}`) avec galerie d'images, caractéristiques et avis clients.

2. 📰 **Écran 2 : Flux d'Articles / Blog (`/posts`)**
   - Flux d'articles avec tags thématiques, nombre de vues et compteurs de réactions (likes et dislikes).

3. 🍲 **Écran 3 : Recettes de Cuisine (`/recipes`)**
   - Liste de recettes avec badges de difficulté, temps de préparation et de cuisson cumulés, type de cuisine, ingrédients et notes.

4. 👤 **Écran 4 : Mon Profil & Session (`/auth/me`)**
   - Consultation des informations de l'utilisateur connecté, statut de session et action de déconnexion.

---

### 3. 💾 Persistance & Mode Hors-ligne Automatique
- **Mise en cache locale automatique** de toutes les données (Produits, Articles, Recettes, Profil) via `SharedPreferences`.
- **Basculement automatique hors-ligne** : si le réseau est indisponible ou si le serveur répond en erreur, l'application charge instantanément les données locales.
- **Bannière visuelle d'avertissement** informant l'utilisateur que les données proviennent du cache local.
- **Recherche hors-ligne** : la recherche textuelle reste opérationnelle même sans connexion internet grâce au filtrage en mémoire du cache.

---

### 4. ⚠️ Gestion Robuste des Erreurs Utilisateur
- Retours visuels clairs avec `SnackBar` flottants et écrans d'erreur dédiés.
- Bouton interactif **« Réessayer »** en cas d'échec réseau ou serveur.
- Rafraîchissement tactile (**Pull-to-refresh**) sur tous les écrans de données.

---

## 🏗️ Architecture du Projet : Clean Architecture

Le projet est structuré selon les principes stricts de la **Clean Architecture** :

```text
lib/
├── core/                                   # Socle technique transversal
│   ├── errors/                             # Exceptions et Failures centralisés
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                            # Réseau & HTTP
│   │   ├── api_client.dart                 # Client Dio centralisé
│   │   └── auth_interceptor.dart           # Injection JWT & Refresh Token auto (401)
│   ├── theme/                              # Thème Material 3 (clair / sombre)
│   │   └── app_theme.dart
│   └── utils/                              # Constantes globales & clés de cache
│       └── constants.dart
│
├── features/
│   ├── auth/                               # Module Authentification & Profil
│   │   ├── data/
│   │   │   ├── datasources/                # auth_remote_data_source & auth_local_data_source
│   │   │   ├── models/                     # user_model.dart
│   │   │   └── repositories/               # auth_repository_impl.dart (login, register, refreshToken)
│   │   ├── domain/
│   │   │   ├── entities/                   # user.dart
│   │   │   ├── repositories/               # auth_repository.dart
│   │   │   └── usecases/                   # login, register, logout, getCurrentUser, refreshToken
│   │   └── presentation/                   # AuthProvider, Login, Register, Profile Screens
│   │
│   ├── products/                           # Module Catalogue Produits (Données REST 1)
│   │   ├── data/                           # product_remote/local_data_source, product_model, repository_impl
│   │   ├── domain/                         # product.dart, product_repository.dart, usecases (list, detail)
│   │   └── presentation/                   # ProductProvider, ProductsScreen, ProductDetailScreen
│   │
│   ├── posts/                              # Module Articles & Actualités (Données REST 2)
│   │   ├── data/                           # post_remote/local_data_source, post_model, repository_impl
│   │   ├── domain/                         # post.dart, post_repository.dart, get_posts_usecase
│   │   └── presentation/                   # PostProvider, PostsScreen
│   │
│   └── recipes/                            # Module Recettes Gourmandes (Données REST 3)
│       ├── data/                           # recipe_remote/local_data_source, recipe_model, repository_impl
│       ├── domain/                         # recipe.dart, recipe_repository.dart, get_recipes_usecase
│       └── presentation/                   # RecipeProvider, RecipesScreen
│
├── home_page.dart                          # Scaffold principal avec NavigationBar (4 onglets)
└── main.dart                               # Point d'entrée, MultiProvider & Injection de dépendances
```

---

## 🔄 Détail du Mécanisme de Refresh Token

Le mécanisme de Refresh Token est pris en charge à deux niveaux complémentaires :

### Niveau 1 : Couche Réseau (Transparent via Dio & Intercepteur)
Dans `lib/core/network/auth_interceptor.dart` :
1. `onRequest` : attache l'en-tête `Authorization: Bearer <accessToken>`.
2. `onError` : intercepte les réponses HTTP 401 Unauthorized.
3. Si un `refreshToken` est présent dans `SharedPreferences` :
   - Émet un appel `POST /auth/refresh` via une instance `Dio` indépendante (évitant toute boucle de récursion d'intercepteur).
   - Enregistre les nouveaux `accessToken` et `refreshToken`.
   - Rejoue la requête HTTP initiale avec le nouveau token.
4. Si le rafraîchissement échoue (ex. refresh token révoqué ou expiré) : purge automatiquement le stockage local pour rediriger l'utilisateur vers l'écran de connexion.

### Niveau 2 : Couche Métier (Clean Architecture Repository & UseCase)
- `AuthRepository.refreshToken()` :
  1. Récupère le refresh token stocké localement (`AuthLocalDataSource.getRefreshToken()`).
  2. Appelle l'endpoint distant `POST /auth/refresh` (`AuthRemoteDataSource.refreshToken()`).
  3. Met à jour atomiquement les jetons en local (`AuthLocalDataSource.saveTokens()`).
  4. Retourne l'entité `User` mise à jour.
- `RefreshTokenUseCase` : encapsule cette logique métier pour une utilisation manuelle ou programmatique.
- `AuthProvider.refreshToken()` : méthode d'actualisation de session utilisable par l'interface ou les tâches d'arrière-plan.

---

## 🌐 API REST Utilisée

L'application communique avec l'API publique **[DummyJSON REST API](https://dummyjson.com)** :

| Module | Endpoints REST | Description |
| :--- | :--- | :--- |
| **Authentification** | `POST /auth/login` | Authentification utilisateur & génération des tokens JWT |
| | `POST /auth/refresh` | Renouvellement de l'AccessToken via RefreshToken |
| | `GET /auth/me` | Récupération des données du profil connecté |
| **Inscription** | `POST /users/add` | Enregistrement d'un nouvel utilisateur |
| **Produits (Écran 1)** | `GET /products` | Récupération de la liste des produits |
| | `GET /products/search?q={query}` | Recherche textuelle de produits |
| | `GET /products/{id}` | Détail complet d'un produit par ID |
| **Articles (Écran 2)** | `GET /posts` | Flux d'articles avec tags et réactions |
| **Recettes (Écran 3)** | `GET /recipes` | Liste de recettes avec ingrédients et temps |

### Identifiants de Démo Préréglés :
- **Nom d'utilisateur** : `emilys`
- **Mot de passe** : `emilyspass`
*(L'écran de connexion propose un bouton « Remplir » automatique pour tester sans saisie manuelle).*

---

## 🧪 Tests Unitaires & Couverture

Le projet dispose d'une suite complète et rigoureuse de **61 tests unitaires et d'intégration** :

| Fichier de Test | Nombre de Tests | Cas Testés |
| :--- | :---: | :--- |
| `auth_repository_test.dart` | 9 | • Connexion réussie & persistance locale du profil et des jetons JWT<br>• Gestion des `ServerException` & exceptions inattendues lors du login<br>• Inscription réussie & gestion des échecs d'inscription<br>• Récupération du profil sauvegardé (présent / absent)<br>• Déconnexion et purge du cache local<br>• Renouvellement réussi via `refreshToken`<br>• Échec de refresh si token local manquant ou rejet serveur |
| `product_repository_test.dart` | 8 | • Récupération en ligne & mise en cache locale<br>• Recherche textuelle en ligne sans écraser le cache global<br>• Basculement automatique en mode hors-ligne vers le cache<br>• Filtrage textuel local hors-ligne<br>• Erreur `CacheException` si cache vide en hors-ligne<br>• Récupération d'un produit par ID en ligne<br>• Récupération d'un produit par ID en cache local<br>• Erreur `CacheException` si produit introuvable en cache |
| `post_repository_test.dart` | 3 | • Récupération en ligne & mise en cache des articles<br>• Basculement automatique sur le cache en mode hors-ligne<br>• Erreur `CacheException` si cache vide hors-ligne |
| `recipe_repository_test.dart` | 3 | • Récupération en ligne & mise en cache des recettes<br>• Basculement automatique sur le cache en mode hors-ligne<br>• Erreur `CacheException` si cache vide hors-ligne |
| `repository_test.dart` | 10 | Suite combinée d'intégration validant tous les repositories ensemble |
| `widget_test.dart` | 1 | Test de rendu de l'interface utilisateur du formulaire de connexion |

### Exécution des tests :
```bash
flutter test
```
*Résultat attendu : 61/61 tests passés avec succès.*

---

## ⚙️ Intégration Continue (CI/CD GitHub Actions)

Le workflow `.github/workflows/ci.yml` automatise la validation qualité à chaque modification du code :
1. Configuration de Flutter et du SDK Java.
2. Téléchargement des dépendances (`flutter pub get`).
3. Analyse statique stricte (`flutter analyze` — 0 warning / 0 lint).
4. Exécution de l'ensemble de la suite de tests (`flutter test`).
5. Construction de l'APK Android Release (`flutter build apk`).

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

4. **Lancer la suite de tests** :
   ```bash
   flutter test
   ```

5. **Exécuter l'application** :
   ```bash
   flutter run
   ```

---

## 🛠️ Technologies & Dépendances

- **Flutter & Dart** (Material 3)
- **[Dio](https://pub.dev/packages/dio)** : Client HTTP avec intercepteur personnalisé pour les jetons JWT et le renouvellement automatique par Refresh Token.
- **[Provider](https://pub.dev/packages/provider)** : Gestion d'état réactive découplée.
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** : Persistance locale et stratégie de cache hors-ligne.
- **[Mocktail](https://pub.dev/packages/mocktail)** : Mocking typé pour les tests unitaires de la Clean Architecture.

---

## 📝 Auteur
Projet développé dans le cadre de la certification **FFSC26 — Master App Fullstack Flutter**.
