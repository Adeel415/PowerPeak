import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../local/local_storage.dart';
import '../../core/utils/app_utils.dart';



// ─── Settings ────────────────────────────────────────────────────────────────

final voiceEnabledProvider = StateNotifierProvider<VoiceNotifier, bool>((ref) {
  return VoiceNotifier();
});

class VoiceNotifier extends StateNotifier<bool> {
  VoiceNotifier() : super(LocalStorage.instance.isVoiceEnabled());

  void toggle() {
    state = !state;
    LocalStorage.instance.setVoiceEnabled(state);
  }
}

// ─── User Profile ─────────────────────────────────────────────────────────────

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(LocalStorage.instance.getUserProfile());

  void save(UserProfile profile) {
    LocalStorage.instance.saveUserProfile(profile);
    state = profile;
  }
}

// ─── BMI Calculator ───────────────────────────────────────────────────────────

class BmiState {
  final double? bmi;
  final double? maintenance;
  final double? fatLoss;
  final double? muscleGain;
  final String? category;

  const BmiState({
    this.bmi,
    this.maintenance,
    this.fatLoss,
    this.muscleGain,
    this.category,
  });
}

final bmiProvider = StateNotifierProvider<BmiNotifier, BmiState>((ref) {
  return BmiNotifier();
});

class BmiNotifier extends StateNotifier<BmiState> {
  BmiNotifier() : super(const BmiState());

  void calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmi = AppUtils.calculateBMI(weightKg, heightCm);
    final maintenance = AppUtils.calculateMaintenanceCalories(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
    );
    state = BmiState(
      bmi: bmi,
      maintenance: maintenance,
      fatLoss: AppUtils.fatLossCalories(maintenance),
      muscleGain: AppUtils.muscleGainCalories(maintenance),
      category: AppUtils.bmiCategory(bmi),
    );
  }

  void reset() => state = const BmiState();
}

// ─── Water Tracker ─────────────────────────────────────────────────────────────

class WaterState {
  final int currentMl;
  final int goalMl;

  const WaterState({required this.currentMl, required this.goalMl});

  double get progress => goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0;
}

final waterProvider =
    StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  return WaterNotifier();
});

class WaterNotifier extends StateNotifier<WaterState> {
  WaterNotifier()
      : super(WaterState(
          currentMl: LocalStorage.instance.getTodayWater(),
          goalMl: LocalStorage.instance.getWaterGoal(),
        ));

  void addWater(int ml) {
    LocalStorage.instance.addWater(ml);
    state = WaterState(
      currentMl: state.currentMl + ml,
      goalMl: state.goalMl,
    );
  }

  void reset() {
    LocalStorage.instance.resetWater();
    state = WaterState(currentMl: 0, goalMl: state.goalMl);
  }

  void setGoal(int ml) {
    LocalStorage.instance.setWaterGoal(ml);
    state = WaterState(currentMl: state.currentMl, goalMl: ml);
  }
}

// ─── Progress Tracker ─────────────────────────────────────────────────────────

final progressProvider =
    StateNotifierProvider<ProgressNotifier, List<WeightEntry>>((ref) {
  return ProgressNotifier();
});

class ProgressNotifier extends StateNotifier<List<WeightEntry>> {
  ProgressNotifier() : super(LocalStorage.instance.getWeightHistory());

  void addEntry(double weightKg, String date) {
    final entry = WeightEntry(weightKg: weightKg, date: date);
    LocalStorage.instance.addWeightEntry(entry);
    state = LocalStorage.instance.getWeightHistory();
  }

  void removeEntry(int index) {
    LocalStorage.instance.deleteWeightEntry(index);
    state = LocalStorage.instance.getWeightHistory();
  }
}

// ─── Step Counter ─────────────────────────────────────────────────────────────

class StepState {
  final int steps;
  final double weightKg;

  const StepState({required this.steps, required this.weightKg});

  double get calories => AppUtils.stepsToCalories(steps, weightKg);
  double get distanceKm => AppUtils.stepsToKm(steps);
}

final stepProvider =
    StateNotifierProvider<StepNotifier, StepState>((ref) {
  final profile = ref.watch(userProfileProvider);
  return StepNotifier(profile?.weightKg ?? 70);
});

class StepNotifier extends StateNotifier<StepState> {
  StepNotifier(double weight) : super(StepState(steps: 0, weightKg: weight));

  void setSteps(int steps) =>
      state = StepState(steps: steps, weightKg: state.weightKg);
}

// ─── Cardio ───────────────────────────────────────────────────────────────────

class CardioState {
  final int minutes;
  final double? calories;

  const CardioState({required this.minutes, this.calories});
}

final cardioProvider =
    StateNotifierProvider<CardioNotifier, CardioState>((ref) {
  return CardioNotifier();
});

class CardioNotifier extends StateNotifier<CardioState> {
  CardioNotifier() : super(const CardioState(minutes: 0));

  void calculate(int minutes, double weightKg) {
    state = CardioState(
      minutes: minutes,
      calories: AppUtils.cardioCalories(minutes, weightKg),
    );
  }
}

// ─── Diet Plans ───────────────────────────────────────────────────────────────

final dietPlansProvider = FutureProvider<List<DietPlan>>((ref) async {
  final json = await rootBundle.loadString('assets/json/diet_plans.json');
  final list = jsonDecode(json) as List;
  return list.map((e) => DietPlan.fromJson(e as Map<String, dynamic>)).toList();
});

// ─── Workouts ─────────────────────────────────────────────────────────────────

final workoutPlansProvider = FutureProvider<List<WorkoutPlan>>((ref) async {
  final json = await rootBundle.loadString('assets/json/workouts.json');
  final list = jsonDecode(json) as List;
  return list
      .map((e) => WorkoutPlan.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─── Motivation Quote ─────────────────────────────────────────────────────────

final quotesProvider = FutureProvider<List<MotivationQuote>>((ref) async {
  final json = await rootBundle.loadString('assets/json/quotes.json');
  final list = jsonDecode(json) as List;
  return list
      .map((e) => MotivationQuote.fromJson(e as Map<String, dynamic>))
      .toList();
});

final dailyQuoteProvider = FutureProvider<MotivationQuote>((ref) async {
  final quotes = await ref.watch(quotesProvider.future);
  final day = DateTime.now().day;
  return quotes[day % quotes.length];
});
