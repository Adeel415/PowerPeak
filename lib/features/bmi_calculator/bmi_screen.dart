import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class BmiScreen extends ConsumerStatefulWidget {
  const BmiScreen({super.key});

  @override
  ConsumerState<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends ConsumerState<BmiScreen> {
  final _weightCtrl = TextEditingController(text: '70');
  final _heightCtrl = TextEditingController(text: '170');
  final _ageCtrl = TextEditingController(text: '25');
  String _gender = 'male';
  String _activity = 'moderate';

  final _activities = {
    'sedentary': 'Sedentary (desk job)',
    'light': 'Light (1-3 days/week)',
    'moderate': 'Moderate (3-5 days)',
    'active': 'Active (6-7 days)',
    'very_active': 'Very Active (2x/day)',
  };

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final height = double.tryParse(_heightCtrl.text) ?? 0;
    final age = int.tryParse(_ageCtrl.text) ?? 0;

    if (weight <= 0 || height <= 0 || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values')),
      );
      return;
    }

    ref.read(bmiProvider.notifier).calculate(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
      activityLevel: _activity,
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppTheme.success;
    if (bmi < 30) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final bmiState = ref.watch(bmiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('BMI & Calorie Calculator')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inputs
                  PPCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _weightCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  suffixText: 'kg',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _heightCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Height (cm)',
                                  suffixText: 'cm',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ageCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  suffixText: 'yrs',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PPDropdown<String>(
                                label: 'Gender',
                                value: _gender,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'male', child: Text('Male')),
                                  DropdownMenuItem(
                                      value: 'female', child: Text('Female')),
                                ],
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PPDropdown<String>(
                          label: 'Activity Level',
                          value: _activity,
                          items: _activities.entries
                              .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) => setState(() => _activity = v!),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calculate'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results
                  if (bmiState.bmi != null) ...[
                    const SizedBox(height: 20),
                    const PPSectionTitle(title: 'Your Results'),
                    const SizedBox(height: 12),

                    // BMI card
                    PPCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                bmiState.bmi!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: _bmiColor(bmiState.bmi!),
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BMI',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                      _bmiColor(bmiState.bmi!).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bmiState.category!,
                                      style: TextStyle(
                                        color: _bmiColor(bmiState.bmi!),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              PPStatChip(
                                label: 'Maintain',
                                value:
                                '${bmiState.maintenance!.round()} kcal',
                                color: AppTheme.accent,
                              ),
                              PPStatChip(
                                label: 'Fat Loss',
                                value: '${bmiState.fatLoss!.round()} kcal',
                                color: AppTheme.error,
                              ),
                              PPStatChip(
                                label: 'Muscle Gain',
                                value:
                                '${bmiState.muscleGain!.round()} kcal',
                                color: AppTheme.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BMI scale info
                    PPCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BMI Scale',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          _BmiScaleRow(
                              label: 'Underweight', range: '< 18.5', color: Colors.blue),
                          _BmiScaleRow(
                              label: 'Normal',
                              range: '18.5 – 24.9',
                              color: AppTheme.success),
                          _BmiScaleRow(
                              label: 'Overweight',
                              range: '25 – 29.9',
                              color: AppTheme.warning),
                          _BmiScaleRow(
                              label: 'Obese',
                              range: '≥ 30',
                              color: AppTheme.error),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiScaleRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _BmiScaleRow({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13)),
          const Spacer(),
          Text(range,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}