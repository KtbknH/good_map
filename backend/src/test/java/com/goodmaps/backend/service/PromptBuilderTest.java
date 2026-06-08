package com.goodmaps.backend.service;

import com.goodmaps.backend.dto.UserProfileRequest;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class PromptBuilderTest {

    private final PromptBuilder promptBuilder = new PromptBuilder();

    @Test
    void userPromptContainsProfileFields() {
        UserProfileRequest profile = new UserProfileRequest(
                "Alex", "Fauteuil roulant", "Musees", "En famille", "Paris",
                5.0, null, null);
        String prompt = promptBuilder.userPrompt(profile);
        assertTrue(prompt.contains("Alex"));
        assertTrue(prompt.contains("Fauteuil roulant"));
        assertTrue(prompt.contains("Paris"));
    }

    @Test
    void userPromptIncludesCoordinatesWhenProvided() {
        UserProfileRequest profile = new UserProfileRequest(
                "Alex", "", "", "", "Paris", 5.0, 48.8566, 2.3522);
        String prompt = promptBuilder.userPrompt(profile);
        assertTrue(prompt.contains("48.8566"));
    }

    @Test
    void systemPromptImposesJsonSchema() {
        String system = promptBuilder.systemPrompt();
        assertTrue(system.contains("suggestions"));
        assertTrue(system.contains("isAccessiblePmr"));
        assertTrue(system.toLowerCase().contains("json"));
    }

    @Test
    void blankFieldsBecomePlaceholder() {
        UserProfileRequest profile = new UserProfileRequest(
                "", null, "", "", "", null, null, null);
        String prompt = promptBuilder.userPrompt(profile);
        assertTrue(prompt.contains("non precise"));
    }
}
