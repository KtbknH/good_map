import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../providers/suggestions_provider.dart';
import '../services/location_service.dart';
import '../widgets/map_top_bar.dart';
import '../widgets/map_view.dart';
import '../widgets/primary_button.dart';
import '../widgets/suggestion_card.dart';
import 'welcome_screen.dart';

/// Écran 3 (maquette) : barre + carte + bouton + carte de suggestion.
/// Récupère la position de l'appareil pour centrer la carte et cibler l'IA.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    final onboarding = context.read<OnboardingProvider>();
    final position = await _locationService.getCurrentLocation();
    if (!mounted || position == null) return;
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
    // Enrichit le profil pour que le backend cible la zone réelle.
    onboarding.update(
      onboarding.profile.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  void _openProfileEditor() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('À propos de Good Maps'),
        content: const Text(
          "Good Maps propose des activités adaptées aux personnes à mobilité "
          "réduite, personnalisées selon votre profil et votre position.\n\n"
          "Les suggestions sont générées par une IA : vérifiez les "
          "informations importantes (horaires, accessibilité) avant de vous "
          "déplacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuggestionsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MapTopBar(onSettings: _openProfileEditor, onInfo: _showInfo),
            const Divider(height: 1),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: MapView(
                  suggestions: provider.suggestions,
                  selectedId: provider.selected?.id,
                  onPinTap: provider.select,
                  userLocation: _userLocation,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      label: 'Obtenir des suggestions',
                      loading: provider.loading,
                      onPressed: () => context
                          .read<SuggestionsProvider>()
                          .fetchSuggestions(
                            context.read<OnboardingProvider>().profile,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildContent(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SuggestionsProvider provider) {
    if (provider.error != null) {
      return Text(
        provider.error!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.coral),
      );
    }
    final selected = provider.selected;
    if (selected == null) {
      return const Text(
        'Appuyez sur « Obtenir des suggestions » pour découvrir des '
        'activités adaptées près de vous.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return SuggestionCard(suggestion: selected);
  }
}
