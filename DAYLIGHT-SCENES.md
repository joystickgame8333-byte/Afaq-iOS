# دورة المشاهد من الفجر إلى الليل

الوضع الافتراضي الجديد «تلقائي حسب الوقت». يتبع الساعة والمنطقة الزمنية الحالية للجهاز، ويتحدّث كل دقيقة وعند العودة للتطبيق أو تغيّر وقت الجهاز. تظل المواقيت والعدّاد التجريبيان منفصلين عن هذا العرض.

المشاهد تتدرّج من الليل إلى الفجر، ثم الشروق والنهار والعصر والغروب والليل. يمكن اختيار كل حالة يدويًا من «أجواء الخلفية» لمعاينتها دون انتظار الساعة الفعلية. التحول إلى التلقائي يُطبّق مرة واحدة على النسخة السابقة، ثم تُحفظ اختيارات المستخدم اللاحقة.

الجدول البصري الثابت بالتوقيت المحلي:

- 04:00–05:30: انتقال من الليل إلى الفجر.
- 05:30–07:00: أجواء الفجر والشروق.
- 07:00–09:00: انتقال إلى النهار.
- 09:00–14:00: نهار.
- 14:00–17:30: انتقال تدريجي إلى ألوان العصر والغروب.
- 17:30–18:00: غروب.
- 18:00–19:30: انتقال إلى الليل.
- بقية اليوم: ليل.

تظهر الشمس تدريجيًا حول 06:00، ويتغيّر موقعها ودفء لونها خلال النهار، ثم تختفي حول 18:30. يظهر الهلال في الليل ويتلاشى قرب الفجر. هذه أوقات وحركة **بصرية تقريبية**؛ لا تُستخدم لحساب الشروق أو الغروب الفعلي أو اتجاه الشمس أو طور القمر الحقيقي، ولا تعتمد على موقع جغرافي.

## الصور المضمّنة

- `Afaq/Assets.xcassets/AtmosphereDawn.imageset/scene.png`
- `Afaq/Assets.xcassets/AtmosphereDay.imageset/scene.png`
- `Afaq/Assets.xcassets/AtmosphereSunset.imageset/scene.png`
- `Afaq/Assets.xcassets/AtmosphereNight.imageset/scene.png`

الصور أُعدّت باستخدام أداة image_gen المدمجة، بإضاءة بديلة لصورة الصحراء الأصلية. لا تحتوي الصور على قرص شمس أو قمر؛ يُرسَمان كعنصرين مستقلين أثناء العرض، لتجنّب ظهور شمس ثابتة خلف القمر أو ظهور قرصين.

## وصف التوليد النهائي

الوصف المشترك: "Precise lighting edit for a time-adaptive iPhone app background. Input image is the EDIT TARGET and establishes the immutable terrain, camera framing and composition. Preserve the same portrait aspect ratio. Output only the full-bleed photograph."

الغروب: "Keep exactly the same sunset sky colors, wispy cloud placement, horizon altitude, mountains, dune geometry, photographic textures, crop and perspective. Remove ONLY the small visible round sun disk, filling its spot seamlessly with the existing warm sunset glow. The warm horizon glow must remain. No other sun, moon, stars, text, icons or objects."

الفجر: "Relight this EXACT SAME landscape as predawn / first light. Keep identical camera, crop, horizon height, mountain outlines, dunes and every terrain feature. Sky deep indigo at top, pale muted lavender and blush peach at the horizon, faint cool early morning light on dunes. Remove the visible sun disk entirely. No sun, moon, stars, text, icons or extra objects. Calm realistic photographic atmosphere, sufficiently subdued for white UI text."

النهار: "Relight this EXACT SAME landscape as clear daytime, retaining identical camera, crop, horizon height, mountain outlines, dunes and all terrain features. Natural softly desaturated blue sky, subtle high wispy clouds, warm sand and natural side lighting. Remove the visible sun disk entirely; no sun or moon anywhere in the image. Keep top sky medium deep blue rather than near-white so white app text remains readable. Realistic landscape photograph, no text, icons, buildings or additional objects."

الليل: "Relight this EXACT SAME landscape as deep clear night, retaining identical camera, crop, horizon height, mountain outlines, dunes and all terrain features. Midnight navy sky with a few extremely faint tiny natural stars. Cool soft blue-silver illumination on dunes, quiet rich deep shadows. Remove the orange sun disk and warm orange horizon glow entirely. No sun or moon anywhere; the app will add its own moving moon. No bright astronomical objects, text, icons, buildings or additional objects."

## التحقق الحالي

نجح فحص صياغة Swift محليًا وبناء Xcode Release للآيفون في GitHub Actions 42509832918. نُشرت الدفعة في preview-5، وتم تنزيل IPA والتحقق من سلامته ومطابقة SHA256. لم تُجر تجربة تشغيل بصري لهذه الدفعة؛ التجربة على آيفون المستخدم.
