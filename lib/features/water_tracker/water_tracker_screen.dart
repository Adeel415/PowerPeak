import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final water = ref.watch(waterProvider);
    final progress = water.progress;
    final percentage = (progress * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Big water circle
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 14,
                            backgroundColor: AppTheme.surfaceLight,
                            color: progress >= 1.0
                                ? AppTheme.success
                                : const Color(0xFF64B5F6),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.water_drop,
                                  color: Color(0xFF64B5F6), size: 32),
                              const SizedBox(height: 4),
                              Text(
                                '${water.currentMl}',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'of ${water.goalMl} ml',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: progress >= 1.0
                                      ? AppTheme.success.withOpacity(0.2)
                                      : const Color(0xFF64B5F6)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  progress >= 1.0
                                      ? 'Goal Met! 🎉'
                                      : '$percentage%',
                                  style: TextStyle(
                                    color: progress >= 1.0
                                        ? AppTheme.success
                                        : const Color(0xFF64B5F6),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Add water buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _WaterButton(
                        label: '+100 ml',
                        icon: Icons.local_drink_outlined,
                        onTap: () => ref
                            .read(waterProvider.notifier)
                            .addWater(100),
                      ),
                      _WaterButton(
                        label: '+250 ml',
                        icon: Icons.water_drop,
                        highlighted: true,
                        onTap: () => ref
                            .read(waterProvider.notifier)
                            .addWater(AppConstants.waterIncrementMl),
                      ),
                      _WaterButton(
                        label: '+500 ml',
                        icon: Icons.local_cafe_outlined,
                        onTap: () => ref
                            .read(waterProvider.notifier)
                            .addWater(500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Goal setter
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily Goal',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          'Adjust your daily water intake target',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: water.goalMl.toDouble(),
                          min: 1000,
                          max: 5000,
                          divisions: 16,
                          label: '${water.goalMl} ml',
                          onChanged: (v) => ref
                              .read(waterProvider.notifier)
                              .setGoal(v.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('1000 ml',
                                style: TextStyle(
                                    color: AppTheme.textHint, fontSize: 11)),
                            Text(
                              '${water.goalMl} ml',
                              style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            const Text('5000 ml',
                                style: TextStyle(
                                    color: AppTheme.textHint, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tips
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                color: AppTheme.accent, size: 18),
                            SizedBox(width: 8),
                            Text('Hydration Tips',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...[
                          'Drink a glass of water first thing in the morning',
                          'Keep a water bottle at your desk',
                          'Drink water 30 min before meals to reduce appetite',
                          'Add lemon or mint for flavor without calories',
                        ].map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle,
                                  size: 5, color: AppTheme.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(tip,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reset
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('Reset Water',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          content: const Text(
                              'Reset today\'s water intake to 0?',
                              style:
                              TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(waterProvider.notifier)
                                    .reset();
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh,
                        color: AppTheme.textSecondary),
                    label: const Text('Reset today',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _WaterButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    const waterBlue = Color(0xFF64B5F6);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: highlighted
              ? waterBlue.withOpacity(0.2)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted
                ? waterBlue
                : AppTheme.cardBorder,
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: highlighted ? waterBlue : AppTheme.textSecondary,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: highlighted ? waterBlue : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}