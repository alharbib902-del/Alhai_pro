# Fix 14 — حفظ السلة محلياً + مراقبة الاتصال (🟡 مهم)
# الوقت: 6-10 ساعات | الأولوية: 14

أنت مطور Flutter خبير.

## المهام — حفظ السلة
1. أضف جدول draft_orders أو استخدم الموجود
2. احفظ السلة تلقائياً كل تعديل (مع debounce 2 ثانية)
3. استعد السلة عند فتح التطبيق مع dialog تأكيد

## المهام — مراقبة الاتصال
4. `flutter pub add connectivity_plus`
5. أنشئ ConnectivityService
6. أضف banner offline/online في أعلى الشاشة
7. فعّل SyncQueue الموجود عند عودة الاتصال

```bash
grep -rn "draft\|Draft\|cart\|Cart\|sync\|Sync\|SyncQueue" lib/ --include="*.dart" | head -20
```

سجّل التغييرات في: `.audit/fixes/fix14-log.md`
ابدأ فوراً. لا تسأل أسئلة.
