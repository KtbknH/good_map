import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/launcher.dart';
import '../models/suggestion.dart';

/// Carte d'une suggestion (maquette écran 3) : titre, description, horaires,
/// actions « Réservez en ligne » / « Appelez maintenant », et disclaimer IA.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key, required this.suggestion});

  final Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          suggestion.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          suggestion.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (suggestion.openingInfo.isNotEmpty)
          Text(
            suggestion.openingInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (suggestion.bookingUrl != null)
              _ActionButton(
                icon: Icons.add_circle_outline,
                label: 'Réservez\nen ligne',
                onTap: () => openExternalUrl(context, suggestion.bookingUrl!),
              ),
            if (suggestion.phoneNumber != null)
              _ActionButton(
                icon: Icons.play_circle_outline,
                label: 'Appelez\nmaintenant',
                onTap: () => dialPhoneNumber(context, suggestion.phoneNumber!),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          "L'IA peut faire des erreurs. Envisagez de vérifier les "
          "informations importantes.",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.coral, size: 40),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.coral, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
