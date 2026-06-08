package com.goodmaps.backend.controller;

import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;
import com.goodmaps.backend.service.SuggestionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class SuggestionController {

    private final SuggestionService suggestionService;

    public SuggestionController(SuggestionService suggestionService) {
        this.suggestionService = suggestionService;
    }

    @PostMapping("/suggestions")
    public SuggestionsResponse suggestions(@RequestBody UserProfileRequest profile) {
        return suggestionService.getSuggestions(profile);
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }
}
