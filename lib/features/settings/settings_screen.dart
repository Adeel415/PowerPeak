import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';
import '../../data/models/models.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'male';
  String _activity = 'moderate';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _weightCtrl.text = profile.weightKg.toString();
      _heightCtrl.text = profile.heightCm.toString();
      _ageCtrl.text = profile.age.toString();
      _gender = profile.gender;
      _activity = profile.activityLevel;
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    final a = int.tryParse(_ageCtrl.text);
    if (w == null || h == null || a == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }
    ref.read(userProfileProvider.notifier).save(
      UserProfile(
        weightKg: w,
        heightCm: h,
        age: a,
        gender: _gender,
        activityLevel: _activity,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved ✓'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voiceEnabled = ref.watch(voiceEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile
                  const PPSectionTitle(
                    title: 'My Profile',
                    subtitle: 'Used for calculations across the app',
                  ),
                  const SizedBox(height: 12),
                  PPCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _weightCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
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
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
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
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
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
                                      value: 'female',
                                      child: Text('Female')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _gender = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PPDropdown<String>(
                          label: 'Activity Level',
                          value: _activity,
                          items: const [
                            DropdownMenuItem(
                                value: 'sedentary',
                                child: Text('Sedentary')),
                            DropdownMenuItem(
                                value: 'light', child: Text('Light')),
                            DropdownMenuItem(
                                value: 'moderate',
                                child: Text('Moderate')),
                            DropdownMenuItem(
                                value: 'active', child: Text('Active')),
                            DropdownMenuItem(
                                value: 'very_active',
                                child: Text('Very Active')),
                          ],
                          onChanged: (v) =>
                              setState(() => _activity = v!),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences
                  const PPSectionTitle(title: 'Preferences'),
                  const SizedBox(height: 12),

                  PPCard(
                    child: Column(
                      children: [
                        // Voice guidance toggle
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over,
                                color: AppTheme.accent),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('Voice Guidance',
                                      style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      'Speak exercise names & rest timers',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(
                              value: voiceEnabled,
                              onChanged: (_) => ref
                                  .read(voiceEnabledProvider.notifier)
                                  .toggle(),
                              activeColor: AppTheme.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App info
                  const PPSectionTitle(title: 'About'),
                  const SizedBox(height: 12),
                  PPCard(
                    child: Column(
                      children: [
                        _InfoRow(
                            icon: Icons.apps,
                            label: 'App Name',
                            value: 'PowerPeak'),
                        const Divider(height: 20),
                        _InfoRow(
                            icon: Icons.tag,
                            label: 'Version',
                            value: '1.0.0'),
                        const Divider(height: 20),
                        _InfoRow(
                            icon: Icons.wifi_off,
                            label: 'Mode',
                            value: 'Fully Offline'),
                        const Divider(height: 20),
                        _InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Focus',
                            value: 'Fat Loss · Muscle Gain'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ],
    );
  }
}