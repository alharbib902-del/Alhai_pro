# تقرير تدقيق تخزين الملفات والصور - منصة الحي

**التاريخ:** 2026-02-26
**المدقق:** Basem (بمساعدة Claude Opus 4.6)
**النطاق:** جميع حزم المنصة (alhai_core, alhai_design_system, alhai_services, packages/*, apps/*, supabase/)
**الإصدار:** 2.4.0

---

## ملخص تنفيذي

تمت مراجعة شاملة لنظام تخزين الملفات والصور في منصة الحي، والذي يعتمد على نظام مزدوج:
1. **Cloudflare R2** عبر Edge Function لتخزين صور المنتجات (الأساسي في الإنتاج)
2. **Supabase Storage** عبر `ImageService` في `alhai_core` (بديل/قديم)

المنصة تمتلك بنية تحتية جيدة لمعالجة الصور بثلاثة أحجام (thumbnail/medium/large) مع CDN وتخزين مؤقت (caching)، لكن هناك **فجوات أمنية حرجة** تتعلق بعدم التحقق من حجم الملفات ونوعها على مستوى الخادم، وعدم وجود سياسات تخزين Supabase Storage مُعرّفة في الكود، وغياب استراتيجية تنظيف الملفات المؤقتة.

### إحصائيات سريعة

| المقياس | القيمة |
|---------|--------|
| عدد المشاكل الحرجة | 6 |
| عدد المشاكل المتوسطة | 8 |
| عدد المشاكل المنخفضة | 5 |
| إجمالي المشاكل | **19** |
| الملفات المتأثرة | ~25 ملف |
| **التقييم العام** | **5.5 / 10** |

---

## النتائج التفصيلية

---

### 1. تكوين Supabase Storage Buckets

#### 1.1 عدم وجود سياسات تخزين مُعرّفة في SQL

**التصنيف:** :red_circle: حرج

لا يوجد أي ملف SQL في مجلد `supabase/` يُنشئ buckets أو يُعرّف سياسات RLS لـ Supabase Storage. الـ `ImageService` يستخدم bucket اسمه `product-images` لكن لا توجد سياسة وصول مُعرّفة في الكود.

**الملف:** `alhai_core/lib/src/services/image_service.dart` (سطر 11)
```dart
static const String _bucket = 'product-images';
```

**الملف:** `supabase/supabase_init.sql` - لا يحتوي على أي `INSERT INTO storage.buckets` أو `CREATE POLICY ON storage.objects`.

**المشكلة:** إذا تم استخدام Supabase Storage بدلاً من R2، فإن الـ bucket إما:
- غير موجود (سيفشل الرفع)
- تم إنشاؤه يدوياً بدون سياسات RLS (أي مستخدم مُصادق يمكنه الوصول)

**التوصية:** إضافة migration لإنشاء buckets مع سياسات RLS:
```sql
INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true);
CREATE POLICY "store_admin_upload" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');
```

---

#### 1.2 نظام مزدوج للتخزين بدون توحيد واضح

**التصنيف:** :yellow_circle: متوسط

يوجد نظامان لرفع الصور:

**النظام 1 - Cloudflare R2 (Edge Function):**
- **الملف:** `supabase/functions/upload-product-images/index.ts`
- يستخدم S3 SDK لرفع webp إلى R2
- يُخزّن 3 أحجام: thumb, medium, large
- CDN URL: `https://cdn.alhai.sa/products/...`

**النظام 2 - Supabase Storage (Dart):**
- **الملف:** `alhai_core/lib/src/services/image_service.dart`
- يستخدم `supabase_flutter` SDK لرفع JPEG
- يُخزّن 3 أحجام: thumb, medium, large
- URLs من Supabase Storage API

**المشكلة:** لا يوجد مكان واحد يحدد أي النظامين يجب استخدامه. الـ Edge Function ترفع webp بينما الـ Dart service يرفع JPEG. قد يؤدي ذلك لتعارضات في البيانات.

---

### 2. التحقق من الملفات المرفوعة وسياسات الرفع

#### 2.1 عدم التحقق من حجم الملف على الخادم (Edge Function)

**التصنيف:** :red_circle: حرج

**الملف:** `supabase/functions/upload-product-images/index.ts` (أسطر 7-63)

```typescript
const { product_id, hash, images } = await req.json()
// لا يوجد أي تحقق من حجم الـ images
for (const [size, base64Data] of Object.entries(images)) {
    const binaryString = atob(base64Data as string)
    // يتم رفع البيانات مباشرة بدون حد أقصى
```

**المشكلة:**
- لا يوجد حد أقصى لحجم الملف المرفوع
- بيانات Base64 يمكن أن تكون بأي حجم (هجوم DoS)
- لا يوجد تحقق من أن البيانات هي فعلاً صورة webp
- لا يوجد rate limiting على مستوى الـ function

---

#### 2.2 عدم التحقق من نوع MIME للملف (Dart ImageService)

**التصنيف:** :red_circle: حرج

**الملف:** `alhai_core/lib/src/services/image_service.dart` (أسطر 22-25)

```dart
Future<ProductImageUrls> uploadProductImage({
    required String storeId,
    required String productId,
    required File imageFile,  // أي ملف يُقبل!
}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);  // يحاول فك التشفير فقط
```

**المشكلة:**
- لا يوجد تحقق من نوع MIME قبل المعالجة
- لا يوجد حد أقصى لحجم الملف قبل القراءة في الذاكرة
- ملف ضخم (مثلاً 500MB) سيتم قراءته بالكامل في الذاكرة
- لا يوجد تحقق من امتداد الملف

**التوصية:**
```dart
// التحقق قبل المعالجة
if (await imageFile.length() > 10 * 1024 * 1024) {
    throw ImageProcessingException('File too large (max 10MB)');
}
final extension = path.extension(imageFile.path).toLowerCase();
if (!['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
    throw ImageProcessingException('Unsupported file type');
}
```

---

#### 2.3 عدم التحقق في AI Invoice Import

**التصنيف:** :yellow_circle: متوسط

**الملف:** `apps/admin/lib/screens/purchases/ai_invoice_import_screen.dart` (أسطر 198-214)

```dart
final XFile? image = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,   // ممتاز - ضغط
    maxWidth: 2000       // ممتاز - حد أقصى للعرض
);
```

**الإيجابيات:** يستخدم `imageQuality: 85` و `maxWidth: 2000` لتقليل الحجم.
**المشكلة:** لا يوجد حد أقصى لـ `maxHeight` ولا تحقق بعد الالتقاط من حجم الملف الناتج.

---

### 3. حدود حجم الملفات

#### 3.1 غياب كامل لحدود حجم الملفات

**التصنيف:** :red_circle: حرج

لا يوجد في أي مكان بالمشروع تعريف لحد أقصى لحجم الملف المرفوع:

- **Edge Function** (`upload-product-images/index.ts`): لا حد
- **ImageService** (`image_service.dart`): لا حد
- **BackupService** (`backup_service.dart`): لا حد لحجم النسخة الاحتياطية
- **WhatsApp Receipt Service** (`whatsapp_receipt_service.dart`): لا حد لحجم PDF

**الملفات المتأثرة:**
- `supabase/functions/upload-product-images/index.ts`
- `alhai_core/lib/src/services/image_service.dart`
- `alhai_services/lib/src/services/backup_service.dart`
- `packages/alhai_pos/lib/src/services/whatsapp_receipt_service.dart`

---

### 4. ضغط الصور وتحسينها

#### 4.1 نظام ضغط جيد في ImageService

**التصنيف:** :green_circle: جيد

**الملف:** `alhai_core/lib/src/services/image_service.dart` (أسطر 35-42)

```dart
final thumb = img.copyResize(image, width: 300);
final medium = img.copyResize(image, width: 600);
final large = img.copyResize(image, width: 1200);

final thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
final mediumBytes = Uint8List.fromList(img.encodeJpg(medium, quality: 85));
final largeBytes = Uint8List.fromList(img.encodeJpg(large, quality: 90));
```

**الإيجابيات:**
- ثلاثة أحجام (300, 600, 1200 بكسل)
- جودة متدرجة (80%, 85%, 90%)
- يحافظ على نسبة العرض للطول
- يستخدم SHA-256 hash للتنسيق

**المشكلة:** يُخرج JPEG بينما Edge Function تتوقع webp. ينبغي توحيد الصيغة.

---

#### 4.2 تعارض بين صيغتي الصور

**التصنيف:** :yellow_circle: متوسط

| المصدر | الصيغة | Content-Type |
|--------|--------|-------------|
| Edge Function (R2) | WebP | `image/webp` |
| ImageService (Supabase) | JPEG | `image/jpeg` |

**الملف 1:** `supabase/functions/upload-product-images/index.ts` (سطر 59):
```typescript
ContentType: 'image/webp',
```

**الملف 2:** `alhai_core/lib/src/services/image_service.dart` (سطر 159):
```dart
contentType: 'image/jpeg',
```

---

### 5. تكوين CDN

#### 5.1 CDN ممتاز عبر Cloudflare R2

**التصنيف:** :green_circle: جيد

**الملف:** `supabase/functions/upload-product-images/index.ts` (أسطر 60, 63)

```typescript
CacheControl: 'public, max-age=31536000, immutable',
// ...
urls[size] = `https://cdn.alhai.sa/${key}`
```

**الإيجابيات:**
- Cache-Control: سنة كاملة + immutable (ممتاز لأن Hash يتغير عند التحديث)
- CDN مخصص: `cdn.alhai.sa`
- مسار منظم: `products/{product_id}_{size}_{hash}.webp`

---

#### 5.2 CORS مفتوح بالكامل

**التصنيف:** :yellow_circle: متوسط

**الملف:** `supabase/functions/_shared/cors.ts` (سطر 2)

```typescript
'Access-Control-Allow-Origin': '*',
```

**المشكلة:** يسمح لأي نطاق بالوصول. يجب تقييده لنطاقات المنصة فقط:
```typescript
'Access-Control-Allow-Origin': 'https://alhai.sa, https://app.alhai.sa'
```

---

### 6. سياسات تنظيف الملفات غير المستخدمة

#### 6.1 غياب تنظيف الصور القديمة من R2

**التصنيف:** :red_circle: حرج

**الملف:** `supabase/functions/upload-product-images/index.ts`

عند رفع صورة جديدة لمنتج (hash جديد)، لا يتم حذف الصور القديمة من R2. مع مرور الوقت، ستتراكم صور orphan في التخزين.

**المشكلة:**
- لا يوجد cron job أو lifecycle policy لحذف الصور القديمة
- لا يوجد RPC أو Edge Function لتنظيف الصور المعزولة
- `deleteProductImages` موجود في `ImageService` لكن يعمل فقط مع Supabase Storage وليس R2

**الملف:** `alhai_core/lib/src/services/image_service.dart` (أسطر 133-151):
```dart
Future<void> deleteProductImages({
    required String storeId,
    required String productId,
}) async {
    // يعمل فقط مع Supabase Storage - لا يحذف من R2!
    final list = await _supabase.storage
        .from(_bucket)
        .list(path: '$storeId/$productId');
```

---

#### 6.2 غياب تنظيف الملفات المؤقتة

**التصنيف:** :yellow_circle: متوسط

**الملف:** `packages/alhai_pos/lib/src/services/whatsapp_receipt_service.dart` (أسطر 179-181)

```dart
final tempDir = await getTemporaryDirectory();
final pdfFileName = 'receipt_$receiptNo.pdf';
final pdfFile = File('${tempDir.path}/$pdfFileName');
await pdfFile.writeAsBytes(pdfBytes);
// لا يتم حذف الملف بعد الإرسال!
```

**الملف:** `packages/alhai_reports/lib/src/utils/csv_export_helper.dart` (أسطر 76-78)

```dart
final dir = await getTemporaryDirectory();
final file = File('${dir.path}/$fileName.csv');
await file.writeAsBytes(bytes);
// لا يتم حذف الملف بعد المشاركة!
```

**المشكلة:** ملفات PDF و CSV المؤقتة لا تُحذف أبداً. نظام التشغيل قد ينظفها لكن ليس مضموناً.

---

### 7. التحقق من أنواع الملفات (MIME Type Validation)

#### 7.1 لا يوجد تحقق من MIME Type في أي مكان

**التصنيف:** :red_circle: حرج

لا يوجد في المشروع بأكمله أي استخدام لـ:
- مكتبة `mime` أو `http_parser` للتحقق من نوع الملف
- فحص Magic Bytes/File Signature
- قائمة بيضاء للأنواع المسموحة

**الملفات المتأثرة:**
- `alhai_core/lib/src/services/image_service.dart` - يقبل أي `File`
- `supabase/functions/upload-product-images/index.ts` - يقبل أي base64
- `apps/admin/lib/screens/purchases/ai_invoice_import_screen.dart` - يستخدم `image_picker` فقط

**التوصية:** إضافة مكتبة `mime` وفحص قبل الرفع.

---

### 8. استراتيجيات تخزين الصور المؤقت (Caching)

#### 8.1 تخزين مؤقت ممتاز في ProductImage widget

**التصنيف:** :green_circle: جيد

**الملف:** `alhai_design_system/lib/src/components/images/product_image.dart` (أسطر 75-91)

```dart
return CachedNetworkImage(
    imageUrl: url,
    cacheManager: CacheManager(
        Config(
            'alhai_product_images',
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 2000,
        ),
    ),
    fadeInDuration: AlhaiMotion.durationFast,
    fadeOutDuration: AlhaiMotion.durationFast,
);
```

**الإيجابيات:**
- مدة صلاحية 30 يوم
- حد أقصى 2000 صورة
- اسم cache مخصص: `alhai_product_images`
- تأثير Fade In/Out

---

#### 8.2 عدم استخدام ProductImage في جميع الأماكن

**التصنيف:** :yellow_circle: متوسط

Widget `ProductImage` من `alhai_design_system` مُعد بشكل ممتاز، لكن العديد من الشاشات تستخدم `Image.network` مباشرة بدونه:

| الملف | السطر | الاستخدام |
|-------|-------|-----------|
| `apps/admin/lib/screens/media/media_library_screen.dart` | 391 | `Image.network(...)` |
| `apps/admin/lib/screens/ecommerce/ecommerce_screen.dart` | 335 | `Image.network(...)` |
| `packages/alhai_shared_ui/lib/src/screens/products/products_screen.dart` | 867 | `Image.network(...)` |
| `packages/alhai_shared_ui/lib/src/screens/products/products_screen.dart` | 1050 | `Image.network(...)` |
| `packages/alhai_shared_ui/lib/src/widgets/dashboard/top_selling_list.dart` | 146 | `Image.network(...)` |
| `packages/alhai_shared_ui/lib/src/widgets/common/app_card.dart` | 357 | `Image.network(...)` |
| `apps/cashier/lib/screens/settings/store_info_screen.dart` | 172 | `Image.network(...)` |

**المشكلة:** `Image.network` لا يستخدم `CacheManager` المخصص، مما يعني:
- لا تخزين مؤقت مُحسّن
- لا حد أقصى لعدد الصور المخزنة مؤقتاً
- لا تحكم بمدة الصلاحية

---

#### 8.3 مراقبة ذاكرة الصور (MemoryMonitor)

**التصنيف:** :green_circle: جيد

**الملف:** `packages/alhai_auth/lib/src/core/monitoring/memory_monitor.dart` (أسطر 31-162)

```dart
class MemoryMonitor {
    static const int maxMemoryMB = 150;
    static const int warningMemoryMB = 100;
    static const int criticalMemoryMB = 130;

    // تنظيف imageCache عند الضغط
    if (level == MemoryPressureLevel.critical) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
    }
}
```

**الإيجابيات:**
- مراقبة دورية كل 30 ثانية
- 3 مستويات ضغط
- تنظيف تلقائي عند الضغط العالي
- تكامل مع lifecycle (تنظيف عند الانتقال للخلفية)
- Mixin `MemoryAwareMixin` لإدارة الموارد

---

### 9. التخزين المحلي (path_provider)

#### 9.1 تشفير قاعدة البيانات المحلية

**التصنيف:** :green_circle: جيد

**الملف:** `packages/alhai_database/lib/src/connection_native.dart` (أسطر 14-40)

```dart
QueryExecutor openNativeConnection({String? dbName, String? encryptionKey}) {
    return LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'));
        // ...
        setup: (db) {
            if (encryptionKey != null && encryptionKey.isNotEmpty) {
                final safeKey = encryptionKey.replaceAll("'", "''");
                db.execute("PRAGMA key = '$safeKey'");
            }
            db.execute('PRAGMA journal_mode=WAL');
        },
    });
}
```

**الإيجابيات:**
- SQLCipher للتشفير
- WAL mode للأداء
- مسار مُنظم: `documents/alhai_pos/pos_database.sqlite`
- تعقيم مفتاح التشفير (escaping quotes)

---

#### 9.2 ملفات PDF المؤقتة للإيصالات

**التصنيف:** :yellow_circle: متوسط

**الملف:** `packages/alhai_pos/lib/src/services/whatsapp_receipt_service.dart` (أسطر 179-181)

```dart
final tempDir = await getTemporaryDirectory();
final pdfFile = File('${tempDir.path}/receipt_$receiptNo.pdf');
await pdfFile.writeAsBytes(pdfBytes);
```

**المشكلة:** يُخزن في المجلد المؤقت وهو صحيح، لكن لا يتم حذف الملف بعد الإرسال.

---

### 10. إدارة الملفات المؤقتة

#### 10.1 تصدير CSV بدون تنظيف

**التصنيف:** :yellow_circle: متوسط

**الملف:** `packages/alhai_reports/lib/src/utils/csv_export_helper.dart` (أسطر 76-85)

```dart
final dir = await getTemporaryDirectory();
final file = File('${dir.path}/$fileName.csv');
await file.writeAsBytes(bytes);

await Printing.sharePdf(
    bytes: Uint8List.fromList(bytes),
    filename: '$fileName.csv',
);

return CsvExportResult(success: true, filePath: file.path);
// لا يتم حذف الملف المؤقت!
```

**التوصية:** إضافة `finally` block لحذف الملف المؤقت:
```dart
} finally {
    if (file.existsSync()) await file.delete();
}
```

---

### 11. إدارة الأصول (Assets)

#### 11.1 تسجيل الأصول في pubspec.yaml

**التصنيف:** :green_circle: منخفض المخاطر

| التطبيق | الأصول المُسجلة |
|---------|----------------|
| `apps/cashier/pubspec.yaml` | `assets/data/` |
| `customer_app/pubspec.yaml` | `assets/images/`, `assets/icons/` |
| `driver_app/pubspec.yaml` | `assets/images/`, `assets/icons/` |
| `distributor_portal/pubspec.yaml` | `assets/images/`, `assets/icons/` |
| `super_admin/pubspec.yaml` | `assets/images/`, `assets/icons/` |

**ملاحظة:** `apps/admin` و `apps/admin_lite` لا تُسجّل أي أصول. إذا كانت تحتاج صور placeholder محلية، يجب إضافتها.

---

### 12. أنماط تحميل الصور

#### 12.1 استخدام CachedNetworkImage (3 أماكن)

**التصنيف:** :green_circle: جيد

| الملف | السطر | السياق |
|-------|-------|--------|
| `alhai_design_system/.../product_image.dart` | 75 | Widget موحد |
| `packages/alhai_pos/.../pos_screen.dart` | 1244 | شاشة POS |
| `packages/alhai_auth/.../mascot_widget.dart` | 227 | Mascot |

---

#### 12.2 استخدام Image.network بدون cache (7+ أماكن)

**التصنيف:** :yellow_circle: متوسط

كما ذُكر في القسم 8.2، هناك 7+ أماكن تستخدم `Image.network` مباشرة بدون `CachedNetworkImage`.

---

#### 12.3 استخدام NetworkImage بدون cache (5 أماكن)

**التصنيف:** :green_circle: منخفض

| الملف | السطر | السياق |
|-------|-------|--------|
| `apps/cashier/.../users_permissions_screen.dart` | 138, 655 | صورة المستخدم |
| `packages/alhai_shared_ui/.../app_sidebar.dart` | 654, 698 | صورة المستخدم |
| `packages/alhai_shared_ui/.../app_header.dart` | 587 | صورة المستخدم |

**ملاحظة:** `NetworkImage` تستخدم Flutter's image cache الافتراضي (100 صورة) وهو مقبول للصور الصغيرة مثل avatars.

---

### 13. أمان تنزيل الملفات

#### 13.1 عدم التحقق من صحة URLs

**التصنيف:** :yellow_circle: متوسط

جميع أماكن استخدام `Image.network` و `CachedNetworkImage` و `NetworkImage` لا تتحقق من:
- بروتوكول HTTPS
- أن الـ URL ينتمي لنطاقات المنصة (`cdn.alhai.sa` أو Supabase)
- عدم تضمين URLs خبيثة

**مثال - لا يوجد تحقق:**
```dart
// products_screen.dart سطر 867
Image.network(
    widget.product.imageThumbnail!, // يمكن أن يكون أي URL
    fit: BoxFit.cover,
)
```

**التوصية:** إنشاء wrapper يتحقق من الـ URL:
```dart
String? validateImageUrl(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return null;
    final allowedHosts = ['cdn.alhai.sa', 'your-project.supabase.co'];
    if (!allowedHosts.any((h) => uri.host.endsWith(h))) return null;
    return url;
}
```

---

### 14. إدارة حصص التخزين (Storage Quota)

#### 14.1 غياب كامل لإدارة الحصص

**التصنيف:** :yellow_circle: متوسط

لا يوجد في المشروع أي نظام لـ:
- تتبع حجم التخزين المستخدم لكل متجر
- تحديد حد أقصى لعدد الصور لكل متجر
- تنبيهات عند اقتراب الحد الأقصى
- ربط حصص التخزين بخطة الاشتراك

**ملاحظة:** شاشة Media Library (`apps/admin/lib/screens/media/media_library_screen.dart`) تعرض مؤشر "نسبة المنتجات التي لديها صور" لكنها لا تتبع الحجم الفعلي للتخزين.

---

### 15. توفر الملفات في وضع عدم الاتصال

#### 15.1 لا يوجد نظام تحميل مسبق للصور

**التصنيف:** :green_circle: منخفض

**المشكلة:** في وضع عدم الاتصال (offline):
- صور المنتجات المخزنة مؤقتاً ستعمل (حتى 30 يوم)
- الصور الجديدة لن تُعرض
- لا يوجد `precacheImage` لتحميل الصور المهمة مسبقاً

**ملاحظة:** `CachedNetworkImage` في `ProductImage` widget يوفر حماية جزئية (30 يوم cache) لكن لا يوجد نظام ذكي لتحميل الصور الأكثر استخداماً مسبقاً.

---

#### 15.2 قاعدة البيانات المحلية تحفظ URLs فقط

**التصنيف:** :green_circle: منخفض

**الملف:** `packages/alhai_database/lib/src/tables/products_table.dart` (أسطر 47-50)

```dart
TextColumn get imageThumbnail => text().nullable()();
TextColumn get imageMedium => text().nullable()();
TextColumn get imageLarge => text().nullable()();
TextColumn get imageHash => text().nullable()();
```

**المشكلة:** يتم حفظ URLs فقط في قاعدة البيانات المحلية، لا يتم حفظ الصور نفسها. في حالة عدم الاتصال + انتهاء cache = لا صور.

---

### 16. نتائج إضافية

#### 16.1 Edge Function لا تتحقق من ملكية المنتج

**التصنيف:** :red_circle: حرج

**الملف:** `supabase/functions/upload-product-images/index.ts` (أسطر 66-76)

```typescript
const { error: updateError } = await supabase
    .from('products')
    .update({
        image_thumbnail: urls['thumb'],
        // ...
    })
    .eq('id', product_id)
```

**المشكلة:** الـ function تستخدم `supabase` client مع auth header المستخدم، والـ RLS policies ستحمي (فقط store_admin يمكنه التعديل). لكن الرفع لـ R2 نفسه لا يتحقق من أن المستخدم له حق رفع صور لهذا المنتج. إذا فشل الـ update بسبب RLS، الصور ستبقى في R2 كملفات orphan.

---

#### 16.2 backup_service يستخدم base64 بدلاً من ضغط حقيقي

**التصنيف:** :green_circle: منخفض

**الملف:** `alhai_services/lib/src/services/backup_service.dart` (أسطر 105-108)

```dart
String _compress(String data) {
    // TODO: Implement actual compression (gzip)
    // For now, just return base64 encoded
    return base64Encode(utf8.encode(data));
}
```

**المشكلة:** base64 يزيد الحجم بـ 33% بدلاً من تقليله. TODO قديم لم يُنفذ.

---

## جدول ملخص المشاكل

| # | المشكلة | التصنيف | الملف | السطر |
|---|---------|---------|-------|-------|
| 1 | لا توجد سياسات Supabase Storage Buckets | :red_circle: حرج | `supabase/supabase_init.sql` | - |
| 2 | لا تحقق من حجم الملف في Edge Function | :red_circle: حرج | `supabase/functions/upload-product-images/index.ts` | 7 |
| 3 | لا تحقق من MIME type في ImageService | :red_circle: حرج | `alhai_core/lib/src/services/image_service.dart` | 22 |
| 4 | غياب كامل لحدود حجم الملفات | :red_circle: حرج | متعدد | - |
| 5 | لا تنظيف للصور القديمة من R2 | :red_circle: حرج | `supabase/functions/upload-product-images/index.ts` | - |
| 6 | لا تحقق من ملكية المنتج قبل الرفع لـ R2 | :red_circle: حرج | `supabase/functions/upload-product-images/index.ts` | 55 |
| 7 | نظام مزدوج للتخزين بدون توحيد | :yellow_circle: متوسط | `image_service.dart` + `index.ts` | - |
| 8 | تعارض صيغ الصور (JPEG vs WebP) | :yellow_circle: متوسط | متعدد | - |
| 9 | CORS مفتوح بالكامل (`*`) | :yellow_circle: متوسط | `supabase/functions/_shared/cors.ts` | 2 |
| 10 | لا تنظيف ملفات مؤقتة (PDF/CSV) | :yellow_circle: متوسط | `whatsapp_receipt_service.dart` + `csv_export_helper.dart` | 179, 76 |
| 11 | Image.network بدون cache (7+ أماكن) | :yellow_circle: متوسط | متعدد | - |
| 12 | لا تحقق من صحة URLs للصور | :yellow_circle: متوسط | متعدد | - |
| 13 | غياب إدارة حصص التخزين | :yellow_circle: متوسط | - | - |
| 14 | لا تحقق في AI Invoice Import بعد الالتقاط | :yellow_circle: متوسط | `ai_invoice_import_screen.dart` | 198 |
| 15 | لا تحميل مسبق للصور (offline) | :green_circle: منخفض | - | - |
| 16 | URLs فقط في DB المحلية (لا صور offline) | :green_circle: منخفض | `products_table.dart` | 47 |
| 17 | admin/admin_lite لا تُسجّل أصول | :green_circle: منخفض | `pubspec.yaml` | - |
| 18 | backup_service يستخدم base64 بدلاً من gzip | :green_circle: منخفض | `backup_service.dart` | 105 |
| 19 | NetworkImage بدون cache مخصص (avatars) | :green_circle: منخفض | متعدد | - |

---

## إحصائيات المشاكل

| التصنيف | العدد | النسبة |
|---------|-------|--------|
| :red_circle: حرج | 6 | 31.6% |
| :yellow_circle: متوسط | 8 | 42.1% |
| :green_circle: منخفض | 5 | 26.3% |
| **الإجمالي** | **19** | **100%** |

---

## التوصيات مرتبة حسب الأولوية

### أولوية 1 - فوري (خلال أسبوع)

1. **إضافة حد أقصى لحجم الملف في Edge Function**
   - الملف: `supabase/functions/upload-product-images/index.ts`
   - الحد المقترح: 10MB لكل صورة
   ```typescript
   const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
   for (const [size, base64Data] of Object.entries(images)) {
       if ((base64Data as string).length > MAX_IMAGE_SIZE * 1.37) {
           return new Response(JSON.stringify({ error: 'Image too large' }), { status: 413 });
       }
   }
   ```

2. **إضافة تحقق MIME type و حجم في ImageService**
   - الملف: `alhai_core/lib/src/services/image_service.dart`
   - التحقق من الامتداد والحجم قبل القراءة

3. **إضافة تحقق ملكية المنتج في Edge Function**
   - التأكد من أن المستخدم عضو في المتجر الذي يملك المنتج قبل الرفع لـ R2

### أولوية 2 - مهم (خلال أسبوعين)

4. **إنشاء سياسات Supabase Storage Buckets**
   - إضافة migration جديد لإنشاء bucket مع RLS

5. **تقييد CORS**
   - تحديد النطاقات المسموحة بدلاً من `*`

6. **استبدال `Image.network` بـ `ProductImage` widget**
   - في جميع الشاشات الـ 7+ المذكورة

7. **إضافة تنظيف الملفات المؤقتة**
   - `whatsapp_receipt_service.dart` و `csv_export_helper.dart`

### أولوية 3 - تحسين (خلال شهر)

8. **إنشاء Lifecycle Policy لـ R2**
   - حذف الصور التي لم يُشر إليها في DB
   - cron job أسبوعي

9. **توحيد صيغة الصور**
   - اختيار WebP كصيغة موحدة (أفضل ضغط)

10. **إضافة نظام حصص التخزين**
    - حصة لكل متجر مربوطة بخطة الاشتراك

11. **تنفيذ ضغط حقيقي في BackupService**
    - استبدال base64 بـ gzip

### أولوية 4 - تحسين مستقبلي

12. **تحميل مسبق للصور الأكثر استخداماً**
    - عند فتح التطبيق مع اتصال

13. **إضافة تحقق من صحة URLs**
    - قائمة بيضاء للنطاقات المسموحة

---

## التقييم العام

| المعيار | الدرجة (من 10) |
|---------|---------------|
| بنية التخزين (R2 + CDN) | 8/10 |
| ضغط الصور وتحسينها | 7/10 |
| التخزين المؤقت (Caching) | 7/10 |
| أمان الرفع (Upload Security) | 3/10 |
| التحقق من الملفات (Validation) | 2/10 |
| تنظيف الملفات (Cleanup) | 2/10 |
| إدارة الحصص (Quota) | 1/10 |
| التخزين المحلي (Local Storage) | 8/10 |
| مراقبة الذاكرة (Memory) | 9/10 |
| التوفر في وضع عدم الاتصال | 5/10 |

### **التقييم النهائي: 5.5 / 10**

المنصة تمتلك بنية تحتية جيدة للتخزين (R2 + CDN + caching + memory monitor) لكنها تفتقر بشكل حاد للتحقق الأمني من الملفات المرفوعة (حجم، نوع، ملكية) ولسياسات تنظيف الملفات. إصلاح المشاكل الحرجة الـ 6 سيرفع التقييم إلى ~7.5/10.

---

*تم إنشاء هذا التقرير بتاريخ 2026-02-26 بمساعدة Claude Opus 4.6*
