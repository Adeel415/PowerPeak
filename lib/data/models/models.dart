import 'package:hive/hive.dart';

part 'models.g.dart';

// ─── Weight Entry ────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class WeightEntry extends HiveObject {
  @HiveField(0)
  final double weightKg;

  @HiveField(1)
  final String date; // yyyy-MM-dd

  WeightEntry({required this.weightKg, required this.date});
}

// ─── User Profile ─────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  double weightKg;

  @HiveField(1)
  double heightCm;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender; // 'male' | 'female'

  @HiveField(4)
  String activityLevel; // sedentary | light | moderate | active | very_active

  UserProfile({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
  });
}

// ─── Diet Meal (in-memory, from JSON) ────────────────────────────────────────

class DietMeal {
  final String name;
  final String time;
  final List<String> items;
  final int calories;

  const DietMeal({
    required this.name,
    required this.time,
    required this.items,
    required this.calories,
  });

  factory DietMeal.fromJson(Map<String, dynamic> json) => DietMeal(
        name: json['name'] as String,
        time: json['time'] as String,
        items: List<String>.from(json['items']),
        calories: json['calories'] as int,
      );
}

class DietPlan {
  final String category;
  final String title;
  final String description;
  final int totalCalories;
  final List<DietMeal> meals;

  const DietPlan({
    required this.category,
    required this.title,
    required this.description,
    required this.totalCalories,
    required this.meals,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
        category: json['category'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        totalCalories: json['totalCalories'] as int,
        meals: (json['meals'] as List)
            .map((m) => DietMeal.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Workout ──────────────────────────────────────────────────────────────────

class Exercise {
  final String name;
  final int sets;
  final String reps;
  final int restSeconds;
  final String? tip;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.tip,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as String,
        restSeconds: json['restSeconds'] as int,
        tip: json['tip'] as String?,
      );
}

class WorkoutDay {
  final String day;
  final String focus;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.day,
    required this.focus,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        day: json['day'] as String,
        focus: json['focus'] as String,
        exercises: (json['exercises'] as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutPlan {
  final String level;
  final String gender;
  final String title;
  final List<WorkoutDay> days;

  const WorkoutPlan({
    required this.level,
    required this.gender,
    required this.title,
    required this.days,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
        level: json['level'] as String,
        gender: json['gender'] as String,
        title: json['title'] as String,
        days: (json['days'] as List)
            .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Quote ───────────────────────────────────────────────────────────────────

class MotivationQuote {
  final String text;
  final String author;

  const MotivationQuote({required this.text, required this.author});

  factory MotivationQuote.fromJson(Map<String, dynamic> json) =>
      MotivationQuote(
        text: json['text'] as String,
        author: json['author'] as String,
      );
}
