import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';
import '../../data/models/models.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  String _level = 'beginner';
  String _gender = 'male';

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(workoutPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      body: Column(
        children: [
          const PPBannerAd(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: PPDropdown<String>(
                    label: 'Level',
                    value: _level,
                    items: const [
                      DropdownMenuItem(
                          value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(
                          value: 'intermediate',
                          child: Text('Intermediate')),
                      DropdownMenuItem(
                          value: 'advanced', child: Text('Advanced')),
                    ],
                    onChanged: (v) => setState(() => _level = v!),
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: plansAsync.when(
              data: (plans) {
                final match = plans
                    .where((p) => p.level == _level && p.gender == _gender)
                    .toList();
                if (match.isEmpty) {
                  return const Center(
                    child: Text(
                      'No plan available for this selection.\nTry Beginner or Intermediate.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                final plan = match.first;
                return _WorkoutPlanView(plan: plan);
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanView extends StatelessWidget {
  final WorkoutPlan plan;

  const _WorkoutPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: plan.days.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PPCard(
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: AppTheme.accent),
                  const SizedBox(width: 12),
                  Text(plan.title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ],
              ),
            ),
          );
        }
        final day = plan.days[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _WorkoutDayCard(day: day),
        );
      },
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final WorkoutDay day;

  const _WorkoutDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return PPCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          title: Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(day.day,
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(day.focus,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ],
          ),
          children: day.exercises
              .map((e) => _ExerciseTile(exercise: e))
              .toList(),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          dense: true,
          title: Text(exercise.name,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          subtitle: exercise.tip != null
              ? Text(exercise.tip!,
              style: const TextStyle(
                  color: AppTheme.textHint, fontSize: 11))
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Badge(
                  label: '${exercise.sets}×${exercise.reps}',
                  color: AppTheme.accent),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showRestTimer(context, exercise),
                child: _Badge(
                    label: '${exercise.restSeconds}s rest',
                    color: AppTheme.primaryLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRestTimer(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (_) => _RestTimerDialog(
        exerciseName: exercise.name,
        seconds: exercise.restSeconds,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _RestTimerDialog extends StatefulWidget {
  final String exerciseName;
  final int seconds;

  const _RestTimerDialog({
    required this.exerciseName,
    required this.seconds,
  });

  @override
  State<_RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<_RestTimerDialog> {
  late int _remaining;
  Timer? _timer;
  final FlutterTts _tts = FlutterTts();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  void _start() {
    _tts.speak('Rest for ${widget.seconds} seconds');
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);
      if (_remaining <= 3 && _remaining > 0) {
        _tts.speak(_remaining.toString());
      }
      if (_remaining <= 0) {
        t.cancel();
        _tts.speak('Go! Next set of ${widget.exerciseName}');
        setState(() => _running = false);
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = widget.seconds;
      _running = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
    widget.seconds > 0 ? 1.0 - (_remaining / widget.seconds) : 1.0;

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Rest Timer',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.exerciseName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.surfaceLight,
                  color: _remaining <= 0
                      ? AppTheme.success
                      : AppTheme.accent,
                ),
                Text(
                  _remaining <= 0 ? 'GO!' : '$_remaining',
                  style: TextStyle(
                    color: _remaining <= 0
                        ? AppTheme.success
                        : AppTheme.textPrimary,
                    fontSize: _remaining <= 0 ? 28 : 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_running)
                ElevatedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              if (_running)
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}