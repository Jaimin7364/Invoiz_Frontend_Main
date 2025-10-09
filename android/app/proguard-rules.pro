# Keep all Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep ProGuard annotations
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

# Keep all classes with @Keep annotation
-keep @proguard.annotation.Keep class * { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}

# Keep all payment related classes
-keep class * implements com.razorpay.PaymentResultListener { *; }

# Keep Flutter plugins
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson specific classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Keep all model classes (you may need to adjust this based on your models)
-keep class com.invoiz.app.client.** { *; }

# OkHttp and Retrofit
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }