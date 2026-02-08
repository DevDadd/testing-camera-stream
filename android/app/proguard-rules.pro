# ML Kit Pose Detection & MediaPipe – keep internal classes/fields
# to avoid NoSuchFieldError (e.g. "[B" field "value" in zzib) when
# loading the pose model.
-keep class com.google.android.gms.internal.mlkit_vision_mediapipe.** { *; }
-keep class com.google.mlkit.vision.pose.** { *; }
-keep class com.google.mlkit.vision.mediapipe.** { *; }
