# Sportik Player — نسخة تطويرية مستقلة

**اسم التطبيق:** Sportik Player  
**Android applicationId:** `com.sportik.player`

## ما الذي أضيف؟

- عند فتح التطبيق من أيقونته تظهر مكتبة فيديو محلية داكنة: مجلدات الفيديو، البحث، وصور مصغرة مع مدة كل فيديو.
- عند الضغط على فيديو محلي يُفتح نفس مشغل BetterPlayer باستخدام `BetterPlayerDataSourceType.file`.
- عند فتح التطبيق ببيانات قناة من Sportik الأساسي، يتجاوز التطبيق المكتبة ويبدأ مسار تشغيل القناة مباشرة.
- أُبقي مسار HMAC/Proxy الحالي للقنوات منفصلًا عن مسار الملفات المحلية.
- لا توجد Unity Ads أو Myservices داخل تطبيق المشغل المستقل.

## المكتبات المضافة

- `photo_manager`: قراءة مكتبة الفيديوهات وألبوماتها وصور المعاينة عبر واجهات Android MediaStore وصلاحيات النظام.

## شرح الملفات

- `lib/main.dart`: يقرأ بيانات التشغيل القادمة من Android MethodChannel. إذا لم تصل بيانات قناة أو ملف محلي يفتح مكتبة الفيديو.
- `lib/view/screen/library.dart`: واجهة المكتبة، طلب الإذن، تحميل ألبومات الفيديو، البحث، الصور المصغرة وفتح الفيديو.
- `lib/controller/playercontroller.dart`: يحتفظ بمسار القنوات والتوكن، ويضيف مسارًا مستقلًا للملف المحلي. الملف المحلي لا يمر عبر HMAC أو Proxy.
- `lib/view/screen/player.dart`: واجهة BetterPlayer الحالية مع اسم الفيديو المحلي وإخفاء أزرار جودة SD/HD للفيديو المحلي.
- `lib/core/services/proxyservice.dart`: خدمة Proxy للقنوات فقط؛ لا تستخدم عند تشغيل ملف محلي.
- `android/app/src/main/AndroidManifest.xml`: يصرح بصلاحيات قراءة الفيديو المتوافقة مع إصدارات Android.
- `android/app/src/main/kotlin/com/sportik/player/MainActivity.kt`: يستقبل Intent extras من التطبيق الأساسي ويمررها إلى Flutter.

## عقد تشغيل القناة من التطبيق الأساسي

Android Intent extras المتوقعة (String):
`sdurl`, `hdurl`, `sdname`, `hdname`, `displayname`, `gettoken`, `key`, `host`.

يجب أن يرسل التطبيق الأساسي هذه القيم إلى `com.sportik.player`. قيمة `key` هي مفتاح HMAC السري؛ لا تضعه في Git أو ملفات عامة. يظل تمريره إلى التطبيق الآخر قابلًا للاستخراج من جهاز مخترق، حتى مع تخزينه في Android Keystore عبر `flutter_secure_storage`.

## التشغيل والبناء

من بيئة Flutter حديثة:

```bash
flutter pub get
flutter analyze
flutter build apk --release
flutter build appbundle --release
```

## ملاحظات اختبار مهمة قبل النشر

1. لم تتوفر Flutter/Dart SDK في بيئة إعداد هذه الحزمة، لذلك **لم يتم تنفيذ `flutter pub get` أو `flutter analyze` أو بناء APK/AAB هنا**. يلزم تنفيذها في Codemagic أو بيئة Flutter ثم إصلاح أي تعارضات إصدار.
2. اختبر إذن مكتبة الفيديو على Android 13 و14/15، بما في ذلك الرفض وإعادة منح الإذن.
3. اختبر ملفات MP4 وMKV وMOV وترميزات الصوت/الفيديو المختلفة؛ دعم الحاويات والترميزات يعتمد على Android/ExoPlayer والجهاز.
4. اختبر Android TV والريموت، خصوصًا التنقل داخل المكتبة والتركيز على البطاقات.
5. اختبر القنوات فعليًا مع Flussonic، بما في ذلك HLS playlists والـ segments. Proxy الموروث يضيف token إلى كل مسار؛ قد تحتاج بعض المصادر إلى إعادة كتابة روابط HLS.
6. في هذا الإصدار الأول، صفحة المكتبة تعرض أحدث عناصر الألبوم المختار، لكنها لا تحفظ سجل متابعة/استكمال مشاهدة بين الجلسات بعد. هذه ميزة لاحقة يمكن إضافتها بـ SQLite/SharedPreferences.
7. تكامل تشغيل القناة من Sportik الأساسي يحتاج اختبارًا على جهاز فعلي للتأكد من أسماء الـ extras وطريقة إطلاق التطبيق.

## خصوصية الملفات

لا تُرفع ملفات توقيع Android أو مفاتيح HMAC أو ملفات `.env` أو كلمات المرور إلى مستودع GitHub. راجع `.gitignore` قبل الرفع.
