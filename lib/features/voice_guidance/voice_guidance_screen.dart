import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class VoiceGuidanceScreen extends ConsumerStatefulWidget {
  const VoiceGuidanceScreen({super.key});

  @override
  ConsumerState<VoiceGuidanceScreen> createState() =>
      _VoiceGuidanceScreenState();
}

class _VoiceGuidanceScreenState extends ConsumerState<VoiceGuidanceScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  double _rate = 0.5;
  double _pitch = 1.0;

  static const _samplePhrases = [
    'Get ready for your workout!',
    'Push-ups — 3 sets of 10 reps',
    'Rest for 60 seconds',
    'Stay hydrated. Drink water now.',
    'Great job! One more set to go.',
    'Cool down. Take a deep breath.',
    'Workout complete. You crushed it!',
  ];

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.speak(text);
    setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final voiceEnabled = ref.watch(voiceEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Guidance')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable/disable toggle
                  PPCard(
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over,
                            color: AppTheme.accent),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Voice Guidance',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  'Hear exercise names, rest countdowns & tips',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch(
                          value: voiceEnabled,
                          onChanged: (_) =>
                              ref.read(voiceEnabledProvider.notifier).toggle(),
                          activeColor: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Voice settings
                  PPCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Voice Settings',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Speed',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)),
                            Text('${(_rate * 100).round()}%',
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Slider(
                          value: _rate,
                          min: 0.25,
                          max: 1.0,
                          divisions: 15,
                          onChanged: (v) => setState(() => _rate = v),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pitch',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)),
                            Text(_pitch.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Slider(
                          value: _pitch,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          onChanged: (v) => setState(() => _pitch = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const PPSectionTitle(
                    title: 'Test Phrases',
                    subtitle: 'Tap any phrase to hear it spoken',
                  ),
                  const SizedBox(height: 12),

                  ..._samplePhrases.map(
                    (phrase) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PPCard(
                        onTap: voiceEnabled ? () => _speak(phrase) : null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              color: voiceEnabled
                                  ? AppTheme.accent
                                  : AppTheme.textHint,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(phrase,
                                  style: TextStyle(
                                      color: voiceEnabled
                                          ? AppTheme.textPrimary
                                          : AppTheme.textHint,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!voiceEnabled)
                    PPCard(
                      child: Row(
                        children: const [
                          Icon(Icons.volume_off, color: AppTheme.warning),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Voice guidance is disabled. Enable it above to use voice features.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13),
                            ),
                          ),
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
