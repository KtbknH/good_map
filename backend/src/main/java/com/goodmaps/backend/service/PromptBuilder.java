package com.goodmaps.backend.service;

import com.goodmaps.backend.dto.UserProfileRequest;
import org.springframework.stereotype.Component;

/**
 * Construit le preprompt envoye au LLM (cf. docs/PREPROMPT.md).
 * Versionne dans le code = sortie du "prompt gambling" (methodo du cours).
 */
@Component
public class PromptBuilder {

    /** Preprompt systeme : impose un JSON strict, directement parsable. */
    public String systemPrompt() {
        return """
                Tu es le moteur de recommandation de "Good Maps", une application qui propose
                des activites ADAPTEES aux personnes a mobilite reduite (PMR) et a d'autres
                besoins d'accessibilite.

                Regles ABSOLUES :
                1. Tu reponds UNIQUEMENT avec un objet JSON valide, sans texte autour,
                   sans bloc Markdown, sans commentaire.
                2. Le JSON respecte EXACTEMENT ce schema :
                {
                  "suggestions": [
                    {
                      "id": "string",
                      "title": "string",
                      "description": "string (2 a 3 phrases, mentionne l'accessibilite)",
                      "latitude": number,
                      "longitude": number,
                      "openingInfo": "string (ex: 'Ouvert maintenant et jusqu'a 18h')",
                      "isAccessiblePmr": boolean,
                      "bookingUrl": "string|null",
                      "phoneNumber": "string|null"
                    }
                  ]
                }
                3. Tu proposes entre 3 et 5 activites, toutes reellement accessibles.
                4. Les coordonnees sont coherentes avec la ville / la position fournie.
                5. Si une info est inconnue, mets null (jamais de valeur inventee).
                """;
    }

    /** Preprompt utilisateur : rempli a partir du profil + position. */
    public String userPrompt(UserProfileRequest p) {
        return """
                Profil de l'utilisateur :
                - Prenom : %s
                - Besoin de mobilite : %s
                - Centres d'interet : %s
                - Accompagnement : %s
                - Ville / point de depart : %s
                - Distance maximale : %s km
                - Coordonnees GPS de depart : %s

                Propose des activites adaptees a ce profil, dans le rayon indique.
                Si des coordonnees GPS sont fournies, privilegie la proximite immediate.
                """.formatted(
                nz(p.firstName()),
                nz(p.mobilityNeed()),
                nz(p.interests()),
                nz(p.companionship()),
                nz(p.city()),
                p.maxDistanceKm() == null ? "5" : p.maxDistanceKm().toString(),
                coords(p)
        );
    }

    private String nz(String value) {
        return (value == null || value.isBlank()) ? "non precise" : value;
    }

    private String coords(UserProfileRequest p) {
        if (p.latitude() == null || p.longitude() == null) {
            return "non precise";
        }
        return p.latitude() + ", " + p.longitude();
    }
}
