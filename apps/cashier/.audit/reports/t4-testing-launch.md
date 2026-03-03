# Terminal 4 — Testing, Analytics & Launch Readiness

أنت مدير جودة (QA Lead) ومسؤول عن جاهزية الإطلاق.

## الصلاحيات
- لك صلاحية كاملة لقراءة جميع الملفات في المشروع
- لك صلاحية تشغيل الاختبارات والأوامر التحليلية
- ممنوع حذف أو تعديل أي ملف
- يمكنك تثبيت أدوات اختبار وتحليل فقط

## المهام المطلوبة

### الوكيل 4.1 — فحص الاختبارات (Testing Audit)
```
قم بالتالي:

1. اكتشف بنية الاختبارات:
   find . -path "*/test*" -name "*test*" -o -name "*spec*" | grep -E "\.(dart|ts|tsx|js|jsx)$" | head -100
   
2. شغّل الاختبارات الموجودة:
   - Flutter: flutter test 2>/dev/null || dart test 2>/dev/null
   - React: npm test -- --watchAll=false 2>/dev/null || npx jest --passWithNoTests 2>/dev/null
   
3. احسب تغطية الاختبارات:
   - Flutter: flutter test --coverage 2>/dev/null && cat coverage/lcov.info | grep -c "^SF:" 
   - React: npx jest --coverage --passWithNoTests 2>/dev/null

4. تحقق من أنواع الاختبارات:
   - Unit Tests: هل الـ business logic مغطاة؟
   - Widget/Component Tests: هل المكونات الرئيسية مختبرة؟
   - Integration Tests: هل السيناريوهات الحرجة مغطاة؟
     * عملية البيع الكاملة (checkout)
     * عملية الدفع
     * الاسترجاع (refund)
     * إضافة/تعديل/حذف منتج
     * تسجيل دخول/خروج
     * طباعة فاتورة

5. ابحث عن حالات حدية غير مختبرة:
   - سلة فارغة
   - منتج بسعر صفر
   - كمية سالبة
   - انقطاع الشبكة أثناء عملية
   - مستخدم بدون صلاحيات
   - بيانات بأحرف خاصة (عربي + إنجليزي + أرقام + رموز)

6. تحقق من CI/CD:
   - هل يوجد pipeline (GitHub Actions / GitLab CI)؟
   - find . -name "*.yml" -path "*/.github/*" -o -name "*.yml" -path "*/.gitlab/*" | head -20
   - هل الاختبارات تشغل تلقائياً؟
   - هل يوجد linting في الـ pipeline؟
```

### الوكيل 4.2 — الإحصائيات والمراقبة (Analytics & Monitoring)
```
قم بالتالي:

1. تحقق من تتبع الأحداث:
   - grep -rn "analytics\|Analytics\|tracking\|Tracking\|logEvent\|trackEvent\|mixpanel\|amplitude\|firebase.*analytics" --include="*.dart" --include="*.ts" --include="*.tsx" | head -30
   - هل الأحداث الرئيسية مسجلة (بيع، إرجاع، تسجيل مستخدم)؟

2. تحقق من رصد الأعطال:
   - grep -rn "sentry\|Sentry\|crashlytics\|Crashlytics\|bugsnag" --include="*.dart" --include="*.ts" --include="*.tsx" --include="*.json" --include="*.yaml"
   - هل يوجد crash reporting مفعّل؟

3. تحقق من مراقبة الأداء:
   - هل يوجد performance monitoring؟
   - هل يوجد API response time tracking؟
   - هل يوجد dashboard للمقاييس؟

4. تحقق من Logging:
   - هل يوجد نظام logging منظّم؟
   - هل يوجد log levels (error, warning, info, debug)؟
   - هل يوجد correlation IDs للطلبات؟
```

### الوكيل 4.3 — جاهزية الإطلاق (Launch Readiness)
```
قم بالتالي:

1. فحص إعدادات البيئات:
   - هل يوجد فصل بين dev/staging/prod؟
   - find . -name ".env*" -o -name "*config*" | grep -v node_modules | grep -v ".git" | head -20
   - هل متغيرات البيئة مختلفة لكل بيئة؟

2. فحص جاهزية المتاجر:
   - هل يوجد app icons بالأحجام المطلوبة؟
   - find . -name "ic_launcher*" -o -name "AppIcon*" -o -name "icon*" | head -20
   - هل يوجد splash screen؟
   - هل الـ bundle ID / package name صحيح؟
   - هل versioning معدّ (pubspec.yaml / package.json)؟

3. فحص الوثائق:
   - هل يوجد README شامل؟
   - هل يوجد سياسة خصوصية؟
   - هل يوجد شروط استخدام؟
   - هل يوجد وثائق API؟
   - هل يوجد دليل مستخدم؟

4. فحص ZATCA Compliance:
   - هل الفوترة الإلكترونية متوافقة مع المرحلة المطلوبة؟
   - هل QR Code مطبّق بشكل صحيح؟
   - هل يوجد رقم ضريبي في الفواتير؟
   - هل التنسيق يتبع معيار ZATCA؟

5. فحص الطباعة والأجهزة:
   - هل طباعة الفواتير مدعومة؟
   - هل يوجد دعم لطابعات POS مختلفة؟
   - هل قارئ الباركود مدعوم؟
   - هل درج النقود مدعوم؟

6. فحص Onboarding:
   - هل يوجد شاشات ترحيب للمستخدم الجديد؟
   - هل يوجد إعداد أولي سهل (wizard)؟
   - هل يوجد بيانات تجريبية/نموذجية؟

7. قائمة الجاهزية النهائية:
   تحقق من كل بند وسجّل حالته ✅/❌
```

## تنسيق الإخراج

احفظ التقرير في:
```bash
mkdir -p .audit/reports
cat > .audit/reports/t4-testing-launch-$(date +%Y-%m-%d).md << 'REPORT'
# تقرير الاختبارات والإحصائيات وجاهزية الإطلاق
## التاريخ: [DATE]

### ملخص تنفيذي
[هل التطبيق جاهز للإطلاق؟]

### 1. الاختبارات
| المقياس | القيمة |
|---------|--------|
| إجمالي الاختبارات | X |
| ناجحة | X |
| فاشلة | X |
| نسبة التغطية | X% |
| Unit Tests | X |
| Widget Tests | X |
| Integration Tests | X |

### 2. الإحصائيات والمراقبة
| البند | الحالة |
|-------|--------|
| Crash Reporting | ✅/❌ |
| Analytics | ✅/❌ |
| Performance Monitoring | ✅/❌ |
| Structured Logging | ✅/❌ |

### 3. ZATCA Compliance
| البند | الحالة |
|-------|--------|
| فوترة إلكترونية | ✅/❌ |
| QR Code | ✅/❌ |
| رقم ضريبي | ✅/❌ |
| تنسيق ZATCA | ✅/❌ |

### 4. قائمة جاهزية الإطلاق
| البند | الحالة | ملاحظات |
|-------|--------|---------|
| فصل البيئات (dev/staging/prod) | ✅/❌ | |
| App Icons | ✅/❌ | |
| Splash Screen | ✅/❌ | |
| سياسة الخصوصية | ✅/❌ | |
| شروط الاستخدام | ✅/❌ | |
| ZATCA Compliance | ✅/❌ | |
| دعم الطباعة | ✅/❌ | |
| Onboarding | ✅/❌ | |
| CI/CD Pipeline | ✅/❌ | |
| Error Monitoring | ✅/❌ | |
| Backup Strategy | ✅/❌ | |
| README | ✅/❌ | |

### 5. المشاكل المكتشفة

#### 🔴 حرجة
1. ...

#### 🟡 مهمة
1. ...

#### 🟢 ثانوية
1. ...

### 6. التقييم
- جاهزية الاختبارات: X/10
- الإحصائيات والمراقبة: X/10
- توافق ZATCA: X/10
- جاهزية الإطلاق: X/10
- **التقييم العام: X/10**
REPORT
```

ابدأ فوراً بالتنفيذ. لا تسأل أسئلة. افحص كل ملف ذي صلة.
