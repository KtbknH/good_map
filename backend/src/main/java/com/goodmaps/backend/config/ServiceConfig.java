package com.goodmaps.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goodmaps.backend.service.AnthropicSuggestionService;
import com.goodmaps.backend.service.MockSuggestionService;
import com.goodmaps.backend.service.OpenAiCompatibleSuggestionService;
import com.goodmaps.backend.service.PromptBuilder;
import com.goodmaps.backend.service.SuggestionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Choisit l'implementation du service selon `llm.provider` :
 *   - openai    : fournisseur compatible OpenAI (Groq, Gemini, OpenRouter, Ollama)
 *   - anthropic : Claude
 *   - mock      : donnees de demonstration
 *
 * Sans cle (et hors Ollama local), on retombe sur le mock pour que l'app
 * tourne quand meme.
 */
@Configuration
public class ServiceConfig {

    private static final Logger log = LoggerFactory.getLogger(ServiceConfig.class);

    @Bean
    public SuggestionService suggestionService(LlmProperties props,
                                               PromptBuilder promptBuilder,
                                               ObjectMapper objectMapper) {
        final String provider = props.getProvider() == null
                ? "" : props.getProvider().trim().toLowerCase();
        final boolean hasKey = props.getApiKey() != null && !props.getApiKey().isBlank();

        switch (provider) {
            case "mock":
                log.warn("provider=mock -> service MOCK actif (donnees de demo).");
                return new MockSuggestionService();

            case "anthropic":
                if (!hasKey) {
                    log.warn("provider=anthropic mais cle absente -> service MOCK actif.");
                    return new MockSuggestionService();
                }
                log.info("provider=anthropic -> Claude actif, modele={}", props.getModel());
                return new AnthropicSuggestionService(props, promptBuilder, objectMapper);

            default: // "openai" (Groq / Gemini / OpenRouter / Ollama)
                final String url = props.getBaseUrl() == null ? "" : props.getBaseUrl();
                final boolean local = url.contains("localhost")
                        || url.contains("127.0.0.1") || url.contains("11434");
                if (!hasKey && !local) {
                    log.warn("provider=openai mais cle absente -> service MOCK actif. "
                            + "Definissez LLM_API_KEY (Groq/Gemini) ou utilisez Ollama en local.");
                    return new MockSuggestionService();
                }
                log.info("provider=openai -> fournisseur compatible OpenAI actif "
                        + "(base={}, modele={}).", props.getBaseUrl(), props.getModel());
                return new OpenAiCompatibleSuggestionService(props, promptBuilder, objectMapper);
        }
    }
}
