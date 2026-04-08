import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';
   // ─── Main Screen ────────────────────────────────────────────────────────────

class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final water = ref.watch(waterProvider);
    final progress = water.progress.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final goalMet = progress >= 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Water Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const PPBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // ── Animated wave circle ──
                  _AnimatedWaterBall(
                    progress: progress,
                    currentMl: water.currentMl,
                    goalMl: water.goalMl,
                    percentage: percentage,
                    goalMet: goalMet,
                  ),

                  const SizedBox(height: 36),

                  // ── Add-water buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _WaterButton(
                        label: '+100 ml',
                        icon: Icons.local_drink_outlined,
                        onTap: () =>
                            ref.read(waterProvider.notifier).addWater(100),
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
                        onTap: () =>
                            ref.read(waterProvider.notifier).addWater(500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Goal slider ──
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.track_changes,
                                  color: Color(0xFF64B5F6), size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Daily Goal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Adjust your daily water intake target',
                          style: TextStyle(
                              color: Color(0xFF90A4AE), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFF64B5F6),
                            inactiveTrackColor:
                            const Color(0xFF64B5F6).withOpacity(0.2),
                            thumbColor: Colors.white,
                            overlayColor:
                            const Color(0xFF64B5F6).withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                            trackHeight: 5,
                          ),
                          child: Slider(
                            value: water.goalMl.toDouble(),
                            min: 1000,
                            max: 5000,
                            divisions: 16,
                            label: '${water.goalMl} ml',
                            onChanged: (v) => ref
                                .read(waterProvider.notifier)
                                .setGoal(v.round()),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('1 L',
                                style: TextStyle(
                                    color: Color(0xFF78909C), fontSize: 11)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF64B5F6)
                                        .withOpacity(0.4),
                                    width: 1),
                              ),
                              child: Text(
                                '${water.goalMl} ml',
                                style: const TextStyle(
                                  color: Color(0xFF64B5F6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Text('5 L',
                                style: TextStyle(
                                    color: Color(0xFF78909C), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Hydration tips ──
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFFFA726).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.tips_and_updates,
                                  color: Color(0xFFFFA726), size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Hydration Tips',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ..._tips.map((tip) => _TipRow(tip: tip)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Reset ──
                  TextButton.icon(
                    onPressed: () => _showResetDialog(context, ref),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF78909C),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset today',
                        style: TextStyle(fontSize: 13)),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _tips = [
    'Drink a glass of water first thing in the morning',
    'Keep a water bottle at your desk',
    'Drink water 30 min before meals to reduce appetite',
    'Add lemon or mint for flavor without no calories',
  ];

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Water',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text("Reset today's water intake to 0?",
            style: TextStyle(color: Color(0xFF90A4AE))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF78909C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.read(waterProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Reset',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Wave Ball ──────────────────────────────────────────────────────

class _AnimatedWaterBall extends StatefulWidget {
  final double progress;
  final int currentMl;
  final int goalMl;
  final int percentage;
  final bool goalMet;

  const _AnimatedWaterBall({
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    required this.percentage,
    required this.goalMet,
  });

  @override
  State<_AnimatedWaterBall> createState() => _AnimatedWaterBallState();
}

class _AnimatedWaterBallState extends State<_AnimatedWaterBall>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _fillCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fillAnim;
  late Animation<double> _pulseAnim;

  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lastProgress = widget.progress;
    _fillAnim =
        Tween<double>(begin: _lastProgress, end: _lastProgress).animate(
          CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
        );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedWaterBall old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _fillAnim = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(
          CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic));
      _lastProgress = widget.progress;
      _fillCtrl
        ..reset()
        ..forward();

      // Pulse on add
      _pulseCtrl.forward(from: 0).then((_) => _pulseCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _fillCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveCtrl, _fillAnim, _pulseAnim]),
      builder: (_, __) {
        final fill = _fillAnim.value.clamp(0.0, 1.0);
        final scale = _pulseAnim.value;

        return Column(
          children: [
            Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _WavePainter(
                    progress: fill,
                    wavePhase: _waveCtrl.value,
                    goalMet: widget.goalMet,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: fill < 0.6
                              ? const Color(0xFF64B5F6)
                              : Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(
                              begin: 0, end: widget.currentMl),
                          duration:
                          const Duration(milliseconds: 600),
                          builder: (_, val, __) => Text(
                            '$val',
                            style: TextStyle(
                              color: fill < 0.55
                                  ? Colors.white
                                  : Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        Text(
                          'of ${widget.goalMl} ml',
                          style: TextStyle(
                            color: fill < 0.6
                                ? const Color(0xFF90A4AE)
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 400),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.goalMet
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.goalMet
                                ? 'Goal Met!'
                                : '${widget.percentage}%',
                            style: TextStyle(
                              color: widget.goalMet
                                  ? Colors.greenAccent
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Wave Painter ────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final bool goalMet;

  _WavePainter(
      {required this.progress,
        required this.wavePhase,
        required this.goalMet});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Clip to circle
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 2)));

    // Dark background
    canvas.drawCircle(
        center, radius, Paint()..color = const Color(0xFF0D2137));

    // Water fill
    final waterTop = size.height * (1 - progress);
    final waveHeight = 10.0;
    final waveLength = size.width;

    final path1 = Path();
    path1.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          waveHeight *
              sin((x / waveLength * 2 * pi) + wavePhase * 2 * pi);
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.close();

    final path2 = Path();
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          waveHeight * 0.6 *
              sin((x / waveLength * 2 * pi) +
                  wavePhase * 2 * pi +
                  pi * 0.7);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();

    final color1 = goalMet
        ? const Color(0xFF00C853)
        : const Color(0xFF1E88E5);
    final color2 = goalMet
        ? const Color(0xFF69F0AE).withOpacity(0.6)
        : const Color(0xFF42A5F5).withOpacity(0.6);

    canvas.drawPath(path1, Paint()..color = color1);
    canvas.drawPath(path2, Paint()..color = color2);

    canvas.restore();

    // Outer ring
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = goalMet
            ? const Color(0xFF00C853).withOpacity(0.5)
            : const Color(0xFF1E88E5).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Outer glow ring
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..color = goalMet
            ? const Color(0xFF00C853).withOpacity(0.12)
            : const Color(0xFF1E88E5).withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress ||
          old.wavePhase != wavePhase ||
          old.goalMet != goalMet;
}

// ─── Water Button ────────────────────────────────────────────────────────────

class _WaterButton extends StatefulWidget {
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
  State<_WaterButton> createState() => _WaterButtonState();
}

class _WaterButtonState extends State<_WaterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    const waterBlue = Color(0xFF64B5F6);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: widget.highlighted
                ? waterBlue.withOpacity(0.18)
                : const Color(0xFF132236),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.highlighted
                  ? waterBlue.withOpacity(0.7)
                  : const Color(0xFF1E3A52),
              width: widget.highlighted ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  color: widget.highlighted
                      ? waterBlue
                      : const Color(0xFF546E7A),
                  size: 28),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.highlighted
                      ? waterBlue
                      : const Color(0xFF78909C),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Glass Card ─────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF132236),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A52), width: 1),
      ),
      child: child,
    );
  }
}

// ─── Tip Row ─────────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  final String tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                  color: Color(0xFFB0BEC5), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}