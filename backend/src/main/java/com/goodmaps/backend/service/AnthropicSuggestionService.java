package com.goodmaps.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goodmaps.backend.config.LlmProperties;
import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

/**
 * Implementation reelle : appelle l'API Anthropic (Claude) avec le preprompt,
 * puis parse et valide le JSON renvoye.
 *
 * La cle API est portee cote serveur uniquement (securite du barème).
 */
public class AnthropicSuggestionService implements SuggestionService {

    private final LlmProperties props;
    private final PromptBuilder promptBuilder;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    public AnthropicSuggestionService(LlmProperties props,
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
                "system", promptBuilder.systemPrompt(),
                "messages", List.of(Map.of(
                        "role", "user",
                        "content", promptBuilder.userPrompt(profile)
                ))
        );

        AnthropicResponse response = restClient.post()
                .uri("/v1/messages")
                .header("x-api-key", props.getApiKey())
                .header("anthropic-version", props.getAnthropicVersion())
                .header("content-type", "application/json")
                .body(body)
                .retrieve()
                .body(AnthropicResponse.class);

        String json = extractText(response);
        return parseSuggestions(json);
    }

    private String extractText(AnthropicResponse response) {
        if (response == null || response.content() == null || response.content().isEmpty()) {
            throw new IllegalStateException("Reponse vide du LLM.");
        }
        return response.content().stream()
                .filter(block -> "text".equals(block.type()))
                .map(AnthropicResponse.ContentBlock::text)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Aucun bloc texte dans la reponse du LLM."));
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

    /** DTO interne pour la reponse de l'API Anthropic. */
    public record AnthropicResponse(List<ContentBlock> content) {
        public record ContentBlock(String type, String text) {
        }
    }
}
