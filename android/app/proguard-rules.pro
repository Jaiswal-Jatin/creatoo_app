# Flutter ProGuard Rules - COMPREHENSIVE KEEP RULES
# This ensures NO crashes while enabling R8 for mapping file generation

# ============== KEEP EVERYTHING CRITICAL ==============

# Keep ALL Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep Firebase completely
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Razorpay completely
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep all application classes
-keep class com.creatoo.app.** { *; }

# Keep Kotlin classes
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ============== KEEP NATIVE METHODS ==============

-keepclasseswithmembernames class * {
    native <methods>;
}

# ============== KEEP ANDROID COMPONENTS ==============

# Keep Activities
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Keep View constructors
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ============== KEEP PARCELABLE ==============

-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ============== KEEP SERIALIZABLE ==============

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============== KEEP ANNOTATIONS ==============

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# ============== KEEP ENUMS ==============

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============== KEEP GSON/JSON ==============

-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# ============== KEEP WEBVIEW ==============

-keep class android.webkit.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ============== DISABLE OPTIMIZATION ==============
# This is the KEY to prevent crashes - minimal optimization

-dontoptimize
-dontobfuscate

# ============== R8 SPECIFIC ==============

# For R8 full mode
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
