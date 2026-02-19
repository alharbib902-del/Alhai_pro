/**
 * Agent A: Finance (المالية)
 * الوكيل المسؤول عن جميع شاشات القسم المالي
 */

module.exports = {
  categorySlug: 'finance',
  categoryName: 'Finance',
  categoryNameAr: 'المالية',
  categoryDescriptionAr: 'يشمل هذا القسم جميع الشاشات المتعلقة بالعمليات المالية: الفواتير، الطلبات، المرتجعات، إلغاء المعاملات، المصروفات وفئاتها، التقارير، درج النقد، والإغلاق الشهري.',
  screens: [
    // ── 1. الفواتير ──
    {
      name: 'Invoices',
      nameAr: 'الفواتير',
      path: '/invoices',
      screenSlug: 'invoices',
      descriptionAr: 'شاشة عرض جميع فواتير المبيعات المُصدَرة. تعرض قائمة بكل فاتورة مع رقمها وتاريخها ومبلغها وحالتها (مدفوعة / معلقة / جزئية). تتيح البحث برقم الفاتورة والتصفية حسب التاريخ والحالة، مع إمكانية النقر على أي فاتورة لعرض تفاصيلها الكاملة وطباعتها.',
      features: ['قائمة الفواتير مع الفلاتر', 'البحث برقم الفاتورة', 'تصفية بنطاق التاريخ', 'تصفية بالحالة (مدفوعة/معلقة/جزئية)', 'تصدير الفواتير'],
      expectedBehaviors: ['عرض قائمة الفواتير أو رسالة حالة فارغة', 'أدوات التصفية تفاعلية', 'كل صف فاتورة قابل للنقر'],
      scenarios: [{ scenarioName: 'عرض الفواتير', dataState: 'any', setup: [], tests: [
        { stepName: 'التحقق من تحميل الصفحة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="invoice" i]', text: 'text=/invoice|فواتير/i', css: '.invoices-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/invoices|الفواتير/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من المحتوى أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*invoice|لا توجد/i', css: '.empty-state, table' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['تفاصيل الفاتورة تحتاج معرّف فاتورة صالح', 'التصدير يحتاج بيانات'],
    },

    // ── 2. سجل الطلبات ──
    {
      name: 'Orders',
      nameAr: 'سجل الطلبات',
      path: '/orders',
      screenSlug: 'orders',
      descriptionAr: 'شاشة سجل الطلبات تعرض جميع طلبات العملاء مُرتَّبة زمنياً. تشمل رقم الطلب واسم العميل وإجمالي المبلغ وحالة الطلب (جديد / قيد التجهيز / مكتمل / ملغي). يمكن تصفية الطلبات حسب الحالة والبحث فيها، مع دعم عرض تفاصيل كل طلب بالنقر عليه.',
      features: ['قائمة الطلبات', 'تتبع حالة الطلب', 'التصفية بالحالة', 'البحث في الطلبات'],
      expectedBehaviors: ['عرض الطلبات أو حالة فارغة', 'الفلاتر تعمل', 'مؤشرات الحالة ظاهرة'],
      scenarios: [{ scenarioName: 'عرض سجل الطلبات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للطلبات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="order" i]', text: 'text=/orders|الطلبات/i', css: '.orders-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/orders|الطلبات/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*order|لا توجد/i', css: '.empty-state, table' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['تفاصيل الطلب تحتاج معرّف طلب صالح'],
    },

    // ── 3. المرتجعات ──
    {
      name: 'Returns',
      nameAr: 'المرتجعات',
      path: '/returns',
      screenSlug: 'returns',
      descriptionAr: 'شاشة إدارة المرتجعات تعرض جميع عمليات إرجاع المنتجات. تتضمن رقم عملية الإرجاع والفاتورة الأصلية وسبب الإرجاع ومبلغ الاسترداد وحالته (مُعالَج / معلق). تدعم البحث والتصفية لمتابعة حالة كل عملية إرجاع.',
      features: ['قائمة المرتجعات', 'تتبع سبب الإرجاع', 'حالة الاسترداد', 'البحث في المرتجعات'],
      expectedBehaviors: ['عرض المرتجعات أو حالة فارغة', 'أدوات التصفية موجودة'],
      scenarios: [{ scenarioName: 'عرض المرتجعات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للمرتجعات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="return" i]', text: 'text=/returns|المرتجعات/i', css: '.returns-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/return|مرتجع/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*return|لا توجد/i', css: '.empty-state, table' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 4. إلغاء المعاملات ──
    {
      name: 'Void Transaction',
      nameAr: 'إلغاء المعاملات',
      path: '/void-transaction',
      screenSlug: 'void-transaction',
      descriptionAr: 'شاشة إلغاء المعاملات تسمح بإبطال فاتورة بيع سابقة بالكامل. يتم البحث عن المعاملة بالرقم أو مسح الباركود، ثم تحديد سبب الإلغاء مع طلب تصريح إداري. بعد التأكيد يتم عكس العملية المالية وإعادة المخزون.',
      features: ['نموذج إلغاء المعاملة', 'اختيار السبب', 'متطلب تصريح إداري'],
      expectedBehaviors: ['يُحمَّل النموذج أو البحث عن المعاملة', 'حقل سبب الإلغاء موجود'],
      scenarios: [{ scenarioName: 'عرض إلغاء المعاملات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لإلغاء المعاملات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="void" i]', text: 'text=/void|إلغاء/i', css: '.void-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/void|إلغاء.*معاملة/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من النموذج أو البحث', action: 'check-content', selectorStrategy: { aria: 'input, [role="search"]', text: 'text=/search|بحث/i', css: 'input, form' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج معاملة صالحة للإلغاء'],
    },

    // ── 5. المصروفات ──
    {
      name: 'Expenses',
      nameAr: 'المصروفات',
      path: '/expenses',
      screenSlug: 'expenses',
      descriptionAr: 'شاشة إدارة المصروفات تعرض جميع المصروفات التشغيلية للمتجر (إيجار، رواتب، صيانة، إلخ). تعرض بطاقات إحصائية في الأعلى بإجمالي المصروفات ومصروفات اليوم والشهر. تتيح إضافة مصروف جديد مع تحديد الفئة والمبلغ والملاحظات، والتصفية حسب الفئة والتاريخ.',
      features: ['قائمة المصروفات', 'زر إضافة مصروف', 'تصفية بالفئة', 'تصفية بالتاريخ', 'ملخص الإجمالي'],
      expectedBehaviors: ['عرض قائمة المصروفات أو حالة فارغة', 'زر الإضافة موجود', 'الفلاتر تعمل'],
      scenarios: [{ scenarioName: 'عرض المصروفات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للمصروفات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="expense" i]', text: 'text=/expense|المصروفات/i', css: '.expenses-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/expense|مصروف/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإضافة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|إضافة|\\+/i', css: '.fab, button' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 6. فئات المصروفات ──
    {
      name: 'Expense Categories',
      nameAr: 'فئات المصروفات',
      path: '/expenses/categories',
      screenSlug: 'expense-categories',
      descriptionAr: 'شاشة فئات المصروفات تُدير تصنيفات المصروفات (إيجار، كهرباء، رواتب، تسويق، صيانة...). يمكن إضافة فئات جديدة وتعديل القائمة الموجودة مع تحديد أيقونة ولون لكل فئة. تُستخدم هذه الفئات عند تسجيل أي مصروف جديد.',
      features: ['قائمة الفئات', 'إضافة فئة', 'تعديل فئة'],
      expectedBehaviors: ['عرض الفئات أو حالة فارغة', 'زر الإضافة موجود'],
      scenarios: [{ scenarioName: 'عرض فئات المصروفات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لفئات المصروفات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="categor" i]', text: 'text=/categor|الفئات/i', css: '.categories-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/categor|فئات/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*categor|لا توجد/i', css: '.list-view, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 7. التقارير ──
    {
      name: 'Reports',
      nameAr: 'التقارير',
      path: '/reports',
      screenSlug: 'reports',
      descriptionAr: 'شاشة التقارير المالية والإدارية تعرض لوحة متكاملة من التقارير: تقرير المبيعات اليومي/الأسبوعي/الشهري، تقرير المنتجات الأكثر مبيعاً، تقرير المصروفات، تقرير الأرباح والخسائر. تتضمن رسوماً بيانية تفاعلية مع إمكانية اختيار نطاق التاريخ وتصدير التقارير بصيغة PDF أو Excel.',
      features: ['أنواع التقارير', 'اختيار نطاق التاريخ', 'توليد التقارير', 'رسوم بيانية', 'تصدير'],
      expectedBehaviors: ['فئات التقارير ظاهرة', 'منتقيات التاريخ تعمل', 'الرسوم البيانية تظهر أو حالة فارغة'],
      scenarios: [{ scenarioName: 'لوحة التقارير', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للتقارير', action: 'navigate', selectorStrategy: { aria: '[aria-label*="report" i]', text: 'text=/report|التقارير/i', css: '.reports-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/report|تقارير/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من خيارات التقارير', action: 'check-content', selectorStrategy: { aria: '[role="button"], [role="tab"]', text: 'text=/sales|مبيعات/i', css: '.report-card, button' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['الرسوم البيانية تحتاج بيانات مبيعات لتكون ذات معنى'],
    },

    // ── 8. درج النقد ──
    {
      name: 'Cash Drawer',
      nameAr: 'درج النقد',
      path: '/cash-drawer',
      screenSlug: 'cash-drawer',
      descriptionAr: 'شاشة درج النقد تعرض حالة الصندوق النقدي الحالي: الرصيد المتوقع والفعلي والفرق بينهما. تتيح عمليات إيداع وسحب نقدي مع تسجيل السبب. تعرض سجل جميع حركات النقد خلال الوردية الحالية. ترتبط بنظام الورديات حيث يُفتح الصندوق ببداية كل وردية ويُغلق بنهايتها.',
      features: ['رصيد الصندوق', 'عمليات إيداع/سحب', 'سجل الحركات', 'المطابقة'],
      expectedBehaviors: ['عرض الرصيد الحالي أو طلب إعداد', 'أزرار الإيداع/السحب موجودة'],
      scenarios: [{ scenarioName: 'عرض درج النقد', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لدرج النقد', action: 'navigate', selectorStrategy: { aria: '[aria-label*="cash" i]', text: 'text=/cash.*drawer|الصندوق/i', css: '.cash-drawer-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/cash|صندوق/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من عرض الرصيد', action: 'check-content', selectorStrategy: { aria: '[role="status"]', text: 'text=/balance|رصيد|ر.س/i', css: '.balance-display, .amount' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج وردية مفتوحة لكامل الوظائف'],
    },

    // ── 9. الإغلاق الشهري ──
    {
      name: 'Monthly Close',
      nameAr: 'الإغلاق الشهري',
      path: '/debts/monthly-close',
      screenSlug: 'monthly-close',
      descriptionAr: 'شاشة الإغلاق الشهري للديون تعرض ملخص ديون العملاء المستحقة خلال الشهر. تتضمن إجمالي الديون والمبالغ المُحصّلة والمتبقية مع كشف تفصيلي لكل عميل. تسمح بإغلاق الفترة المحاسبية الشهرية بعد مراجعة جميع الحسابات والتأكد من صحة الأرصدة.',
      features: ['ملخص شهري', 'تسوية الديون', 'اختيار الفترة', 'إجراء إغلاق الفترة'],
      expectedBehaviors: ['عرض الملخص الشهري أو حالة فارغة', 'منتقي الفترة موجود'],
      scenarios: [{ scenarioName: 'عرض الإغلاق الشهري', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للإغلاق الشهري', action: 'navigate', selectorStrategy: { aria: '[aria-label*="month" i]', text: 'text=/monthly|شهري|إغلاق/i', css: '.monthly-close-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/monthly|إغلاق.*شهري/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من محتوى الفترة', action: 'check-content', selectorStrategy: { aria: '[role="table"], select', text: 'text=/period|فترة|شهر/i', css: '.period-selector, .summary' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج سجلات ديون لبيانات ذات معنى'],
    },
  ],
};
