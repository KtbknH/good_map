import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/profile_repository.dart';

/// État de l'onboarding : conserve le profil, le persiste et l'expose au reste
/// de l'app (notamment à l'écran carte pour personnaliser la requête IA).
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    required ProfileRepository repository,
    UserProfile? initialProfile,
  })  : _repository = repository,
        _profile = initialProfile ?? const UserProfile(),
        _completed = initialProfile != null;

  final ProfileRepository _repository;
  UserProfile _profile;
  bool _completed;

  UserProfile get profile => _profile;
  bool get completed => _completed;

  /// Mise à jour en mémoire (ex : enrichissement par la géolocalisation).
  void update(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Valide l'onboarding et persiste le profil.
  Future<void> complete(UserProfile profile) async {
    _profile = profile;
    _completed = true;
    await _repository.save(profile);
    notifyListeners();
  }
}
