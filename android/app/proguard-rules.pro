# flutter_local_notifications planlanmış bildirimleri Gson ile saklar.
# R8 genel tür bilgisini silerse zonedSchedule release'de
# "TypeToken must be created with a type argument" hatasıyla çöker
# (randevu ve hatırlatma bildirimleri kurulamaz).
# Kaynak: flutter_local_notifications örnek projesindeki kurallar.

-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Eklentinin Gson ile okuyup yazdığı bildirim modelleri.
-keep class com.dexterous.** { *; }
