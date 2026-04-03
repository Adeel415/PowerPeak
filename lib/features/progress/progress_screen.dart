import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';
import '../../data/models/models.dart';

import 'dart:ui' as ui;
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  void _addEntry() {
    final w = double.tryParse(_weightCtrl.text);
    if (w == null || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight')),
      );
      return;
    }
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    ref.read(progressProvider.notifier).addEntry(w, today);
    _weightCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weight Progress')),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add entry card
                  PPCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                                color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(
                                  Icons.monitor_weight_outlined,
                                  color: AppTheme.accent),
                              suffixText: 'kg',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addEntry,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (entries.isEmpty)
                    PPCard(
                      child: Column(
                        children: [
                          const Icon(Icons.show_chart,
                              color: AppTheme.textHint, size: 48),
                          const SizedBox(height: 12),
                          Text('No entries yet',
                              style:
                              Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          const Text(
                            'Add your first weight entry to start tracking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Stats summary
                    Row(
                      children: [
                        Expanded(
                          child: PPStatChip(
                            label: 'Current',
                            value:
                            '${entries.last.weightKg.toStringAsFixed(1)} kg',
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PPStatChip(
                            label: 'Starting',
                            value:
                            '${entries.first.weightKg.toStringAsFixed(1)} kg',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ChangeChip(entries: entries),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Lightweight chart
                    const PPSectionTitle(title: 'Weight Chart'),
                    const SizedBox(height: 12),
                    PPCard(
                      child: SizedBox(
                        height: 180,
                        child: _WeightLineChart(entries: entries),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // History list
                    const PPSectionTitle(title: 'History'),
                    const SizedBox(height: 10),
                    ...entries.reversed.toList().asMap().entries.map((e) {
                      final i = entries.length - 1 - e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PPCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                    Icons.monitor_weight_outlined,
                                    color: AppTheme.accent,
                                    size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${entry.weightKg.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16)),
                                    Text(entry.date,
                                        style: const TextStyle(
                                            color: AppTheme.textHint,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppTheme.error, size: 20),
                                onPressed: () => ref
                                    .read(progressProvider.notifier)
                                    .removeEntry(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
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

class _ChangeChip extends StatelessWidget {
  final List<WeightEntry> entries;

  const _ChangeChip({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const PPStatChip(
          label: 'Change', value: '—', color: AppTheme.textHint);
    }
    final change = entries.last.weightKg - entries.first.weightKg;
    final isLoss = change < 0;
    return PPStatChip(
      label: 'Change',
      value: '${isLoss ? '' : '+'}${change.toStringAsFixed(1)} kg',
      color: isLoss ? AppTheme.success : AppTheme.error,
    );
  }
}

// Lightweight custom chart — no external chart library
class _WeightLineChart extends StatelessWidget {
  final List<WeightEntry> entries;

  const _WeightLineChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const Center(
        child: Text('Add at least 2 entries to see chart',
            style: TextStyle(color: AppTheme.textHint, fontSize: 13)),
      );
    }

    return CustomPaint(
      painter: _ChartPainter(entries),
      size: Size.infinite,
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  _ChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final weights = entries.map((e) => e.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b) - 1;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 1;
    final range = maxW - minW;

    final n = entries.length;
    final xStep = size.width / (n - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.cardBorder.withOpacity(0.5)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line path
    final linePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppTheme.accent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final x = i * xStep;
      final y = size.height -
          ((weights[i] - minW) / range) * (size.height * 0.85) -
          size.height * 0.05;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      // Smooth curve
      final cp1 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i].dy,
      );
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Dots
    final dotPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppTheme.surface
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 5, dotBorder);
      canvas.drawCircle(pt, 3.5, dotPaint);
    }

    // Labels on first/last



  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.entries != entries;
}