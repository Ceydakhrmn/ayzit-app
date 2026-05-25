import 'package:flutter/material.dart';
import '../../widgets/pregnancy/growth_garden_card.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Büyüme Bahçem',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bebeğinle birlikte her hafta büyüyorsun.',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 24),
            const GrowthGardenCard(),
          ],
        ),
      ),
    );
  }
}
