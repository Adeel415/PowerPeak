# Flutter & Dart
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Hive
-keep class com.hivedb.** { *; }
-keep @com.hivedb.HiveType class * { *; }
-keep class **.*.*.*.HiveType { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# flutter_tts
-keep class com.tundralabs.fluttertts.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable