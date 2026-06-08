package com.goodmaps.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goodmaps.backend.service.AnthropicSuggestionService;
import com.goodmaps.backend.service.MockSuggestionService;
import com.goodmaps.backend.service.PromptBuilder;
import com.goodmaps.backend.service.SuggestionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Choisit l'implementation du service selon la presence de la cle API.
 * Sans cle -> mock (l'app tourne immediatement). Avec cle -> Claude.
 */
@Configuration
public class ServiceConfig {

    private static final Logger log = LoggerFactory.getLogger(ServiceConfig.class);

    @Bean
    public SuggestionService suggestionService(LlmProperties props,
                                               PromptBuilder promptBuilder,
                                               ObjectMapper objectMapper) {
        if (props.getApiKey() == null || props.getApiKey().isBlank()) {
            log.warn("ANTHROPIC_API_KEY absente -> service MOCK active (donnees de demo).");
            return new MockSuggestionService();
        }
        log.info("Cle API detectee -> service Anthropic (Claude) active, modele={}", props.getModel());
        return new AnthropicSuggestionService(props, promptBuilder, objectMapper);
    }
}
