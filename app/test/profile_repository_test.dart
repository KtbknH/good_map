import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:goodmaps_app/models/user_profile.dart';
import 'package:goodmaps_app/services/profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ProfileRepository : save puis load restitue le profil', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ProfileRepository();

    expect(await repo.load(), isNull);

    const profile = UserProfile(
      firstName: 'Alex',
      city: 'Paris',
      maxDistanceKm: 3,
    );
    await repo.save(profile);

    final loaded = await repo.load();
    expect(loaded, isNotNull);
    expect(loaded!.firstName, 'Alex');
    expect(loaded.city, 'Paris');
    expect(loaded.maxDistanceKm, 3);
  });
}
