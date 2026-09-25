# Application Full-Stack Flutter — Certification Mobile (Master App Connectée)

Application mobile Flutter complète connectée à une API REST réelle, développée selon les principes de la Clean Architecture. Le projet intègre une gestion complète de l'authentification JWT avec mécanisme de Refresh Token, trois écrans distincts de données distantes (Catalogue de Produits, Flux d'Articles et Recettes de Cuisine), la persistance locale ultra-rapide avec Hive (`hive_flutter`), un mode hors-ligne intelligent avec basculement automatique et bandeau d'avertissement visuel, la gestion avancée des erreurs réseau avec retours utilisateurs (SnackBars et écrans d'erreur interactifs), un client HTTP basé sur le package officiel `http` avec intercepteur personnalisé pour l'injection des jetons d'autorisation, ainsi qu'une suite de tests unitaires rigoureux sur la couche repository et l'accès aux données locales.

---

## 📋 Table des Matières

1. [Spécifications & Exigences Validées](#-spécifications--exigences-validées)
2. [Architecture du Projet (Clean Architecture)](#-architecture-du-projet-clean-architecture)
3. [Appels Réseau avec le package HTTP & Intercepteur](#-appels-réseau-avec-le-package-http--intercepteur)
4. [Authentification & Gestion du Refresh Token](#-authentification--gestion-du-refresh-token)
5. [Mise en Cache Locale avec Hive (Hive Boxes)](#-mise-en-cache-locale-avec-hive-hive-boxes)
6. [Mode Hors-Ligne & Gestion des Erreurs Réseau](#-mode-hors-ligne--gestion-des-erreurs-réseau)
7. [Les 3 Écrans de Données REST Distincts](#-les-3-écrans-de-données-rest-distincts)
8. [Tests Unitaires de la Couche Repository](#-tests-unitaires-de-la-couche-repository)
9. [Configuration & Lancement](#-configuration--lancement)
10. [Pipeline CI/CD GitHub Actions](#-pipeline-cicd-github-actions)

---

## ✅ Spécifications & Exigences Validées

| Exigence du Référentiel | Statut | Implémentation dans le Projet |
| :--- | :---: | :--- |
| **Authentification (login/register/logout)** | ✅ | Flux JWT réel via `/auth/login`, `/auth/me` et `/users/add` |
| **Au moins 3 écrans de données REST** | ✅ | **Produits** (`/products`), **Articles** (`/posts`), **Recettes** (`/recipes`) |
| **Mise en cache locale des données (Hive)** | ✅ | **Hive** (`hive_flutter`) avec boîtes dédiées pour Produits, Articles et Recettes |
| **Mode hors-ligne avec affichage du cache** | ✅ | Basculement automatique en cas de panne réseau + `OfflineBanner` Hive |
| **Gestion d'erreurs réseau avec messages utilisateur** | ✅ | `NetworkErrorHandler` centralisé avec messages clairs, SnackBars et bouton *Réessayer* |
| **Architecture Clean ou Feature-First** | ✅ | Découpage strict `data` / `domain` / `presentation` par feature |
| **Repository Pattern** | ✅ | `AuthRepository`, `ProductRepository`, `PostRepository`, `RecipeRepository` |
| **Package HTTP pour les appels réseau** | ✅ | Package officiel `http` (`package:http/http.dart`) avec fallback `dio` |
| **Intercepteur pour l'injection du token d'auth** | ✅ | `AuthInterceptor extends http.BaseClient` injectant le token Bearer JWT |
| **Gestion du Refresh Token** | ✅ | Interception automatique 401 + `POST /auth/refresh` + `RefreshTokenUseCase` |
| **Tests unitaires sur la couche repository** | ✅ | Tests exhaustifs de la couche repository et de l'accès aux données Hive |

---

## 🏗️ Architecture du Projet (Clean Architecture)

Le projet respecte rigoureusement la **Clean Architecture** recommandée pour les applications Flutter d'envergure entreprise :

```text
lib/
├── core/                                   # Socle technique transversal
│   ├── errors/                             # Exceptions et Failures centralisés
│   │   ├── exceptions.dart                 # ServerException, CacheException, NetworkException
│   │   └── failures.dart                   # ServerFailure, CacheFailure, NetworkFailure, AuthFailure
│   ├── network/                            # Couche Réseau HTTP
│   │   ├── api_client.dart                 # Client HTTP centralisé (package:http et dio)
│   │   ├── auth_interceptor.dart           # AuthInterceptor (http.BaseClient) & AuthDioInterceptor
│   │   └── network_error_handler.dart      # Messages d'erreur conviviaux pour l'utilisateur
│   ├── theme/                              # Design System Material 3
│   │   └── app_theme.dart
│   ├── utils/                              # Constantes d'API et clés de stockage
│   │   └── constants.dart
│   └── widgets/                            # Composants transversaux
│       └── offline_banner.dart             # Bandeau visuel du Mode Hors-ligne Hive
│
├── features/
│   ├── auth/                               # Module Authentification & Profil
│   │   ├── data/
│   │   │   ├── datasources/                # auth_remote_data_source & auth_local_data_source (Hive)
│   │   │   ├── models/                     # user_model.dart
│   │   │   └── repositories/               # auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/                   # user.dart
│   │   │   ├── repositories/               # auth_repository.dart
│   │   │   └── usecases/                   # login, register, logout, getCurrentUser, refreshToken
│   │   └── presentation/                   # AuthProvider, LoginScreen, RegisterScreen, ProfileScreen
│   │
│   ├── products/                           # 1er Écran de Données REST : Catalogue Produits
│   │   ├── data/                           # product_remote/local_data_source (Hive), repository_impl
│   │   ├── domain/                         # product.dart, product_repository.dart, usecases (list, detail)
│   │   └── presentation/                   # ProductProvider, ProductsScreen, ProductDetailScreen
│   │
│   ├── posts/                              # 2e Écran de Données REST : Flux d'Articles
│   │   ├── data/                           # post_remote/local_data_source (Hive), repository_impl
│   │   ├── domain/                         # post.dart, post_repository.dart, get_posts_usecase
│   │   └── presentation/                   # PostProvider, PostsScreen
│   │
│   └── recipes/                            # 3e Écran de Données REST : Recettes de Cuisine
│       ├── data/                           # recipe_remote/local_data_source (Hive), repository_impl
│       ├── domain/                         # recipe.dart, recipe_repository.dart, get_recipes_usecase
│       └── presentation/                   # RecipeProvider, RecipesScreen
│
├── home_page.dart                          # Scaffold principal avec NavigationBar Material 3 (4 onglets)
└── main.dart                               # Initialisation de Hive, MultiProvider & Injection de dépendances
```

---

## 🌐 Appels Réseau avec le package HTTP & Intercepteur

Conformément aux exigences techniques, les appels réseau utilisent le package officiel **`http`** (`package:http/http.dart`) :

### Intercepteur d'Authentification (`AuthInterceptor`)
Dans `lib/core/network/auth_interceptor.dart`, la classe `AuthInterceptor` étend `http.BaseClient` :
1. **Injection automatique du Token** : Chaque requête sortante est interceptée pour injecter l'en-tête `Authorization: Bearer <accessToken>`.
2. **Détection du 401 Unauthorized** : Si le serveur répond avec un code HTTP 401, l'intercepteur bloque la requête en cours et déclenche le protocole de renouvellement.
3. **Renouvellement via Refresh Token** : Un appel `POST /auth/refresh` est émis pour obtenir de nouveaux tokens.
4. **Rejeu automatique** : La requête initiale est clonée, mise à jour avec le nouvel `accessToken` et rejouée de façon transparente.

```dart
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final SharedPreferences prefs;

  AuthInterceptor({http.Client? client, required this.prefs})
      : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Injection du token d'authentification
    final token = prefs.getString(AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // 2. Envoi et interception des erreurs 401 pour refresh token
    ...
  }
}
```

---

## 🔐 Authentification & Gestion du Refresh Token

L'application communique avec l'API publique **[DummyJSON](https://dummyjson.com)** :
* **Connexion** : `POST /auth/login` (récupère `accessToken` et `refreshToken`).
* **Profil utilisateur** : `GET /auth/me` (sécurisé par Bearer Token).
* **Inscription** : `POST /users/add`.
* **Renouvellement du Token** : `POST /auth/refresh`.

### Deux niveaux de renouvellement :
1. **Niveau Réseau Transparent** : via `AuthInterceptor`, l'utilisateur ne ressent aucune interruption lorsque son token expire.
2. **Niveau Métier Clean Architecture** : via `AuthRepository.refreshToken()`, `RefreshTokenUseCase` et `AuthProvider.refreshToken()`, permettant une invocation manuelle ou programmatique à l'ouverture de l'application.

---

## 💾 Mise en Cache Locale avec Hive (Hive Boxes)

Pour satisfaire l'exigence de persistance haute performance pour structures de données complexes, le projet utilise **Hive** (`hive_flutter`) :

* Initialisation dans `lib/main.dart` :
  ```dart
  await Hive.initFlutter();
  final productsBox = await Hive.openBox('products_box');
  final postsBox = await Hive.openBox('posts_box');
  final recipesBox = await Hive.openBox('recipes_box');
  final authBox = await Hive.openBox('auth_box');
  ```
* **`ProductLocalDataSourceImpl`** : Sauvegarde et lecture de la liste des produits dans la boîte Hive `products_box`.
* **`PostLocalDataSourceImpl`** : Mise en cache et lecture des articles dans la boîte Hive `posts_box`.
* **`RecipeLocalDataSourceImpl`** : Mise en cache et lecture des recettes dans la boîte Hive `recipes_box`.
* **`AuthLocalDataSourceImpl`** : Persistance sécurisée des données de session dans la boîte Hive `auth_box`.

---

## 📡 Mode Hors-Ligne & Gestion des Erreurs Réseau

### 1. Basculement Automatique en Mode Hors-Ligne
Chaque Repository (`ProductRepositoryImpl`, `PostRepositoryImpl`, `RecipeRepositoryImpl`) applique la stratégie suivante :
1. Tente de récupérer les données distantes fraîches via l'API REST.
2. En cas de succès : sauvegarde immédiatement les données dans le cache Hive local (`isCached: false`).
3. En cas d'échec réseau ou serveur (`NetworkException`, `SocketException`) : bascule instantanément sur le cache local Hive (`isCached: true`).
4. Si le cache local est vide : lève une exception claire pour guider l'utilisateur.

### 2. Bandeau Visuel Hors-Ligne (`OfflineBanner`)
Dès que les données affichées proviennent du cache Hive, un bandeau visuel ambré apparaît en haut de l'écran :
`Mode hors-ligne : Données affichées depuis le cache local Hive`

### 3. Gestion d'Erreurs Centralisée (`NetworkErrorHandler`)
La classe `NetworkErrorHandler` traduit chaque incident technique en message compréhensible pour l'utilisateur :
- *Pas de connexion Internet* : « Pas de connexion Internet. Vos données sont affichées depuis le cache local Hive. »
- *Serveur inaccessible* : « Le serveur est temporairement inaccessible. Les données hors-ligne sont affichées. »
- *Cache vide* : « Aucune donnée en cache disponible. Veuillez vous reconnecter pour actualiser. »

L'interface propose un bouton interactif **« Réessayer »** et supporte le rafraîchissement tactile (**Pull-to-refresh**).

---

## 📱 Les 3 Écrans de Données REST Distincts

L'application intègre **3 écrans de données distincts** issus de collections REST indépendantes, ainsi qu'un 4e écran dédié au profil et à l'authentification :

1. 🛍️ **Écran 1 : Catalogue Produits (`ProductsScreen`)**
   - Endpoints : `GET /products`, `GET /products/search?q={query}`, `GET /products/{id}`.
   - Fonctionnalités : grille de produits, recherche en temps réel (en ligne et filtrage local hors-ligne), écran de détail complet avec galerie d'images et avis.

2. 📰 **Écran 2 : Flux d'Articles & Actualités (`PostsScreen`)**
   - Endpoint : `GET /posts`.
   - Fonctionnalités : liste d'articles de blog avec tags, nombre de vues et compteurs de réactions (likes et dislikes).

3. 🍲 **Écran 3 : Recettes Gourmandes (`RecipesScreen`)**
   - Endpoint : `GET /recipes`.
   - Fonctionnalités : liste de recettes de cuisine avec temps de préparation, niveau de difficulté, type de cuisine, ingrédients et notes.

4. 👤 **Écran 4 : Mon Profil (`ProfileScreen`)**
   - Endpoint : `GET /auth/me`.
   - Fonctionnalités : consultation du profil connecté, gestion de la session et bouton de déconnexion.

---

## 🧪 Tests Unitaires de la Couche Repository

Le projet comprend une suite complète de **43 tests unitaires et d'intégration UI** vérifiant la Clean Architecture, la couche repository et l'accès aux données locales Hive :

1. **`test/repository_test.dart`** : Test d'intégration unitaire validant le comportement de tous les Repositories (Auth, Produits, Articles, Recettes) en mode en-ligne, basculement hors-ligne et gestion des erreurs.
2. **`test/unit/auth_repository_test.dart`** : Validation de `login`, `register`, `getSavedUser`, `logout` et `refreshToken`.
3. **`test/unit/product_repository_test.dart`** : Validation de `getProducts` (en-ligne, mise en cache, basculement hors-ligne, recherche) et `getProductById`.
4. **`test/unit/post_repository_test.dart`** : Validation de la récupération et de la mise en cache des articles avec fallback hors-ligne.
5. **`test/unit/recipe_repository_test.dart`** : Validation de la récupération et de la mise en cache des recettes avec fallback hors-ligne.
6. **`test/unit/local_data_source_test.dart`** : Tests unitaires dédiés à la logique d'accès aux données locales via les boîtes Hive.
7. **`test/widget_test.dart`** : Test d'intégration de l'interface utilisateur (`LoginScreen`).

### Exécution des tests :
```bash
flutter test
```

---

## 🚀 Configuration & Lancement

### Prérequis
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ≥ 3.12.0)
- Dart SDK (version ≥ 3.0.0)

### Étapes d'installation
1. **Cloner le dépôt GitHub** :
   ```bash
   git clone https://github.com/delfa25/ffsc26_certif4.git
   cd ffsc26_certif4
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Vérifier l'analyse statique du code** :
   ```bash
   flutter analyze
   ```

4. **Lancer les tests unitaires** :
   ```bash
   flutter test
   ```

5. **Exécuter l'application** :
   ```bash
   flutter run
   ```

### Identifiants de Démo Préréglés :
- **Nom d'utilisateur** : `emilys`
- **Mot de passe** : `emilyspass`
*(Un bouton « Remplir » sur l'écran de connexion pré-remplit automatiquement ces champs pour faciliter la soutenance).*

---

## ⚙️ Pipeline CI/CD GitHub Actions

Le fichier `.github/workflows/ci.yml` automatise la validation qualité à chaque push ou pull request :
1. Mise en place de l'environnement Flutter & Java.
2. Résolution des dépendances (`flutter pub get`).
3. Analyse statique stricte du code (`flutter analyze`).
4. Exécution de tous les tests unitaires (`flutter test`).
5. Construction de l'exécutable Android Release (`flutter build apk`).

---

## 📝 Auteur
Projet développé dans le cadre de la certification **FFSC26 — Master App Fullstack Flutter**.
