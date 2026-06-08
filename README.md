<div align="center">

# 🗺️ Good Maps

### Suggestions d'activités adaptées (PMR), générées par IA

*Projet fil rouge — module « Coder avec l'IA Générative » (EPSI, B3)*

**App Flutter** &nbsp;•&nbsp; **Backend Spring Boot** &nbsp;•&nbsp; **LLM (Claude)**

</div>

---

## 📑 Sommaire
- [1. Présentation](#1-présentation)
- [2. Aperçu (maquette)](#2-aperçu-maquette)
- [3. Architecture d'ensemble](#3-architecture-densemble)
- [4. Stack technique](#4-stack-technique)
- [5. Démarrage rapide](#5-démarrage-rapide)
- [6. Installation détaillée](#6-installation-détaillée)
- [7. Comment l'app et le backend communiquent](#7-comment-lapp-et-le-backend-communiquent)
- [8. Le POC : un JSON bien formaté](#8-le-poc--un-json-bien-formaté)
- [9. Méthodologie IA](#9-méthodologie-ia)
- [10. Sécurité](#10-sécurité)
- [11. Tests](#11-tests)
- [12. Arborescence](#12-arborescence)
- [13. Correspondance avec le barème](#13-correspondance-avec-le-barème)
- [14. Roadmap](#14-roadmap)

---

## 1. Présentation

**Good Maps** aide les personnes à mobilité réduite (PMR) — et plus largement
toute personne avec un besoin d'accessibilité — à trouver des **activités
adaptées** près d'elles. L'utilisateur renseigne un profil (besoin de mobilité,
centres d'intérêt, ville…), l'app récupère sa position, et une **IA générative**
propose des activités accessibles, affichées sur une carte avec possibilité de
**réserver** ou d'**appeler** directement.

Le fil conducteur pédagogique du cours est le rôle du développeur **« chef
d'orchestre »** : on ne code pas chaque ligne à la main, on **pilote** l'IA, on
**comprend** ce qu'elle produit, et on **intègre** proprement dans une
architecture maîtrisée. Ce dépôt en est l'illustration concrète.

> Le POC du cours : **« récupérer un JSON bien formaté »** depuis un LLM. C'est
> le cœur technique du projet (section 8).

---

## 2. Aperçu (maquette)

Trois écrans, fidèles à la maquette du cours :

| # | Écran | Contenu |
|---|-------|---------|
| 1 | **Splash** | Logo Good Maps. Redirige vers la carte si un profil est déjà enregistré, sinon vers l'onboarding. |
| 2 | **Bienvenue !** | Formulaire de personnalisation du profil (pré-rempli, mémorisé). Bouton *« Passer à la carte »*. |
| 3 | **Carte** | Barre (réglages · logo · infos), carte OpenStreetMap centrée sur l'utilisateur, bouton *« Obtenir des suggestions »*, fiche d'activité (description, horaires, *Réservez en ligne* / *Appelez maintenant*) et disclaimer IA. |

Palette : coral `#FF5C5C`, encre `#1A1A1A`, fond blanc.

---

## 3. Architecture d'ensemble

Monorepo en deux projets indépendants :

```
goodmaps/
├── app/        →  Front Flutter (UI, carte, géoloc, persistance)
└── backend/    →  API Spring Boot (préprompt, appel LLM, validation JSON)
```

Flux d'une demande de suggestions :

```
┌──────────────┐   POST /api/suggestions    ┌───────────────┐   POST /v1/messages   ┌──────────┐
│  App Flutter │ ──  profil + position   ──> │    Backend    │ ──   préprompt    ──> │  Claude  │
│  (UI, carte) │                             │ (Spring Boot) │                       │  (LLM)   │
│              │ <── { "suggestions": … } ── │               │ <── JSON (nettoyé +   │          │
└──────────────┘                             └───────────────┘      validé)          └──────────┘
       │                                              │
  modèle Dart                                  🔐 clé API ICI
  `Suggestion`                                 (jamais côté app)
```

**Pourquoi cette séparation ?**
- **Sécurité** : la clé API du LLM ne quitte jamais le serveur.
- **Maîtrise** : le préprompt est versionné côté backend, pas dans le client.
- **Maintenabilité** : l'app ne dépend que d'abstractions ; on remplace le mock
  par le backend (ou OpenStreetMap par Google Maps) sans rien casser ailleurs.

---

## 4. Stack technique

**App (Flutter / Dart, SDK ≥ 3.3)**
- `provider` — gestion d'état (UI découplée de la logique)
- `flutter_map` + `latlong2` — carte OpenStreetMap (sans clé API)
- `url_launcher` — ouverture d'URL (réservation) et appels (`tel:`)
- `geolocator` — géolocalisation de l'appareil
- `shared_preferences` — persistance locale du profil
- `http` — appel du backend

**Backend (Java 17+, Spring Boot 3.3)**
- `spring-boot-starter-web` + `RestClient` — API REST et appel HTTP du LLM
- Jackson — (dé)sérialisation JSON (records Java)
- JUnit 5 — tests

---

## 5. Démarrage rapide

L'app **tourne immédiatement** avec des données de démonstration (mock), sans
backend ni clé API. Pour la chaîne complète, lancez aussi le backend.

```bash
# 1) (Optionnel) Backend — mode mock, démarre sans clé
cd backend
mvn spring-boot:run            # http://localhost:8080

# 2) App Flutter
cd ../app
flutter create .               # génère android/ios/web…
flutter pub get
flutter run
```

Pour utiliser le **vrai LLM** : exporter la clé avant de lancer le backend
(`export ANTHROPIC_API_KEY=sk-ant-...`) puis brancher l'app sur le backend
(section 7).

---

## 6. Installation détaillée

### 6.1 Prérequis
- **Flutter** (SDK ≥ 3.3), vérifié avec `flutter doctor` (toolchain Android/iOS).
- **Java 17+** et **Maven 3.9+** pour le backend.

### 6.2 App — configuration plateforme (après `flutter create .`)
Les permissions natives ne sont pas versionnées ; ajoutez-les une fois.

**Android** — `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Internet (tuiles de carte en release) -->
<uses-permission android:name="android.permission.INTERNET"/>
<!-- Géolocalisation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Au niveau <manifest> : schémas pour url_launcher -->
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

**iOS** — `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Good Maps utilise votre position pour proposer des activités proches.</string>
<key>LSApplicationQueriesSchemes</key>
<array><string>https</string><string>tel</string></array>
```

### 6.3 Backend — clé API
```bash
cp .env.example .env            # puis renseigner la clé, OU exporter :
export ANTHROPIC_API_KEY=sk-ant-votre-cle
export LLM_MODEL=claude-sonnet-4-6   # optionnel ; vérifiez le modèle dispo
mvn spring-boot:run
```
Sans clé, le backend démarre en **mode mock** (données de démo). La clé n'est
jamais commitée (`.gitignore` exclut `.env`).

---

## 7. Comment l'app et le backend communiquent

Dans `app/lib/main.dart`, remplacer le mock par le backend :
```dart
Provider<AiSuggestionService>(
  create: (_) => BackendAiSuggestionService(baseUrl: 'http://10.0.2.2:8080'),
)
```

`baseUrl` selon la cible :

| Cible | baseUrl |
|---|---|
| Émulateur Android | `http://10.0.2.2:8080` (10.0.2.2 = localhost de l'hôte) |
| Web / desktop / simulateur iOS | `http://localhost:8080` |
| Téléphone physique | `http://<IP-LAN-de-votre-PC>:8080` |

**Contrat aligné de bout en bout :**
- L'app envoie `UserProfile.toJson()` → mappé sur le record `UserProfileRequest`.
- Le backend répond `{ "suggestions": [...] }` → mappé 1:1 sur le modèle Dart
  `Suggestion`. (Le champ booléen `isAccessiblePmr` est verrouillé via
  `@JsonProperty` pour rester identique des deux côtés.)

Endpoints : `POST /api/suggestions`, `GET /api/health`.

---

## 8. Le POC : un JSON bien formaté

L'objectif central du cours est d'obtenir d'un LLM un **JSON directement
exploitable**. La stratégie :

1. **Schéma imposé** dans le préprompt (interdiction de texte libre, `null`
   explicites). Voir `app/docs/PREPROMPT.md` et `backend/.../PromptBuilder.java`.
2. **Modèle = contrat** : le schéma JSON correspond exactement au modèle
   `Suggestion` (app & backend).
3. **Défense anti-« bullshit »** : le backend retire d'éventuels fences Markdown
   et **valide** la structure avant de répondre (rejet si liste vide / JSON
   invalide).

Extrait du schéma exigé :
```json
{ "suggestions": [ {
  "id": "string", "title": "string", "description": "string",
  "latitude": 0, "longitude": 0, "openingInfo": "string",
  "isAccessiblePmr": true, "bookingUrl": "string|null", "phoneNumber": "string|null"
} ] }
```

---

## 9. Méthodologie IA

Détaillée dans **`app/docs/METHODOLOGIE_IA.md`**. En résumé :

- **Outils** : Claude (génération de code, précis), Copilot (autocomplétion dans
  VS Code), Cursor (audit/refactor du repo), un LLM côté backend pour le JSON.
- **Démarche cartésienne** : découpage en briques indépendantes (thème →
  modèles → services → providers → widgets → écrans), chacune compréhensible et
  testable seule.
- **Anti « prompt gambling »** : préprompt versionné, schéma JSON imposé, revue
  humaine systématique du code généré.
- **Limites assumées** : l'IA *simule sans comprendre* ; le disclaimer invite à
  vérifier les informations sensibles (horaires, accessibilité).

---

## 10. Sécurité

- **Clé API côté serveur uniquement**, lue depuis une variable d'environnement,
  jamais dans l'app ni dans Git.
- **Validation** du JSON renvoyé par le LLM avant exposition à l'app.
- **CORS** ouvert en POC (`backend/.../CorsConfig.java`) → **à restreindre** en
  production.

---

## 11. Tests

```bash
# App
cd app && flutter test
# Backend
cd backend && mvn test
```
Couverture : parsing/round-trip JSON, persistance du profil, service mock,
construction du préprompt, affichage de la fiche de suggestion.

> ⚠️ Le backend n'a pas été compilé dans l'environnement de génération (pas
> d'accès à Maven Central) : lancez `mvn test` / `mvn spring-boot:run` en local
> pour confirmer, et vérifiez que `LLM_MODEL` correspond à un modèle disponible
> sur votre compte.

---

## 12. Arborescence

```
goodmaps/
├── README.md                         ← ce fichier
├── app/                              ← Flutter
│   ├── lib/
│   │   ├── main.dart  app.dart
│   │   ├── core/{theme,constants,utils}/
│   │   ├── models/        (Suggestion, UserProfile)
│   │   ├── services/      (AiSuggestion, Location, ProfileRepository)
│   │   ├── providers/     (Onboarding, Suggestions)
│   │   ├── screens/       (splash, welcome, map)
│   │   └── widgets/       (logo, bouton, carte, top bar, suggestion_card)
│   ├── test/
│   ├── docs/              (PREPROMPT.md, METHODOLOGIE_IA.md)
│   └── pubspec.yaml
└── backend/                          ← Spring Boot
    ├── src/main/java/com/goodmaps/backend/
    │   ├── config/        (Llm, Cors, Service)
    │   ├── controller/    (SuggestionController)
    │   ├── dto/           (UserProfileRequest, Suggestion, SuggestionsResponse)
    │   ├── service/       (PromptBuilder, Mock + Anthropic)
    │   └── exception/     (GlobalExceptionHandler)
    ├── src/test/java/...
    ├── src/main/resources/application.yml
    └── pom.xml
```

---

## 13. Correspondance avec le barème

*(Barème page 20 du support de cours.)*

| Critère | Comment il est couvert |
|---|---|
| **Méthodologie** (outils IA, préprompt) | `app/docs/METHODOLOGIE_IA.md` (outils, démarche) et `app/docs/PREPROMPT.md` + `backend/.../PromptBuilder.java` (préprompt versionné, schéma imposé). |
| **Complétude** (README détaillé) | Ce README racine + un README par sous-projet. |
| **Structure, maintenabilité, sécurité** | Architecture en couches des deux côtés ; abstraction `AiSuggestionService` (mock ↔ backend) ; carte isolée ; **clé API côté serveur**, JSON validé. |
| **Rendu** | Thème centralisé fidèle à la maquette, carte OpenStreetMap, marqueur de position, actions *Réservez/Appelez* fonctionnelles. |
| **Maîtrise de la stack** | Flutter idiomatique (provider, flutter_map, geolocator, shared_preferences, url_launcher) **et** Spring Boot 3 (records, RestClient, Jackson, JUnit). |

---

## 14. Roadmap

- [x] Squelette Flutter (structure, thème, navigation, modèles, mock)
- [x] Carte réelle (flutter_map / OpenStreetMap)
- [x] Backend Spring Boot + appel LLM + validation du JSON
- [x] `url_launcher` (réservation / appel)
- [x] Géolocalisation (carte centrée + envoi au backend)
- [x] Persistance du profil (shared_preferences)

**Pistes futures :** cache des suggestions, choix multi-fournisseur (OpenAI,
Mistral) derrière la même interface, validation Bean Validation, mode hors-ligne.

---

<div align="center">
<sub>EPSI B3 — Coder avec l'IA Générative · « Musique, maestro ! » 🎼</sub>
</div>
