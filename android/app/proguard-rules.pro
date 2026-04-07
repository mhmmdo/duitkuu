# Flutter Proguard Rules
# This file must be proguarded to produce functioning code.

###### START: Flutter specific keep rules ######

# Keep Flutter engine internal classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep activity and fragment classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Fragment
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgent
-keep public class * extends android.preference.Preference
-keep public class * extends androidx.preference.Preference
-keep public class * extends androidx.work.Worker
-keep public class * extends android.content.pm.ParcelableArray

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

###### END: Flutter specific keep rules ######

###### START: Library specific rules ######

# SQLite Database
-keep class android.database.** { *; }

# Image Picker
-keep class com.example.imagepicker.** { *; }

# Google ML Kit
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.common.** { *; }

# androidx
-keep class androidx.** { *; }
-keepattributes Signature,RuntimeVisibleAnnotations,AnnotationDefault

###### END: Library specific rules ######

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization options
-optimizationpasses 5
-dontobfuscate
-verbose

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
