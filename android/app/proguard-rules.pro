# Proguard rules for Auroville TV
# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\Users\franc\AppData\Local\Pub\Cache\hosted\pub.dev/...

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class org.chromium.** { *; }

# Keep native sqflite code
-keep class com.tekartik.sqflite.** { *; }

# Ignore warnings for missing Play Store dynamic components library classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
