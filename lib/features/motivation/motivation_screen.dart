import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';

class MotivationScreen extends ConsumerStatefulWidget {
  const MotivationScreen({super.key});

  @override
  ConsumerState<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends ConsumerState<MotivationScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

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
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
    setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyQuoteProvider);
    final allAsync = ref.watch(quotesProvider);
    final voiceEnabled = ref.watch(voiceEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Motivation')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quote of the day
                  dailyAsync.when(
                    data: (quote) => _QuoteOfDayCard(
                      quote: quote.text,
                      author: quote.author,
                      onSpeak: voiceEnabled
                          ? () => _speak('"${quote.text}" by ${quote.author}')
                          : null,
                      speaking: _speaking,
                    ),
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, _) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),
                  const PPSectionTitle(
                    title: 'All Quotes',
                    subtitle: 'Daily inspiration for your fitness journey',
                  ),
                  const SizedBox(height: 12),

                  // All quotes list
                  allAsync.when(
                    data: (quotes) => Column(
                      children: quotes
                          .map((q) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _QuoteCard(
                          text: q.text,
                          author: q.author,
                        ),
                      ))
                          .toList(),
                    ),
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
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

class _QuoteOfDayCard extends StatelessWidget {
  final String quote;
  final String author;
  final VoidCallback? onSpeak;
  final bool speaking;

  const _QuoteOfDayCard({
    required this.quote,
    required this.author,
    this.onSpeak,
    required this.speaking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined,
                        color: AppTheme.accentLight, size: 14),
                    SizedBox(width: 6),
                    Text('Quote of the Day',
                        style: TextStyle(
                            color: AppTheme.accentLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (onSpeak != null)
                GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      speaking ? Icons.stop : Icons.volume_up,
                      color: AppTheme.accent,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Icon(Icons.format_quote,
              color: AppTheme.accent, size: 32),
          const SizedBox(height: 10),
          Text(
            quote,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text('— $author',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;
  final String author;

  const _QuoteCard({required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return PPCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote,
              color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.4)),
                const SizedBox(height: 6),
                Text('— $author',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}