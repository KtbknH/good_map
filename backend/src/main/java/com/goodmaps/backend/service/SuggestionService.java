package com.goodmaps.backend.service;

import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;

/**
 * Contrat du service de suggestions (mock ou LLM reel).
 */
public interface SuggestionService {

    SuggestionsResponse getSuggestions(UserProfileRequest profile);
}
