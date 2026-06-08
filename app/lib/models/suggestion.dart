/// Modèle d'une suggestion d'activité.
///
/// Reflète exactement le JSON renvoyé par l'IA (cf. docs/PREPROMPT.md).
/// Le POC du cours = « récupérer un JSON bien formaté » : ce modèle est
/// le point de contrôle de cette exigence.
class Suggestion {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String openingInfo;
  final bool isAccessiblePmr;
  final String? bookingUrl;
  final String? phoneNumber;

  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.openingInfo,
    required this.isAccessiblePmr,
    this.bookingUrl,
    this.phoneNumber,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      openingInfo: json['openingInfo'] as String? ?? '',
      isAccessiblePmr: json['isAccessiblePmr'] as bool? ?? false,
      bookingUrl: json['bookingUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'openingInfo': openingInfo,
        'isAccessiblePmr': isAccessiblePmr,
        'bookingUrl': bookingUrl,
        'phoneNumber': phoneNumber,
      };
}
