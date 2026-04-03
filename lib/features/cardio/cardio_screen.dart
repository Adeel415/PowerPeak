import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class CardioScreen extends ConsumerStatefulWidget {
  const CardioScreen({super.key});

  @override
  ConsumerState<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends ConsumerState<CardioScreen> {
  int _minutes = 30;
  double _weight = 70;

  static const _activities = [
    _CardioActivity('Running', Icons.directions_run, 8.0, Color(0xFFEF9A9A)),
    _CardioActivity('Cycling', Icons.directions_bike, 6.0, Color(0xFF80CBC4)),
    _CardioActivity('Walking', Icons.directions_walk, 3.5, Color(0xFFA5D6A7)),
    _CardioActivity('Jump Rope', Icons.sports_gymnastics, 11.0, Color(0xFFFFCC80)),
    _CardioActivity('Swimming', Icons.pool, 7.0, Color(0xFF64B5F6)),
    _CardioActivity('Skipping', Icons.sports_handball, 10.0, Color(0xFFCE93D8)),
  ];

  int _selectedActivity = 0;

  double get _calories =>
      _activities[_selectedActivity].met * _weight * (_minutes / 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardio Tracker')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity selector
                  const PPSectionTitle(title: 'Choose Activity'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _activities.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (ctx, i) {
                      final act = _activities[i];
                      final selected = _selectedActivity == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedActivity = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: selected
                                ? act.color.withOpacity(0.2)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? act.color
                                  : AppTheme.cardBorder,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(act.icon,
                                  color: selected
                                      ? act.color
                                      : AppTheme.textSecondary,
                                  size: 26),
                              const SizedBox(height: 6),
                              Text(
                                act.name,
                                style: TextStyle(
                                  color: selected
                                      ? act.color
                                      : AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Duration
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Duration',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            Text('$_minutes min',
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18)),
                          ],
                        ),
                        Slider(
                          value: _minutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          label: '$_minutes min',
                          onChanged: (v) =>
                              setState(() => _minutes = v.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('5 min',
                                style: TextStyle(
                                    color: AppTheme.textHint, fontSize: 11)),
                            Text('120 min',
                                style: TextStyle(
                                    color: AppTheme.textHint, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Weight
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your Weight',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            Text('${_weight.round()} kg',
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18)),
                          ],
                        ),
                        Slider(
                          value: _weight,
                          min: 40,
                          max: 150,
                          divisions: 110,
                          label: '${_weight.round()} kg',
                          onChanged: (v) => setState(() => _weight = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Result
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.8),
                          AppTheme.primaryLight.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _activities[_selectedActivity].name,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_calories.round()}',
                          style: const TextStyle(
                            color: AppTheme.accentLight,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text('calories burned',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoPill(
                                label: '$_minutes min',
                                icon: Icons.timer_outlined),
                            const SizedBox(width: 12),
                            _InfoPill(
                                label: '${_weight.round()} kg',
                                icon: Icons.monitor_weight_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // MET info
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppTheme.accent, size: 16),
                            SizedBox(width: 8),
                            Text('About MET Calculations',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Calories are estimated using Metabolic Equivalent (MET) values. '
                              'Actual burn varies with fitness level, terrain, and intensity.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardioActivity {
  final String name;
  final IconData icon;
  final double met;
  final Color color;

  const _CardioActivity(this.name, this.icon, this.met, this.color);
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.accent, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}