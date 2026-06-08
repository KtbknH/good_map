import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/good_maps_logo.dart';
import 'map_screen.dart';
import 'welcome_screen.dart';

/// Écran 1 (maquette) : logo centré, puis redirection.
/// Si un profil est déjà sauvegardé, on va directement à la carte.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    final completed = context.read<OnboardingProvider>().completed;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => completed ? const MapScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: GoodMapsLogo(fontSize: 30, showSubtitle: true),
      ),
    );
  }
}
