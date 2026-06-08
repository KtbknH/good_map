import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_form_field.dart';
import 'map_screen.dart';

/// Écran 2 (maquette) : formulaire « Bienvenue ! » de personnalisation.
/// Pré-rempli si un profil existe ; persiste à la validation.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _mobility;
  late final TextEditingController _interests;
  late final TextEditingController _companionship;
  late final TextEditingController _city;
  late final TextEditingController _distance;

  @override
  void initState() {
    super.initState();
    final p = context.read<OnboardingProvider>().profile;
    _firstName = TextEditingController(text: p.firstName);
    _mobility = TextEditingController(text: p.mobilityNeed);
    _interests = TextEditingController(text: p.interests);
    _companionship = TextEditingController(text: p.companionship);
    _city = TextEditingController(text: p.city);
    _distance = TextEditingController(text: _formatDistance(p.maxDistanceKm));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _mobility.dispose();
    _interests.dispose();
    _companionship.dispose();
    _city.dispose();
    _distance.dispose();
    super.dispose();
  }

  String _formatDistance(double d) =>
      d == d.truncateToDouble() ? d.toInt().toString() : d.toString();

  Future<void> _goToMap() async {
    final onboarding = context.read<OnboardingProvider>();
    final navigator = Navigator.of(context);
    // copyWith pour préserver d'éventuelles coordonnées déjà présentes.
    final profile = onboarding.profile.copyWith(
      firstName: _firstName.text.trim(),
      mobilityNeed: _mobility.text.trim(),
      interests: _interests.text.trim(),
      companionship: _companionship.text.trim(),
      city: _city.text.trim(),
      maxDistanceKm: double.tryParse(_distance.text.trim()) ?? 5,
    );
    await onboarding.complete(profile);
    if (!mounted) return;
    if (navigator.canPop()) {
      navigator.pop(); // ouvert depuis la carte (édition) -> retour
    } else {
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MapScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Bienvenue !',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _goToMap,
                        icon: const Icon(Icons.close),
                        tooltip: 'Passer',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    "Pour mieux personnaliser vos suggestions d'activités, "
                    'merci de remplir ce formulaire.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ProfileFormField(label: 'Prénom', controller: _firstName),
                  ProfileFormField(
                    label: 'Besoin de mobilité (ex : fauteuil roulant)',
                    controller: _mobility,
                  ),
                  ProfileFormField(
                    label: "Centres d'intérêt",
                    controller: _interests,
                  ),
                  ProfileFormField(
                    label: 'Accompagnement (seul, en famille…)',
                    controller: _companionship,
                  ),
                  ProfileFormField(
                    label: 'Ville / point de départ',
                    controller: _city,
                  ),
                  ProfileFormField(
                    label: 'Distance max (km)',
                    controller: _distance,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Passer à la carte',
                    onPressed: _goToMap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
