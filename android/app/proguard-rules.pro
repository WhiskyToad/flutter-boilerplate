# Keep Flutter utility classes accessed reflectively by JNI-based plugins.
# Without these rules R8 strips io.flutter.util.PathUtils in release builds,
# which causes path_provider and similar plugins to throw ClassNotFoundException.
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
