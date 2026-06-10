package com.goodmaps.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goodmaps.backend.config.LlmProperties;
import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

/**
 * Implementation pour TOUT fournisseur compatible OpenAI :
 * Groq, Google Gemini (mode compat), OpenRouter, Ollama (local), etc.
 *
 * Un seul code : on change l'URL, la cle et le modele dans application.yml.
 * C'est l'interet de l'abstraction SuggestionService : zero impact ailleurs.
 *
 * Format OpenAI : POST {baseUrl}/chat/completions, en-tete Authorization: Bearer,
 * reponse dans choices[0].message.content.
 */
public class OpenAiCompatibleSuggestionService implements SuggestionService {

    private final LlmProperties props;
    private final PromptBuilder promptBuilder;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    public OpenAiCompatibleSuggestionService(LlmProperties props,
                                             PromptBuilder promptBuilder,
                                             ObjectMapper objectMapper) {
        this.props = props;
        this.promptBuilder = promptBuilder;
        this.objectMapper = objectMapper;
        this.restClient = RestClient.builder()
                .baseUrl(props.getBaseUrl())
                .build();
    }

    @Override
    public SuggestionsResponse getSuggestions(UserProfileRequest profile) {
        Map<String, Object> body = Map.of(
                "model", props.getModel(),
                "max_tokens", props.getMaxTokens(),
                "messages", List.of(
                        Map.of("role", "system", "content", promptBuilder.systemPrompt()),
                        Map.of("role", "user", "content", promptBuilder.userPrompt(profile))
                )
        );

        RestClient.RequestBodySpec request = restClient.post()
                .uri("/chat/completions")
                .header("content-type", "application/json");

        // Ollama (local) n'exige pas de cle : on n'ajoute l'en-tete que si presente.
        if (props.getApiKey() != null && !props.getApiKey().isBlank()) {
            request = request.header("Authorization", "Bearer " + props.getApiKey());
        }

        OpenAiResponse response = request
                .body(body)
                .retrieve()
                .body(OpenAiResponse.class);

        String json = extractText(response);
        return parseSuggestions(json);
    }

    private String extractText(OpenAiResponse response) {
        if (response == null || response.choices() == null || response.choices().isEmpty()) {
            throw new IllegalStateException("Reponse vide du LLM.");
        }
        OpenAiResponse.Message message = response.choices().get(0).message();
        if (message == null || message.content() == null || message.content().isBlank()) {
            throw new IllegalStateException("Contenu vide dans la reponse du LLM.");
        }
        return message.content();
    }

    private SuggestionsResponse parseSuggestions(String raw) {
        String cleaned = stripFences(raw);
        try {
            SuggestionsResponse parsed = objectMapper.readValue(cleaned, SuggestionsResponse.class);
            if (parsed.suggestions() == null || parsed.suggestions().isEmpty()) {
                throw new IllegalStateException("Le LLM n'a renvoye aucune suggestion.");
            }
            return parsed;
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("JSON du LLM invalide : " + e.getMessage(), e);
        }
    }

    /** Defense anti-"bullshit" : retire d'eventuels fences Markdown. */
    private String stripFences(String value) {
        String t = value.trim();
        if (t.startsWith("```")) {
            t = t.replaceFirst("^```(json)?", "").trim();
            if (t.endsWith("```")) {
                t = t.substring(0, t.length() - 3).trim();
            }
        }
        return t;
    }

    /** DTO interne pour la reponse "chat completions" (format OpenAI). */
    public record OpenAiResponse(List<Choice> choices) {
        public record Choice(Message message) {
        }

        public record Message(String role, String content) {
        }
    }
}
