import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String todayString() => formatDate(DateTime.now());

  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Mifflin-St Jeor BMR, then Harris-Benedict activity multiplier
  static double calculateMaintenanceCalories({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    String activityLevel = 'moderate',
  }) {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    final multiplier = _activityMultiplier(activityLevel);
    return bmr * multiplier;
  }

  static double _activityMultiplier(String level) {
    switch (level) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.55;
    }
  }

  static double fatLossCalories(double maintenance) => maintenance - 500;
  static double muscleGainCalories(double maintenance) => maintenance + 300;

  /// Rough step calorie estimate: ~0.04 kcal per step per 70kg person (scaled)
  static double stepsToCalories(int steps, double weightKg) =>
      steps * 0.04 * (weightKg / 70);

  /// Distance from steps (avg stride ~0.75m)
  static double stepsToKm(int steps) => steps * 0.00075;

  /// Cardio calorie burn (MET ~7 for moderate running * weight * hours)
  static double cardioCalories(int minutes, double weightKg) =>
      7 * weightKg * (minutes / 60);

  static String bmiColor(double bmi) {
    if (bmi < 18.5) return 'blue';
    if (bmi < 25.0) return 'green';
    if (bmi < 30.0) return 'orange';
    return 'red';
  }
}