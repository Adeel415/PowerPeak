import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class StepCounterScreen extends ConsumerStatefulWidget {
  const StepCounterScreen({super.key});

  @override
  ConsumerState<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends ConsumerState<StepCounterScreen> {
  final _stepsCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _stepsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepState = ref.watch(stepProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Step Counter')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: PPStatChip(
                          label: 'Steps',
                          value: stepState.steps.toString(),
                          color: const Color(0xFFA5D6A7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PPStatChip(
                          label: 'Calories',
                          value: stepState.calories.toStringAsFixed(0),
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PPStatChip(
                          label: 'Distance',
                          value:
                          '${stepState.distanceKm.toStringAsFixed(2)} km',
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Progress towards 10k goal
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily Goal: 10,000 Steps',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 14),
                        PPProgressBar(
                          value: stepState.steps / 10000,
                          label: '${stepState.steps} steps',
                          trailing:
                          '${((stepState.steps / 10000) * 100).round()}%',
                          color: const Color(0xFFA5D6A7),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          stepState.steps >= 10000
                              ? '🎉 Goal achieved! Great work!'
                              : '${10000 - stepState.steps} steps remaining',
                          style: TextStyle(
                            color: stepState.steps >= 10000
                                ? AppTheme.success
                                : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Manual input
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PPSectionTitle(
                          title: 'Enter Steps',
                          subtitle: 'Type or adjust your step count manually',
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _stepsCtrl,
                          keyboardType: TextInputType.number,
                          style:
                          const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Steps today',
                            prefixIcon: Icon(Icons.directions_walk,
                                color: AppTheme.accent),
                          ),
                          onChanged: (v) {
                            final steps = int.tryParse(v) ?? 0;
                            ref
                                .read(stepProvider.notifier)
                                .setSteps(steps);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quick add row
                        const Text('Quick Add:',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [1000, 2000, 5000, 8000].map((amount) {
                            return GestureDetector(
                              onTap: () {
                                final current =
                                    ref.read(stepProvider).steps;
                                final newVal = current + amount;
                                ref
                                    .read(stepProvider.notifier)
                                    .setSteps(newVal);
                                _stepsCtrl.text = newVal.toString();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.cardBorder),
                                ),
                                child: Text('+$amount',
                                    style: const TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        TextButton.icon(
                          onPressed: () {
                            ref.read(stepProvider.notifier).setSteps(0);
                            _stepsCtrl.text = '0';
                          },
                          icon: const Icon(Icons.refresh,
                              color: AppTheme.textHint, size: 18),
                          label: const Text('Reset',
                              style:
                              TextStyle(color: AppTheme.textHint)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Health facts
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                color: AppTheme.accent, size: 18),
                            SizedBox(width: 8),
                            Text('Did You Know?',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...[
                          '10,000 steps ≈ 5 km / 400–500 calories',
                          'Walking after meals helps control blood sugar',
                          'Just 30 min of walking reduces heart disease risk by 35%',
                          'Every 2,000 steps = ~1 km walked',
                        ].map((fact) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle,
                                  size: 5,
                                  color: AppTheme.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(fact,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}