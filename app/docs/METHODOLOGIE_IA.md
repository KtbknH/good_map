# Méthodologie IA

Document répondant au critère **« Méthodologie (outils IA utilisés, préprompt) »**
du barème (page 20 du support de cours).

## Outils IA utilisés
| Étape | Outil | Rôle |
|-------|-------|------|
| Génération de structure & code | Claude (Anthropic) | Squelette, modèles, widgets — précis sur le code (cf. cours) |
| Autocomplétion en édition | GitHub Copilot dans VS Code | Complétion ligne à ligne pendant l'écriture |
| Audit / refactor du repo | Cursor | Relecture globale, cohérence des conventions |
| Génération du JSON (POC) | LLM via backend | Suggestions formatées (voir PREPROMPT.md) |

## Démarche (méthode cartésienne)
Conformément au cours (« découper un problème complexe en plus petits simples »),
le projet a été découpé en briques indépendantes :
1. **Thème & constantes** (le socle visuel)
2. **Modèles** (le contrat de données = le JSON du POC)
3. **Service IA** (abstraction + mock + implémentation backend)
4. **Providers** (état isolé de l'UI)
5. **Widgets** réutilisables, puis **écrans** qui les assemblent

Chaque brique est compréhensible et testable seule → on reste « chef
d'orchestre » et non simple copieur de code généré.

## Bonnes pratiques anti-"prompt gambling"
- Préprompt **versionné** dans le repo (docs/PREPROMPT.md), pas improvisé.
- Schéma JSON **imposé** → réponse directement parsable.
- Revue humaine systématique du code généré (les outils ne sont pas autonomes).
- Clé API **hors du client** (sécurité, critère du barème).

## Limites assumées (cf. cours)
- L'IA simule sans comprendre : la pertinence des suggestions reste à vérifier.
- Pas de compréhension fine des besoins utilisateurs → le formulaire
  d'onboarding sert justement à cadrer la demande.
