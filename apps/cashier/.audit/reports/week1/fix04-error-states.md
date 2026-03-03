# Fix 04 — إضافة Error States + Empty States + Loading States (🔴 حرج)
# الوقت: 8-12 ساعة | الأولوية: 4

أنت مطور Flutter خبير في UX. حالياً 47 شاشة فيها try/catch صامت بدون أي تنبيه للمستخدم.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إنشاء widgets مشتركة جديدة في shared_ui

## المهام

### 1. أنشئ 3 widgets مشتركة في packages/shared_ui/lib/widgets/:
- `error_state_widget.dart` — أيقونة خطأ + رسالة + زر إعادة المحاولة
- `empty_state_widget.dart` — أيقونة + رسالة + زر إضافة اختياري
- `loading_state_widget.dart` — CircularProgressIndicator مع رسالة اختيارية

### 2. ابحث عن كل try/catch الصامت
```bash
grep -rn -A3 "catch (e" lib/features/ --include="*.dart" | grep -B1 "debugPrint\|// \|print\|{$" | head -60
```

### 3. أصلح كل شاشة بإضافة:
- `_isLoading` state
- `_error` state (String?)
- في build: if error → ErrorStateWidget, if loading → Loading, if empty → Empty, else → content

### 4. ابدأ بالشاشات الأهم:
1. شاشة البيع POS
2. المنتجات
3. المبيعات/التقارير
4. المخزون
5. العملاء
6. الإعدادات
7. باقي الشاشات

سجّل التغييرات في: `.audit/fixes/fix04-log.md`
ابدأ فوراً. لا تسأل أسئلة.
