# Aturan untuk class anotasi yang hilang
-keep class javax.annotation.** { *; }
-keep class com.google.errorprone.annotations.** { *; }

# Aturan untuk tidak menampilkan peringatan tentang class tersebut
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**