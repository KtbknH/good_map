import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/suggestion.dart';
import '../models/user_profile.dart';

/// Contrat du service de suggestions.
///
/// L'UI ne dépend QUE de cette abstraction. On bascule entre le mock
/// (démo hors-ligne) et l'implémentation réelle (backend) sans rien changer
/// dans les écrans : c'est le cœur de la maintenabilité de l'app.
abstract class AiSuggestionService {
  Future<List<Suggestion>> fetchSuggestions(UserProfile profile);
}

/// Implémentation de démonstration : données statiques, aucune clé requise.
/// Permet de lancer l'app immédiatement après un `flutter run`.
class MockAiSuggestionService implements AiSuggestionService {
  @override
  Future<List<Suggestion>> fetchSuggestions(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const [
      Suggestion(
        id: '1',
        title: "Visite de l'Opéra Garnier",
        description:
            "Explorez l'Opéra Garnier et son architecture magnifique avec "
            "des installations pour les PMR.",
        latitude: 48.8719,
        longitude: 2.3316,
        openingInfo: "Ouvert maintenant et jusqu'à 18h",
        isAccessiblePmr: true,
        bookingUrl: 'https://www.operadeparis.fr',
        phoneNumber: '+33171252423',
      ),
      Suggestion(
        id: '2',
        title: 'Musée du Louvre',
        description:
            "Le plus grand musée du monde, accessible : ascenseurs, fauteuils "
            "en prêt et parcours adaptés aux personnes à mobilité réduite.",
        latitude: 48.8606,
        longitude: 2.3376,
        openingInfo: 'Ouvert de 9h à 18h',
        isAccessiblePmr: true,
        bookingUrl: 'https://www.louvre.fr',
        phoneNumber: '+33140205317',
      ),
      Suggestion(
        id: '3',
        title: 'Jardin des Tuileries',
        description:
            "Une promenade accessible au cœur de Paris : allées larges, "
            "surfaces planes et bancs nombreux pour les pauses.",
        latitude: 48.8635,
        longitude: 2.3275,
        openingInfo: "Ouvert maintenant et jusqu'à 21h",
        isAccessiblePmr: true,
      ),
    ];
  }
}

/// Implémentation réelle : interroge le backend (Spring Boot) qui détient la
/// clé API et construit le préprompt (cf. docs/PREPROMPT.md).
///
/// NB : non câblée par défaut (voir lib/main.dart). Code prêt à l'emploi dès
/// que le backend expose `POST {baseUrl}/api/suggestions`.
class BackendAiSuggestionService implements AiSuggestionService {
  BackendAiSuggestionService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<Suggestion>> fetchSuggestions(UserProfile profile) async {
    final uri = Uri.parse('$baseUrl/api/suggestions');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Échec de la récupération des suggestions (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items =
        (decoded['suggestions'] as List<dynamic>).cast<Map<String, dynamic>>();
    return items.map(Suggestion.fromJson).toList();
  }
}
