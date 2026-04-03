class AppConstants {
  AppConstants._();

  // Hive Box Names
  static const String waterBox = 'water_box';
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';
  static const String userBox = 'user_box';

  // Hive Keys
  static const String waterTodayKey = 'water_today';
  static const String waterGoalKey = 'water_goal';
  static const String waterDateKey = 'water_date';
  static const String voiceEnabledKey = 'voice_enabled';
  static const String adsConsentKey = 'ads_consent';

  // AdMob IDs (Test IDs — replace with real ones before publishing)
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test banner
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test interstitial

  // Defaults
  static const int defaultWaterGoalMl = 2500;
  static const int waterIncrementMl = 250;

  // Interstitial frequency (show every N navigations)
  static const int interstitialFrequency = 4;
}