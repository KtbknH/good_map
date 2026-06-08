import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Logo « GOOD MAPS » (wordmark + épingle).
///
/// Remplace temporairement l'asset officiel (assets/images/logo.png) :
/// dès que le PNG/SVG sera ajouté, on pourra l'utiliser ici sans rien
/// changer dans les écrans qui consomment ce widget.
class GoodMapsLogo extends StatelessWidget {
  const GoodMapsLogo({
    super.key,
    this.fontSize = 22,
    this.showSubtitle = false,
    this.showIcon = true,
  });

  final double fontSize;
  final bool showSubtitle;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.location_on,
                color: AppColors.coral,
                size: fontSize * 1.3,
              ),
              const SizedBox(width: 4),
            ],
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
                children: const [
                  TextSpan(
                    text: 'GOOD ',
                    style: TextStyle(color: AppColors.coral),
                  ),
                  TextSpan(
                    text: 'MAPS',
                    style: TextStyle(color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 6),
          Text(
            "SUGGESTIONS D'ACTIVITÉS ADAPTÉES",
            style: TextStyle(
              fontSize: fontSize * 0.4,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}
