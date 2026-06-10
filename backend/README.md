# Good Maps — Backend (Spring Boot)

Backend Java du projet **Good Maps**. Son rôle : recevoir le profil utilisateur,
**construire le préprompt**, **appeler le LLM** (Claude / Anthropic) et renvoyer
à l'app un **JSON validé** au format attendu.

> C'est l'archi « chef d'orchestre » du cours : **Java** pour la logique sensible
> (clé API, préprompt, validation), **Flutter** pour l'expérience.

---

## 🎯 Pourquoi un backend ?
- **Sécurité** : la clé API du LLM ne quitte jamais le serveur (jamais dans l'app).
- **Maîtrise** : le préprompt est versionné côté serveur, pas dans le client.
- **Fiabilité** : le JSON du LLM est nettoyé et validé avant d'être renvoyé.

## 🧱 Architecture
```
src/main/java/com/goodmaps/backend/
├── GoodMapsBackendApplication.java   # Point d'entrée Spring Boot
├── config/
│   ├── LlmProperties.java            # Config LLM (clé via variable d'env)
│   ├── CorsConfig.java               # Autorise l'app Flutter web
│   └── ServiceConfig.java            # Choisit Mock ou Anthropic selon la clé
├── controller/
│   └── SuggestionController.java     # POST /api/suggestions, GET /api/health
├── dto/
│   ├── UserProfileRequest.java       # = UserProfile côté Dart
│   ├── Suggestion.java               # = Suggestion côté Dart (schéma JSON)
│   └── SuggestionsResponse.java      # { "suggestions": [...] }
├── service/
│   ├── SuggestionService.java        # Interface
│   ├── PromptBuilder.java            # Le préprompt (cf. docs/PREPROMPT.md)
│   ├── MockSuggestionService.java    # Démo sans clé API
│   └── AnthropicSuggestionService.java # Appel réel + parsing + validation
└── exception/
    └── GlobalExceptionHandler.java   # Réponses d'erreur propres (JSON)
```

## ✅ Prérequis
- **Java 17+** (testé avec JDK 21)
- **Maven 3.9+**

## 🚀 Démarrage

Le backend choisit son moteur via `llm.provider` (variable `LLM_PROVIDER`) :
**openai** (Groq / Gemini / OpenRouter / Ollama), **anthropic** (Claude) ou
**mock**. Par défaut : `openai` pointant sur **Groq** (gratuit).

```bash
cd backend

# Mode MOCK (aucune clé, démarre direct)
LLM_PROVIDER=mock mvn spring-boot:run

# Mode réel : voir « Tester gratuitement » juste en dessous
mvn spring-boot:run
```
Le serveur écoute sur **http://localhost:8080**.

## 🆓 Tester gratuitement (sans payer de clé)

`OpenAiCompatibleSuggestionService` fonctionne avec tout fournisseur compatible
OpenAI. Choisis-en un, exporte les variables, puis `mvn spring-boot:run` :

**Groq** — gratuit, sans carte (défaut). Clé : https://console.groq.com
```bash
export LLM_API_KEY=gsk_xxx
mvn spring-boot:run
```

**Google Gemini** — gratuit, sans carte. Clé : https://aistudio.google.com
```bash
export LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai
export LLM_MODEL=gemini-2.0-flash
export LLM_API_KEY=AIzaxxx
mvn spring-boot:run
```

**Ollama** — local, aucune clé. Après `ollama pull llama3.2` :
```bash
export LLM_BASE_URL=http://localhost:11434/v1
export LLM_MODEL=llama3.2
mvn spring-boot:run
```

**Claude** — payant :
```bash
export LLM_PROVIDER=anthropic
export LLM_BASE_URL=https://api.anthropic.com
export LLM_MODEL=claude-sonnet-4-6
export LLM_API_KEY=sk-ant-xxx
mvn spring-boot:run
```
> Au démarrage, le log indique le fournisseur actif (ou « MOCK » si aucune clé).
> Quota gratuit dépassé → l'API renvoie HTTP 429, sans facturation.

### Tester l'API
```bash
# Santé
curl http://localhost:8080/api/health

# Suggestions
curl -X POST http://localhost:8080/api/suggestions \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Alex","mobilityNeed":"Fauteuil roulant","interests":"Musées","companionship":"En famille","city":"Paris","maxDistanceKm":5}'
```
Réponse :
```json
{ "suggestions": [ { "id": "1", "title": "Visite de l'Opéra Garnier", ... } ] }
```

## 🔌 Connecter l'app Flutter
Dans `lib/main.dart` (côté app), remplacer le mock par le backend :
```dart
Provider<AiSuggestionService>(
  create: (_) => BackendAiSuggestionService(baseUrl: 'http://10.0.2.2:8080'),
)
```
Adresse selon la cible :
| Cible | baseUrl |
|---|---|
| Émulateur Android | `http://10.0.2.2:8080` (10.0.2.2 = localhost de la machine hôte) |
| Web / desktop / iOS simulateur | `http://localhost:8080` |
| Téléphone physique | `http://<IP-LAN-de-votre-PC>:8080` |

Le contrat est déjà aligné : l'app envoie `UserProfile.toJson()`, le backend
répond `{ "suggestions": [...] }` mappé 1:1 sur le modèle Dart `Suggestion`.

## 🔐 Sécurité
- Clé API lue depuis `ANTHROPIC_API_KEY` (variable d'env), **jamais commitée**
  (`.gitignore` exclut `.env`). Voir `.env.example`.
- CORS : `*` en POC → **restreindre** aux origines réelles en production
  (`CorsConfig.java`).

## 🧠 Le préprompt (POC : JSON bien formaté)
`PromptBuilder.java` impose un **schéma JSON strict** au LLM (interdiction de
texte libre, `null` explicites). Objectif : une réponse directement parsable et
limiter les hallucinations de format. Détails dans `docs/PREPROMPT.md` (côté app).

## 🧪 Tests
```bash
mvn test
```
Couvre la construction du préprompt et le service mock.

## 🗒️ Pistes d'amélioration
- Mise en cache des suggestions par profil.
- Validation Bean Validation sur les entrées.
- Choix multi-fournisseur (OpenAI, Mistral…) derrière la même interface.

---

## 📊 Correspondance avec le barème
| Critère | Où le retrouver |
|---|---|
| **Méthodologie** (préprompt) | `PromptBuilder.java`, `docs/PREPROMPT.md` |
| **Complétude** (README) | ce fichier |
| **Structure, maintenabilité, sécurité** | couches config/controller/dto/service, interface + 2 impls, clé API côté serveur |
| **Maîtrise de la stack** | Spring Boot 3, records Java, RestClient, Jackson, JUnit |
