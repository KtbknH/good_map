package com.goodmaps.backend.dto;

import java.util.List;

/**
 * Enveloppe renvoyee a l'app : { "suggestions": [ ... ] }.
 */
public record SuggestionsResponse(List<Suggestion> suggestions) {
}
