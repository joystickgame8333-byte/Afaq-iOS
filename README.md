# أفق — واجهة الآيفون

مشروع SwiftUI جديد لواجهة «أفق» التي اختارها المستخدم. هذه المرحلة للواجهة والإعدادات فقط.

## ما يتضمنه

- شاشة اليوم بخلفية صحراء وقت الغروب مضمّنة داخل التطبيق، وصلاة قادمة وعد تنازلي ثابت ومواقيت توضيحية.
- تنقّل أصلي بين اليوم والإعدادات؛ يكتسب مظهر Liquid Glass من النظام على iOS 26 فما بعد.
- زر إعدادات يستخدم `glassEffect` على iOS 26+، ومواد النظام على iOS 18–25.
- أجواء الغروب والليل والفجر: بدائل لونية للصورة نفسها في هذه المرحلة، وليست صورًا مستقلة أو تغييرًا تلقائيًا مع الوقت.
- إعدادات محفوظة عبر UserDefaults: الأرقام، تنسيق الساعة، الثواني، الشروق، أجواء الخلفية، والتعتيم.
- معاينة مباشرة للخلفية، استعادة إعدادات المظهر، وشاشة «عن أفق».
- واجهة عربية RTL وأيقونات SF Symbols، مع تسميات VoiceOver واحترام تقليل الشفافية والحركة.

## الحدود الحالية

لا حساب مواقيت، ولا موقع، ولا اتصال شبكي، ولا أذان أو تنبيهات أو قبلة. مدينة الرياض جزء من بيانات العرض. لا يطلب التطبيق أي صلاحيات. العد التنازلي ثابت عمدًا. مصدر المشروع متاح في [GitHub](https://github.com/joystickgame8333-byte/Afaq-iOS)، وحزم تجربة الآيفون في [Releases](https://github.com/joystickgame8333-byte/Afaq-iOS/releases). لم يُنشر التطبيق في App Store أو TestFlight.

## التشغيل

1. على Mac شغّل `bash tools/prepare-assets.sh` لتجهيز قياسات أيقونة التطبيق.
2. افتح `Afaq.xcodeproj` باستخدام Xcode 26 أو أحدث، واختر scheme باسم `Afaq` ومحاكي iPhone، ثم Run.
3. للتشغيل على جهاز حقيقي عبر Xcode: اختر فريقك في Signing & Capabilities، واستبدل معرّف `com.omaralasam.afaq` إذا لزم.

الحد الأدنى للتطبيق iOS 18. يحتاج **البناء** Xcode 26+ لتجميع واجهات Liquid Glass، حتى مع وجود بديل للأجهزة الأقدم. يستفيد من مظهر النظام عند التشغيل على iOS 27 كذلك، دون الاعتماد على API خاص بالإصدار 27.

```sh
bash tools/prepare-assets.sh
xcodebuild -project Afaq.xcodeproj -scheme Afaq \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

## التحقق

نجح فحص بنية المشروع ومراجعه وصحة JSON وXML وYAML وتحليل صياغة ملفات Swift السبعة محليًا. ونجح بناء Xcode لنسخة iPhone بنمط Release ونسخة المحاكي بنمط Debug على جهاز GitHub المستضاف. لم يكتمل فحص الواجهة أثناء التشغيل: تشغيل محاكي GitHub تأخر، لذلك جُعل التقاط الصور خيارًا يدويًا مستقلًا عن نشر IPA. لا توجد صور تشغيل فعلية مُراجعة حتى الآن، ولم تُجر تجربة على جهاز iPhone حقيقي.

ملف GitHub Actions يبني حزمة iPhone غير موقّعة `Afaq.ipa` وينشرها في GitHub Releases. عند تشغيل workflow يدويًا يمكن تفعيل `capture_preview` لبناء المحاكي ومحاولة التقاط الرئيسية والإعدادات. ملف IPA يحتاج وسيلة توقيع أو تثبيت جانبي متوافقة؛ لا يثبّت من Safari مباشرة. لم يُضبط توقيع Apple أو TestFlight أو بيانات متجر. أيقونة أولية مضمّنة ويُضبط قياسها آليًا قبل البناء.

## الملفات

- `Afaq/HomeView.swift`: الرئيسية وصفوف المواقيت.
- `Afaq/SettingsView.swift`: الإعدادات واختيار الأجواء وعن التطبيق.
- `Afaq/AppearanceSettings.swift`: الحالة وحفظ الخيارات وتنسيق الأرقام.
- `Afaq/PreviewSchedule.swift`: بيانات العرض المستقلة عن أي حاسبة.
- `Afaq/AtmosphereView.swift`: الخلفية والزجاج والتوافق.
- `design-reference.png`: لوحة التصورات؛ الاتجاه المعتمد هو الهاتف الأوسط.
- `ASSET-NOTES.md`: مصدر الخلفية والوصف المستخدم لتوليدها.

مرجع التصميم والتنفيذ: [Apple — Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/).
