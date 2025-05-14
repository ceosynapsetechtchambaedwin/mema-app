# Empêcher R8 de supprimer ou d'obscurcir ExoPlayer (utilisé par just_audio)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Facultatif, mais utile si tu utilises Firebase Storage
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
