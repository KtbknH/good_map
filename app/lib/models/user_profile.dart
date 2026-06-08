/// Profil utilisateur saisi à l'onboarding (écran « Bienvenue ! »).
///
/// Ces champs personnalisent le préprompt envoyé à l'IA. Les coordonnées
/// (latitude/longitude) sont renseignées au runtime par la géolocalisation
/// pour cibler des activités réellement proches.
class UserProfile {
  final String firstName;
  final String mobilityNeed;
  final String interests;
  final String companionship;
  final String city;
  final double maxDistanceKm;
  final double? latitude;
  final double? longitude;

  const UserProfile({
    this.firstName = '',
    this.mobilityNeed = '',
    this.interests = '',
    this.companionship = '',
    this.city = '',
    this.maxDistanceKm = 5,
    this.latitude,
    this.longitude,
  });

  UserProfile copyWith({
    String? firstName,
    String? mobilityNeed,
    String? interests,
    String? companionship,
    String? city,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      mobilityNeed: mobilityNeed ?? this.mobilityNeed,
      interests: interests ?? this.interests,
      companionship: companionship ?? this.companionship,
      city: city ?? this.city,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String? ?? '',
      mobilityNeed: json['mobilityNeed'] as String? ?? '',
      interests: json['interests'] as String? ?? '',
      companionship: json['companionship'] as String? ?? '',
      city: json['city'] as String? ?? '',
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble() ?? 5,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'mobilityNeed': mobilityNeed,
        'interests': interests,
        'companionship': companionship,
        'city': city,
        'maxDistanceKm': maxDistanceKm,
        'latitude': latitude,
        'longitude': longitude,
      };
}
