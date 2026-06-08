import 'package:flutter/foundation.dart';

import '../models/suggestion.dart';
import '../models/user_profile.dart';
import '../services/ai_suggestion_service.dart';

/// État des suggestions : pilote le chargement, les erreurs et la sélection
/// courante. Découple totalement l'UI de la source de données.
class SuggestionsProvider extends ChangeNotifier {
  SuggestionsProvider(this._service);

  final AiSuggestionService _service;

  List<Suggestion> _suggestions = const [];
  Suggestion? _selected;
  bool _loading = false;
  String? _error;

  List<Suggestion> get suggestions => _suggestions;
  Suggestion? get selected => _selected;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchSuggestions(UserProfile profile) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _suggestions = await _service.fetchSuggestions(profile);
      _selected = _suggestions.isNotEmpty ? _suggestions.first : null;
    } catch (e) {
      _error = 'Impossible de charger les suggestions. Réessayez.';
      if (kDebugMode) debugPrint(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void select(Suggestion suggestion) {
    _selected = suggestion;
    notifyListeners();
  }
}
