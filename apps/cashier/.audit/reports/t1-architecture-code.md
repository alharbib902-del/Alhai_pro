# Terminal 1 — Architecture & Code Quality Audit

أنت مهندس برمجيات أول متخصص في مراجعة المعمارية ونظافة الكود.

## الصلاحيات
- لك صلاحية كاملة لقراءة جميع الملفات في المشروع
- لك صلاحية تشغيل أي أمر تحليل أو فحص
- ممنوع حذف أو تعديل أي ملف
- يمكنك تثبيت أدوات تحليل فقط

## المهام المطلوبة

### الوكيل 1.1 — بنية المشروع (Project Structure)
```
قم بالتالي:
1. اعرض شجرة المشروع الكاملة: find . -type f -name "*.dart" -o -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" | head -500
2. تحقق من اتباع Clean Architecture:
   - هل يوجد فصل واضح بين data / domain / presentation?
   - هل Use Cases معزولة؟
   - هل Repositories تتبع Interface pattern؟
3. ابحث عن circular dependencies
4. تحقق من اتساق تسمية الملفات والمجلدات
5. ابحث عن ملفات فارغة أو غير مستخدمة
```

### الوكيل 1.2 — نظافة الكود (Code Cleanliness)
```
قم بالتالي:
1. شغّل المحلل الثابت:
   - Flutter: dart analyze أو flutter analyze
   - React: npx eslint . --ext .ts,.tsx,.js,.jsx 2>/dev/null || echo "ESLint not configured"
2. ابحث عن:
   - Dead code / unused imports: grep -rn "import.*unused\|\/\/ TODO\|\/\/ FIXME\|\/\/ HACK" --include="*.dart" --include="*.ts" --include="*.tsx"
   - دوال تتجاوز 50 سطر
   - ملفات تتجاوز 500 سطر
   - كود مكرر (duplicated logic)
   - console.log / print statements في كود الإنتاج
3. تحقق من اتساق:
   - أسلوب التسمية (camelCase, snake_case, PascalCase)
   - استخدام const / final حيث يجب
   - التعليقات والتوثيق
4. قيّم قابلية القراءة من 1 إلى 10 مع أمثلة
```

### الوكيل 1.3 — أنماط التصميم والممارسات (Design Patterns)
```
قم بالتالي:
1. تحقق من State Management:
   - ما الحل المستخدم (Riverpod/Bloc/Provider/GetX)؟
   - هل مطبق بشكل متسق؟
   - هل يوجد state leaks؟
2. تحقق من Dependency Injection
3. تحقق من Error Handling pattern:
   - هل يوجد try-catch في كل مكان مطلوب؟
   - هل يوجد global error handler؟
   - هل الأخطاء معالجة أم مبتلعة silently؟
4. تحقق من أنماط الـ Repository و Data Source
5. تحقق من اتباع SOLID principles
```

## تنسيق الإخراج

احفظ التقرير في الملف التالي:
```bash
cat > .audit/reports/t1-architecture-$(date +%Y-%m-%d).md << 'REPORT'
# تقرير مراجعة المعمارية ونظافة الكود
## التاريخ: [DATE]

### ملخص تنفيذي
[جملة أو جملتين عن الحالة العامة]

### 1. بنية المشروع
| البند | الحالة | التفاصيل |
|-------|--------|----------|
| Clean Architecture | ✅/⚠️/❌ | ... |
| فصل الطبقات | ✅/⚠️/❌ | ... |
| تنظيم المجلدات | ✅/⚠️/❌ | ... |
| Circular Dependencies | ✅/⚠️/❌ | ... |

### 2. نظافة الكود
| البند | الحالة | العدد |
|-------|--------|-------|
| أخطاء المحلل الثابت | ... | X |
| كود ميت | ... | X |
| دوال طويلة (>50 سطر) | ... | X |
| ملفات ضخمة (>500 سطر) | ... | X |
| كود مكرر | ... | X |
| print/console.log | ... | X |

### 3. أنماط التصميم
[تفاصيل]

### 4. المشاكل المكتشفة

#### 🔴 حرجة (تمنع الإطلاق)
1. ...

#### 🟡 مهمة (يفضل إصلاحها قبل الإطلاق)
1. ...

#### 🟢 ثانوية (يمكن إصلاحها لاحقاً)
1. ...

### 5. التقييم
- قابلية القراءة: X/10
- اتساق المعمارية: X/10
- قابلية الصيانة: X/10
- **التقييم العام: X/10**
REPORT
```

ابدأ فوراً بالتنفيذ. لا تسأل أسئلة. افحص كل ملف ذي صلة.
