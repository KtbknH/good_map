import 'package:geolocator/geolocator.dart';

/// Gère l'obtention de la position de l'appareil, permissions comprises.
/// Renvoie `null` si le service est désactivé ou la permission refusée
/// (l'app reste fonctionnelle, le backend retombe sur la ville saisie).
class LocationService {
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }
}
