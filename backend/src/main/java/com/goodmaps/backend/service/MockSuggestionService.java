package com.goodmaps.backend.service;

import com.goodmaps.backend.dto.Suggestion;
import com.goodmaps.backend.dto.SuggestionsResponse;
import com.goodmaps.backend.dto.UserProfileRequest;

import java.util.List;

/**
 * Donnees statiques : permet de demarrer le backend sans cle API.
 */
public class MockSuggestionService implements SuggestionService {

    @Override
    public SuggestionsResponse getSuggestions(UserProfileRequest profile) {
        return new SuggestionsResponse(List.of(
                new Suggestion(
                        "1",
                        "Visite de l'Opera Garnier",
                        "Explorez l'Opera Garnier et son architecture magnifique avec "
                                + "des installations pour les PMR.",
                        48.8719, 2.3316,
                        "Ouvert maintenant et jusqu'a 18h",
                        true,
                        "https://www.operadeparis.fr",
                        "+33171252423"
                ),
                new Suggestion(
                        "2",
                        "Musee du Louvre",
                        "Le plus grand musee du monde, accessible : ascenseurs, fauteuils "
                                + "en pret et parcours adaptes aux personnes a mobilite reduite.",
                        48.8606, 2.3376,
                        "Ouvert de 9h a 18h",
                        true,
                        "https://www.louvre.fr",
                        "+33140205317"
                ),
                new Suggestion(
                        "3",
                        "Jardin des Tuileries",
                        "Une promenade accessible au coeur de Paris : allees larges, "
                                + "surfaces planes et bancs nombreux pour les pauses.",
                        48.8635, 2.3275,
                        "Ouvert maintenant et jusqu'a 21h",
                        true,
                        null,
                        null
                )
        ));
    }
}
