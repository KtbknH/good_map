# Good Maps — App (Flutter)

**Suggestions d'activités adaptées (PMR), générées par IA.**

Front Flutter du projet **Good Maps**. Affiche une carte, un formulaire de
profil, et des suggestions d'activités accessibles produites par un LLM
(via le backend) renvoyant un **JSON bien formaté** — le POC du cours.

> Le README racine (`../README.md`) couvre l'ensemble du projet (app + backend).

---

## ✨ Fonctionnalités (maquette)
1. **Splash** — logo Good Maps ; va directement à la carte si un profil est
   déjà enregistré.
2. **Onboarding** « Bienvenue ! » — formulaire de personnalisation, **pré-rempli**
   et **mémorisé** entre deux lancements.
3. **Carte** — carte OpenStreetMap **centrée sur la position** de l'utilisateur,
   bouton *« Obtenir des suggestions »*, et carte d'activité (titre, description,
   horaires, *Réservez en ligne* / *Appelez maintenant* fonctionnels, disclaimer).

## 🧱 Architecture
```
lib/
├── main.dart                 # Entrée : charge le profil persisté, injecte les providers
├── app.dart                  # MaterialApp + thème
├── core/
│   ├── theme/                # Couleurs, thème global
│   ├── constants/            # Espacements, rayons, géo par défaut
│   └── utils/                # launcher.dart (ouvrir URL / appeler)
├── models/                   # Suggestion (contrat JSON), UserProfile (+ JSON)
├── services/                 # AiSuggestionService (mock + backend)
│                             # LocationService (géoloc), ProfileRepository (persistance)
├── providers/                # OnboardingProvider, SuggestionsProvider
├── screens/                  # splash / welcome / map
└── widgets/                  # logo, bouton, carte de suggestion, top bar, carte
```

**Principe directeur :** l'UI ne dépend que d'**abstractions**. On bascule du
mock au backend, ou d'OpenStreetMap à Google Maps, sans toucher aux écrans.

## 🚀 Démarrage
Les dossiers de plateforme (`android/`, `ios/`…) ne sont pas versionnés ; on les
régénère en une commande.

```bash
cd app
flutter create .        # génère android/ios/web…
flutter pub get
flutter run             # tourne immédiatement grâce au mock (sans backend ni clé)
```
> `flutter doctor` doit être au vert. En cas d'incompatibilité de version,
> `flutter pub get` indique le paquet à ajuster.

## 📍 Géolocalisation
`LocationService` (geolocator) récupère la position, gère les permissions et
retombe proprement sur la ville saisie si refus. À configurer **après
`flutter create .`** :

- **Android** — `android/app/src/main/AndroidManifest.xml` :
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  ```
- **iOS** — `ios/Runner/Info.plist` :
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Good Maps utilise votre position pour proposer des activités proches.</string>
  ```
> Sur le **web**, la géoloc exige HTTPS. Sur émulateur, pensez à définir une
> position simulée.

## 💾 Persistance du profil
`ProfileRepository` (shared_preferences) sauvegarde le profil en JSON. Au
lancement, `main.dart` le recharge : si présent, on saute le formulaire. Le
profil reste éditable via l'icône réglages de la carte.

## 🗺️ La carte
`flutter_map` + OpenStreetMap (aucune clé API). Épingles des suggestions,
marqueur « vous êtes ici », recentrage sur la sélection. Code isolé dans
`lib/widgets/map_view.dart`.
- **Release Android** : ajouter `<uses-permission android:name="android.permission.INTERNET"/>`
  dans le manifest (déjà présent en debug).
- **Passer à Google Maps** : remplacer le contenu de `map_view.dart` ; le reste
  ne bouge pas.

## 📞 Boutons « Réservez » / « Appelez » (url_launcher)
Câblés dans `lib/core/utils/launcher.dart`. Déclarer les schémas après
`flutter create .` :
- **Android** (`<manifest>`) :
  ```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>
    <intent>
      <action android:name="android.intent.action.DIAL" />
      <data android:scheme="tel" />
    </intent>
  </queries>
  ```
- **iOS** (`Info.plist`) :
  ```xml
  <key>LSApplicationQueriesSchemes</key>
  <array><string>https</string><string>tel</string></array>
  ```

## 🔌 Brancher le backend (passer du mock au réel)
Dans `lib/main.dart`, remplacer :
```dart
Provider<AiSuggestionService>(create: (_) => MockAiSuggestionService())
```
par :
```dart
Provider<AiSuggestionService>(
  create: (_) => BackendAiSuggestionService(baseUrl: 'http://10.0.2.2:8080'),
)
```
(`10.0.2.2` = localhost de la machine hôte vu depuis l'émulateur Android.)

## 🛠️ Stack
- **Flutter / Dart** (SDK ≥ 3.3) · **provider** · **http**
- **flutter_map + latlong2** (carte) · **url_launcher** (URL/appel)
- **geolocator** (position) · **shared_preferences** (persistance)

## ✅ Tests
```bash
flutter test
```
Parsing JSON, round-trip du profil, persistance, service mock, affichage carte.

## 🗒️ Roadmap
- [x] Squelette Flutter (structure, thème, navigation, modèles, mock)
- [x] Carte réelle (flutter_map / OpenStreetMap)
- [x] Backend Spring Boot + appel LLM + validation du JSON
- [x] url_launcher (réservation / appel)
- [x] Géolocalisation (carte centrée + envoi au backend)
- [x] Persistance du profil (shared_preferences)
