package com.goodmaps.backend.dto;

/**
 * Profil recu de l'app Flutter (memes cles que UserProfile.toJson cote Dart).
 * latitude/longitude sont fournis par la geolocalisation (peuvent etre null).
 */
public record UserProfileRequest(
        String firstName,
        String mobilityNeed,
        String interests,
        String companionship,
        String city,
        Double maxDistanceKm,
        Double latitude,
        Double longitude
) {
}
