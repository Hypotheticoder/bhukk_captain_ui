# PayU Checkout Pro R8/ProGuard Rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# Ignore missing Google Pay (Tez) classes if not using Google Pay directly
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# PayU SDK internal classes
-keep class com.payu.** { *; }
-dontwarn com.payu.**

# Google Play Core — Flutter deferred components / split install
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Standard Flutter/Android keeps
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
