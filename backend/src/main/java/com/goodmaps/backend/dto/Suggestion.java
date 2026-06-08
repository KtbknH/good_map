package com.goodmaps.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Une suggestion d'activite. Reflete EXACTEMENT le modele Dart `Suggestion`
 * et le schema JSON impose au LLM (cf. PromptBuilder / docs/PREPROMPT.md).
 *
 * @JsonProperty force le nom "isAccessiblePmr" (Jackson renommerait sinon un
 * booleen "isX" en "x"), garantissant l'alignement avec l'app Flutter.
 */
public record Suggestion(
        String id,
        String title,
        String description,
        double latitude,
        double longitude,
        String openingInfo,
        @JsonProperty("isAccessiblePmr") boolean isAccessiblePmr,
        String bookingUrl,
        String phoneNumber
) {
}
