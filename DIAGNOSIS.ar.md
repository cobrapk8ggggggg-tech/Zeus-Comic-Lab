# تشخيص فرع Zeus-Browser ومصائر الـ workflows — ماذا حدث ولماذا

> مصدر الحقيقة: سجلات Actions الحقيقية + قراءة كاملة لفرع `feature/zeus-manhwa-translation-20261101` (14 commit) + خط التحويل `.openminis/{build_project.rb, embed_native.py, native_ui.py}`.

## 1) ما بُني فعلاً (تقدير عادل)

خط ترجمة صور المانhua على **iOS/WebKit** (متصفح ZEUS مبنٍ على OpenMinis):
- **Swift (14 ملفاً)** في `ZEUSNext/ComicTranslation/`: فقاعات، Bidi عربي، OCR (Vision)، Paddle/ONNX، بكسلات، مترجم نص، ذاكرة ترجمة، متجر نماذج، نوافذ متداخلة للصور الطويلة، واجهات.
- **C++ أصلي**: `Native/ComicRuntime/` (فك JPEG/PNG/WebP إقليمي عند تعذر Canvas).
- **جسر JS**: `ZEUSNext/Resources/comic-images.js` (عزل WKContentWorld، مصدر أصلي بسجلات داخلية لا DOM، lazy = فواصل).
- **ترجمة**: Google/Microsoft/MyMemory بلا مفتاح (مُختبَرة حياً — `LIVE-PROVIDERS.json`) + BYOK (Yandex Cloud/Papago/DeepL/Caiyun/Anthropic) + llama.cpp محلي (GGUF).
- **رسم**: CoreText مع تشكيل عربي واستيراد خطوط TTF/OTF/TTC وأقنعة تنظيف موضعية.
- **10 workflows** في `.github/workflows/`.

## 2) حالة الـ workflows عند آخر commit (56a48ee)

| Workflow | آخر نتيجة | السبب |
|---|---|---|
| ZEUS comic image translation | ✅ success (2c1de0c) | يعمل |
| ZEUS native browser integration tests | ❌ failure (56a48ee) | فشل **بناء** التطبيق: exit 65 |
| IPA from feature/... | ❌ failure (56a48ee و3b58305 و2c1de0c) | نفس فشل البناء على جهاز حقيقي |

أي: **اختبارات نواة الترجمة خضراء، لكن بناء التطبيق نفسه أحمر منذ 3 commits على الأقل.**

## 3) الأسباب الجذرية (من السجلات حرفياً)

### (أ) نوعان مفقودان — أعمال نصف منجزة
```
upstream/src/ios/ZeusCloudFiles.swift:136:30: error: cannot find type 'ZeusOutputKind' in scope
upstream/src/ios/Views/Chat/AIChatView.swift:1062:13: error: cannot find 'ZeusConversationFiles' in scope
```
- `embed_native.py` + `native_ui.py` **يُدخلان** أوراق عرض تستدعي `ZeusOutputKind` و `ZeusConversationFiles` في AIChatView وStorageManagement، و`ZeusCloudFiles.swift` في Host يستخدم الأول في فلتر الشبكة.
- **لا يوجد أي تعريف** لهذين النوعين في المستودع ولا في submodule OpenMinis — نُسيت ملفاتها.
- خطأ `Predicate<ZeusCloudFiles.Entry>` وخطأ تجاوز وقت type-check في `AIChatView.swift:515` كلاهما **تسلسل** من نفس الجذور (الفلتر يفشل في التفريد فتنهار الشبكة كلها).

### (ب) آخر commit (56a48ee) لم يكن هو السبب
غيّر `build_project.rb` فقط (إزالة حزمة VAD + وراثة مسارات CocoaPods) — إصلاحات صحيحة، لكنها لا تعالج النوعين المفقودين.

## 4) ما فعله هذا المستودع الجديد (Zeus-Comic-Lab)

1. **نسخة أساس** من الفرع الأخير (بكل التنفيذ والتوثيق).
2. **إصلاح 1**: `.openminis/Host/ZeusHostTypes.swift` — تعريف `ZeusOutputKind` (CaseIterable + classify بالامتدادات + title عربي + SF Symbol) و`ZeusConversationFiles` (ورقة ملفات المحادثة فوق ZeusCloudFilesView) — يُلتقط تلقائياً لهدف التطبيق (glob Host) ويكفي للـ TEST_HOST للاختبارات.
3. لاحقاً: تفعيل الـ workflows، ثم تحسينات التكافؤ مع Ascent (خطوط، تلوين حسب خلفية الفقاعة، ...).
