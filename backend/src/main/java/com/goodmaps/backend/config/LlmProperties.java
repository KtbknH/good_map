package com.goodmaps.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Configuration du LLM, alimentée par application.yml / variables d'env.
 * La clé API n'est jamais codée en dur : c'est le coeur de la sécurité.
 *
 * provider :
 *   - "openai"    -> fournisseur compatible OpenAI (Groq, Gemini, OpenRouter, Ollama)
 *   - "anthropic" -> Claude (API Anthropic)
 *   - "mock"      -> données de démonstration
 */
@ConfigurationProperties(prefix = "llm")
public class LlmProperties {

    private String provider = "openai";
    private String apiKey = "";
    private String model = "claude-sonnet-4-6";
    private String baseUrl = "https://api.anthropic.com";
    private int maxTokens = 1024;
    private String anthropicVersion = "2023-06-01";

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public int getMaxTokens() {
        return maxTokens;
    }

    public void setMaxTokens(int maxTokens) {
        this.maxTokens = maxTokens;
    }

    public String getAnthropicVersion() {
        return anthropicVersion;
    }

    public void setAnthropicVersion(String anthropicVersion) {
        this.anthropicVersion = anthropicVersion;
    }
}
