/// Constantes d'espacement (échelle 4 px) pour une mise en page homogène.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Rayons d'arrondi réutilisables.
abstract class AppRadii {
  static const double card = 16;
  static const double button = 10;
  static const double field = 8;
}

/// Chemins des assets.
abstract class AppAssets {
  static const String logo = 'assets/images/logo.png';
}

/// Coordonnées par défaut (Paris) tant que la géolocalisation n'est pas branchée.
abstract class AppGeo {
  static const double defaultLat = 48.8566;
  static const double defaultLng = 2.3522;
}
