import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/providers.dart';
import '../bmi_calculator/bmi_screen.dart';
import '../diet/diet_screen.dart';
import '../workout/workout_screen.dart';
import '../water_tracker/water_tracker_screen.dart';
import '../step_counter/step_counter_screen.dart';
import '../cardio/cardio_screen.dart';
import '../progress/progress_screen.dart';
import '../motivation/motivation_screen.dart';
import '../settings/settings_screen.dart';
export '../../ads/ads_service.dart' show PPBannerAd;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    AdsService.instance.tryShowInterstitial();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(dailyQuoteProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PowerPeak 💪',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: AppTheme.accentLight,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your fitness companion',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _navigate(context, const SettingsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings,
                              color: AppTheme.accent, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quote of the day
                  quoteAsync.when(
                    data: (q) => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_quote,
                                  color: AppTheme.accent, size: 16),
                              SizedBox(width: 6),
                              Text('Quote of the Day',
                                  style: TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(q.text,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic)),
                          const SizedBox(height: 4),
                          Text('— ${q.author}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Banner Ad ─────────────────────────────────────────────
            const Align(
              alignment: Alignment.center,
              child: PPBannerAd(),
            ),

            // ── Feature Grid ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _FeatureGrid(onNavigate: _navigate),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final void Function(BuildContext, Widget) onNavigate;

  const _FeatureGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        title: 'BMI & Calories',
        icon: Icons.monitor_weight_outlined,
        color: const Color(0xFFD4A054),
        screen: const BmiScreen(),
      ),
      _Feature(
        title: 'Diet Plans',
        icon: Icons.restaurant_menu,
        color: const Color(0xFF81C784),
        screen: const DietScreen(),
      ),
      _Feature(
        title: 'Workout',
        icon: Icons.fitness_center,
        color: const Color(0xFFEF9A9A),
        screen: const WorkoutScreen(),
      ),
      _Feature(
        title: 'Water Tracker',
        icon: Icons.water_drop_outlined,
        color: const Color(0xFF64B5F6),
        screen: const WaterTrackerScreen(),
      ),
      _Feature(
        title: 'Step Counter',
        icon: Icons.directions_walk,
        color: const Color(0xFFA5D6A7),
        screen: const StepCounterScreen(),
      ),
      _Feature(
        title: 'Cardio',
        icon: Icons.directions_run,
        color: const Color(0xFFFFCC80),
        screen: const CardioScreen(),
      ),
      _Feature(
        title: 'Progress',
        icon: Icons.show_chart,
        color: const Color(0xFFCE93D8),
        screen: const ProgressScreen(),
      ),
      _Feature(
        title: 'Motivation',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFFFF176),
        screen: const MotivationScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        final f = features[i];
        return _FeatureTile(feature: f, onTap: () => onNavigate(context, f.screen));
      },
    );
  }
}

class _Feature {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _Feature({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final VoidCallback onTap;

  const _FeatureTile({required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: feature.color.withOpacity(0.25), width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(feature.icon, color: feature.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Re-export for convenience
