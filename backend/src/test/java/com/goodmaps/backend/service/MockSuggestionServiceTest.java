package com.goodmaps.backend.service;

import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MockSuggestionServiceTest {

    private final MockSuggestionService service = new MockSuggestionService();

    @Test
    void returnsAccessibleSuggestions() {
        SuggestionsResponse response = service.getSuggestions(new UserProfileRequest(
                "Alex", "", "", "", "Paris", 5.0, null, null));
        assertFalse(response.suggestions().isEmpty());
        assertTrue(response.suggestions().stream().allMatch(s -> s.isAccessiblePmr()));
    }
}
