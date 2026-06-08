import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helpers d'ouverture d'URL et d'appel téléphonique.
///
/// Isolés du widget pour rester réutilisables et garder `SuggestionCard`
/// concentré sur l'affichage (séparation des responsabilités).

/// Ouvre une URL dans le navigateur / une app externe.
Future<void> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _showError(context, 'Lien invalide.');
    return;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) _showError(context, "Impossible d'ouvrir le lien.");
  } catch (_) {
    if (!context.mounted) return;
    _showError(context, "Impossible d'ouvrir le lien.");
  }
}

/// Lance l'appel téléphonique vers [phoneNumber].
Future<void> dialPhoneNumber(BuildContext context, String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    final ok = await launchUrl(uri);
    if (!context.mounted) return;
    if (!ok) _showError(context, "Impossible de lancer l'appel.");
  } catch (_) {
    if (!context.mounted) return;
    _showError(context, "Impossible de lancer l'appel.");
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
