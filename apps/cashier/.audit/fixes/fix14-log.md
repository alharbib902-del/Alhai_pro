# Fix 14 — حفظ السلة محلياً + مراقبة الاتصال

## التاريخ: 2026-03-01

---

## الملخص

تم تحسين حفظ السلة المحلي وتأكيد وجود مراقبة الاتصال الكاملة.

---

## التغييرات

### 1. حفظ السلة مع Debounce (2 ثانية)

**الملف:** `packages/alhai_pos/lib/src/providers/cart_providers.dart`

- أضفنا `dart:async` import لاستخدام `Timer`
- أضفنا `Timer? _debounceTimer` في `CartNotifier`
- غيرنا `_saveCart()` من حفظ فوري إلى حفظ مع debounce 2 ثانية
- أضفنا `dispose()` override لحفظ فوري عند إغلاق التطبيق

**قبل:**
```dart
Future<void> _saveCart() async {
  await _persistence.saveCart(state);
}
```

**بعد:**
```dart
void _saveCart() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(seconds: 2), () {
    _persistence.saveCart(state);
  });
}
```

### 2. استعادة السلة مع dialog تأكيد

**الملف:** `packages/alhai_pos/lib/src/providers/cart_providers.dart`

- غيرنا `_init()` من استعادة تلقائية صامتة إلى حفظ المسودة بانتظار التأكيد
- أضفنا `_pendingDraft` field لحفظ السلة المحملة
- أضفنا properties: `hasPendingDraft`, `pendingDraftItemCount`, `pendingDraftTotal`
- أضفنا methods: `acceptDraft()`, `discardDraft()`
- أضفنا `hasPendingDraftProvider` provider

**الملف:** `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart`

- أضفنا `_checkPendingDraft()` method في `initState()`
- يعرض `AlertDialog` مع عدد العناصر والإجمالي
- زر "استعادة" و "إلغاء"
- عند القبول: `acceptDraft()` → استعادة السلة
- عند الرفض: `discardDraft()` → مسح السلة المحفوظة

### 3. ترقية شريط الاتصال

**الملف:** `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart`

- رقّينا من `OfflineBanner()` إلى `StatusBanners()` (يشمل شريط الاتصال + عدد عمليات المزامنة المعلقة)

### 4. مراقبة الاتصال (موجود مسبقاً)

البنية التحتية كانت مكتملة مسبقاً:
- **ConnectivityService** في `packages/alhai_sync/` — يراقب الاتصال عبر `connectivity_plus`
- **OfflineBanner** و **SyncPendingBanner** في `packages/alhai_shared_ui/`
- **SyncManager** يفعّل `syncPending()` تلقائياً عند عودة الاتصال
- **isOnlineProvider** يبث حالة الاتصال كـ Stream

---

## الملفات المعدلة

| الملف | التغيير |
|---|---|
| `packages/alhai_pos/lib/src/providers/cart_providers.dart` | debounce + deferred restore + pending draft |
| `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` | restore dialog + StatusBanners |

## النتيجة

- السلة تُحفظ تلقائياً كل 2 ثانية (بدلاً من كل تعديل)
- عند فتح التطبيق مع سلة محفوظة: يظهر dialog للتأكيد
- شريط offline/online يعمل مع عدد العمليات المعلقة
- SyncQueue يتفعل تلقائياً عند عودة الاتصال
