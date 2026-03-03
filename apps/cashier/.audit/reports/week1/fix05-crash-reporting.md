# Fix 05 — تكامل Sentry Crash Reporting (🔴 حرج)
# الوقت: 4-6 ساعات | الأولوية: 5

أنت مطور Flutter خبير في المراقبة.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبة sentry_flutter

## المهام
1. `flutter pub add sentry_flutter`
2. عدّل main.dart بـ SentryFlutter.init مع DSN من --dart-define
3. استبدل كل debugPrint في catch blocks بـ Sentry.captureException
4. عدّل runZonedGuarded و FlutterError.onError ليرسلوا لـ Sentry
5. أضف Sentry breadcrumbs للعمليات المهمة (بيع، دفع، تسجيل دخول)

```bash
grep -rn "debugPrint.*error\|debugPrint.*Error\|debugPrint.*fail\|runZonedGuarded\|FlutterError.onError" lib/ --include="*.dart" | head -30
```

سجّل التغييرات في: `.audit/fixes/fix05-log.md`
ابدأ فوراً. لا تسأل أسئلة.
