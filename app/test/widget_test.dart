import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goodmaps_app/models/suggestion.dart';
import 'package:goodmaps_app/models/user_profile.dart';
import 'package:goodmaps_app/services/ai_suggestion_service.dart';
import 'package:goodmaps_app/widgets/suggestion_card.dart';

void main() {
  test('MockAiSuggestionService renvoie des suggestions adaptées', () async {
    final service = MockAiSuggestionService();
    final result = await service.fetchSuggestions(const UserProfile());
    expect(result, isNotEmpty);
    expect(result.first.isAccessiblePmr, isTrue);
  });

  test('Suggestion.fromJson parse correctement un JSON', () {
    final json = {
      'id': '42',
      'title': 'Opéra Garnier',
      'description': 'Visite accessible',
      'latitude': 48.8719,
      'longitude': 2.3316,
      'openingInfo': "Ouvert jusqu'à 18h",
      'isAccessiblePmr': true,
    };
    final s = Suggestion.fromJson(json);
    expect(s.id, '42');
    expect(s.title, 'Opéra Garnier');
    expect(s.isAccessiblePmr, isTrue);
  });

  test('UserProfile : round-trip toJson/fromJson conserve les données', () {
    const profile = UserProfile(
      firstName: 'Alex',
      mobilityNeed: 'Fauteuil roulant',
      city: 'Paris',
      maxDistanceKm: 3,
      latitude: 48.8566,
      longitude: 2.3522,
    );
    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.firstName, 'Alex');
    expect(restored.mobilityNeed, 'Fauteuil roulant');
    expect(restored.maxDistanceKm, 3);
    expect(restored.latitude, 48.8566);
  });

  testWidgets('SuggestionCard affiche le titre de la suggestion',
      (tester) async {
    const suggestion = Suggestion(
      id: '1',
      title: 'Test Opéra',
      description: 'Description de test',
      latitude: 48.87,
      longitude: 2.33,
      openingInfo: 'Ouvert',
      isAccessiblePmr: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SuggestionCard(suggestion: suggestion)),
      ),
    );

    expect(find.text('Test Opéra'), findsOneWidget);
  });
}
