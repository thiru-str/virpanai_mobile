# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
#Disable android logging
# no logging in production
# Preserve all classes, methods, and fields for the device_calendar library

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-keep class com.builttoroam.devicecalendar.** { *; }
# Prevent R8 from stripping WebView
-keep class android.webkit.** { *; }


# Google Play Core SplitCompat and SplitInstall
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keepattributes Exceptions, Signature, *Annotation*

# Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# --- Fix for BouncyCastle LDAP and CRL ---
-dontwarn javax.naming.**
-dontwarn org.bouncycastle.**
-dontwarn net.jcip.annotations.**

# Keep required classes so R8 doesn't strip them
-keep class javax.naming.** { *; }
-keep class org.bouncycastle.** { *; }
-keep class net.jcip.annotations.** { *; }

# Nimbus JOSE (JWT and crypto handling)
-keep class com.nimbusds.** { *; }

# Preserve annotations used at runtime
-keepattributes *Annotation*

# --- Google Tink Crypto Library Fix ---
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Nimbus JOSE library (JWT & crypto handling)
-keep class com.nimbusds.** { *; }
-dontwarn com.nimbusds.**

# Preserve annotations used at runtime
-keepattributes *Annotation*




