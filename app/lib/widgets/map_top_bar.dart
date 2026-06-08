import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'good_maps_logo.dart';

/// Barre supérieure de l'écran carte : réglages | logo | infos
/// (maquette écran 3).
class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key, this.onSettings, this.onInfo});

  final VoidCallback? onSettings;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIcon(icon: Icons.tune, onTap: onSettings),
          const GoodMapsLogo(fontSize: 20),
          _CircleIcon(icon: Icons.info_outline, onTap: onInfo),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Icon(icon, color: AppColors.ink, size: 22),
      ),
    );
  }
}
