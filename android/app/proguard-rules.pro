# Keep `Companion` object fields of serializable classes.
# This avoids serializer lookup through `getDeclaredClasses` as done for named companion objects.
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

# Keep `serializer()` on companion objects (both default and named) of serializable classes.
-if @kotlinx.serialization.Serializable class ** {
    static **$* *;
}
-keepclassmembers class <2>$<3> {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep `INSTANCE.serializer()` of serializable objects.
-if @kotlinx.serialization.Serializable class ** {
    public static ** INSTANCE;
}
-keepclassmembers class <1> {
    public static <1> INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}

# @Serializable and @Polymorphic are used at runtime for polymorphic serialization.
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault

# Don't shrink or obfuscate Context related classes
-keep class android.app.Application { <init>(); }
-keep class android.content.Context { <init>(); }
-keep class android.content.ContextWrapper { <init>(android.content.Context); }
-keep class androidx.core.app.CoreComponentFactory { <init>(); }
-keep class com.example.tushar_db.MainActivity { <init>(); }
-keep class * extends android.content.Context
-keepclassmembers class * extends android.content.Context {
   public <init>(android.content.Context);
   public void attachBaseContext(android.content.Context);
}

# GetStorage
-keep class com.github.getstream.sdk.chat.StreamChatClient { *; }
-keep class com.github.getstream.sdk.chat.StreamChat { *; }

# Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }
-keep class androidx.core.app.NotificationChannelCompat { *; }
-keep class androidx.core.app.NotificationChannelGroupCompat { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationChannelGroup { *; }
-keep class android.app.Notification { *; }

# Keep all classes in the application
-keep class com.example.tushar_db.** { *; }

# Keep Flutter engine
-keep class io.flutter.** { *; }

# Workmanager
-keep class androidx.work.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Play Core Library
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Rules from missing_rules.txt
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep all classes in the application
-keep class com.example.tushar_db.** { *; }

# Add this to preserve the line numbers for easier debugging
-keepattributes SourceFile,LineNumberTable

# Uncomment these for more verbose output
-verbose
-printusage unused.txt
-printseeds seeds.txt
-printmapping mapping.txt

# New rules for SharedPreferences
-keep class android.app.SharedPreferences { *; }
-keep class android.app.SharedPreferences$Editor { *; }
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Additional rules for AwesomeNotifications
-keep class me.carda.awesome_notifications.core.** { *; }
-keep class me.carda.awesome_notifications.core.models.** { *; }
-keep class me.carda.awesome_notifications.core.enumerators.** { *; }
-keep class me.carda.awesome_notifications.core.exceptions.** { *; }
-keep class me.carda.awesome_notifications.core.utils.** { *; }

# Keep classes that might be used by AwesomeNotifications
-keep class androidx.core.app.NotificationCompat$Builder { *; }
-keep class androidx.core.app.NotificationCompat$Action { *; }
-keep class androidx.core.app.NotificationCompat$Action$Builder { *; }

# Ensure these classes are not obfuscated
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
# Gson specific rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent proguard from stripping interface information from TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not
# kept. Suspend functions are wrapped in continuations where the type argument
# is used.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Additional AwesomeNotifications specific rules
-keep class me.carda.awesome_notifications.** { *; }
-keep class me.carda.awesome_notifications.core.** { *; }
-keep class me.carda.awesome_notifications.core.models.** { *; }
-keep class me.carda.awesome_notifications.core.enumerators.** { *; }
-keep class me.carda.awesome_notifications.core.exceptions.** { *; }
-keep class me.carda.awesome_notifications.core.utils.** { *; }

# Keep all classes that might be used in JSON parsing
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep TypeAdapter classes
-keep class * extends com.google.gson.TypeAdapter