import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../../core/constants/app_constants.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  late Box _waterBox;
  late Box _settingsBox;
  late Box<WeightEntry> _progressBox;
  late Box<UserProfile> _userBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WeightEntryAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    _waterBox = await Hive.openBox(AppConstants.waterBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _progressBox =
        await Hive.openBox<WeightEntry>(AppConstants.progressBox);
    _userBox = await Hive.openBox<UserProfile>(AppConstants.userBox);
  }

  // ─── Water Tracker ──────────────────────────────────────────────────────────

  int getTodayWater() {
    final today = _todayString();
    final savedDate = _waterBox.get(AppConstants.waterDateKey, defaultValue: '');
    if (savedDate != today) {
      _waterBox.put(AppConstants.waterDateKey, today);
      _waterBox.put(AppConstants.waterTodayKey, 0);
      return 0;
    }
    return _waterBox.get(AppConstants.waterTodayKey, defaultValue: 0) as int;
  }

  void addWater(int ml) {
    final today = _todayString();
    _waterBox.put(AppConstants.waterDateKey, today);
    final current =
        _waterBox.get(AppConstants.waterTodayKey, defaultValue: 0) as int;
    _waterBox.put(AppConstants.waterTodayKey, current + ml);
  }

  void resetWater() {
    _waterBox.put(AppConstants.waterTodayKey, 0);
    _waterBox.put(AppConstants.waterDateKey, _todayString());
  }

  int getWaterGoal() => _waterBox.get(AppConstants.waterGoalKey,
      defaultValue: AppConstants.defaultWaterGoalMl) as int;

  void setWaterGoal(int ml) => _waterBox.put(AppConstants.waterGoalKey, ml);

  // ─── Settings ───────────────────────────────────────────────────────────────

  bool isVoiceEnabled() =>
      _settingsBox.get(AppConstants.voiceEnabledKey, defaultValue: true) as bool;

  void setVoiceEnabled(bool v) =>
      _settingsBox.put(AppConstants.voiceEnabledKey, v);

  // ─── Progress / Weight ──────────────────────────────────────────────────────

  List<WeightEntry> getWeightHistory() => _progressBox.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  void addWeightEntry(WeightEntry entry) => _progressBox.add(entry);

  void deleteWeightEntry(int index) => _progressBox.deleteAt(index);

  // ─── User Profile ───────────────────────────────────────────────────────────

  UserProfile? getUserProfile() =>
      _userBox.isEmpty ? null : _userBox.getAt(0);

  void saveUserProfile(UserProfile profile) {
    if (_userBox.isEmpty) {
      _userBox.add(profile);
    } else {
      _userBox.putAt(0, profile);
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
