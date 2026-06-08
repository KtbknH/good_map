import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/user_profile.dart';
import 'providers/onboarding_provider.dart';
import 'providers/suggestions_provider.dart';
import 'services/ai_suggestion_service.dart';
import 'services/profile_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement du profil sauvegardé avant le démarrage de l'UI.
  final profileRepository = ProfileRepository();
  final UserProfile? savedProfile = await profileRepository.load();

  runApp(
    MultiProvider(
      providers: [
        // Service injecté. Par défaut : un mock (démo hors-ligne).
        // À remplacer par BackendAiSuggestionService une fois le backend
        // Spring Boot déployé (la clé API reste alors côté serveur).
        Provider<AiSuggestionService>(
          create: (_) => MockAiSuggestionService(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(
            repository: profileRepository,
            initialProfile: savedProfile,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SuggestionsProvider(context.read<AiSuggestionService>()),
        ),
      ],
      child: const GoodMapsApp(),
    ),
  );
}
