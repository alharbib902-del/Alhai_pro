/**
 * Agent B: Shifts (الورديات)
 * الوكيل المسؤول عن جميع شاشات إدارة الورديات
 */

module.exports = {
  categorySlug: 'shifts',
  categoryName: 'Shifts',
  categoryNameAr: 'الورديات',
  categoryDescriptionAr: 'يشمل هذا القسم إدارة ورديات العمل: عرض سجل الورديات السابقة، فتح وردية جديدة مع تحديد الرصيد الافتتاحي، إغلاق الوردية الحالية مع جرد الصندوق، وعرض الملخص التفصيلي لكل وردية.',
  screens: [
    // ── 1. سجل الورديات ──
    {
      name: 'Shifts',
      nameAr: 'سجل الورديات',
      path: '/shifts',
      screenSlug: 'shifts-list',
      descriptionAr: 'شاشة سجل الورديات تعرض قائمة بجميع الورديات السابقة والحالية. كل وردية تظهر بتاريخ بدايتها ونهايتها ومدتها واسم الموظف المسؤول وإجمالي المبيعات وعدد الفواتير. الوردية المفتوحة حالياً تظهر بشكل مميز مع مؤشر "نشطة". يمكن الضغط على أي وردية لعرض ملخصها التفصيلي، وتوجد أزرار لفتح وردية جديدة أو إغلاق الحالية.',
      features: ['سجل الورديات', 'مؤشر الوردية النشطة', 'عرض المدة', 'إجمالي المبيعات لكل وردية', 'تصفية بالتاريخ', 'أزرار فتح/إغلاق وردية'],
      expectedBehaviors: ['عرض قائمة الورديات أو حالة فارغة', 'الوردية النشطة مميزة', 'زر فتح وردية ظاهر إن لم تكن هناك وردية مفتوحة'],
      scenarios: [{ scenarioName: 'عرض سجل الورديات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للورديات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="shift" i]', text: 'text=/shifts|الورديات/i', css: '.shifts-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من عنوان الصفحة', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/shifts|الورديات/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من قائمة الورديات أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*shift|لا توجد/i', css: '.empty-state, table, .shift-card' }, expect: 'content-or-empty', onFailScreenshot: true },
        { stepName: 'التحقق من أزرار الإجراءات', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/open.*shift|بدء.*وردية|close|إغلاق/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 2. فتح وردية ──
    {
      name: 'Open Shift',
      nameAr: 'فتح وردية',
      path: '/shifts/open',
      screenSlug: 'shift-open',
      descriptionAr: 'شاشة فتح وردية جديدة تتيح بدء يوم عمل جديد. يقوم الموظف بإدخال الرصيد الافتتاحي (المبلغ النقدي الموجود في الصندوق عند البداية) مع إمكانية إضافة ملاحظات. بعد التأكيد يتم فتح الوردية وتبدأ عمليات البيع. لا يمكن فتح وردية جديدة إذا كانت هناك وردية مفتوحة بالفعل.',
      features: ['إدخال الرصيد الافتتاحي', 'حقل الملاحظات', 'تأكيد بدء الوردية', 'تعيين الموظف'],
      expectedBehaviors: ['حقل إدخال المبلغ النقدي موجود', 'زر البدء/الفتح ظاهر', 'التحقق من صحة النموذج يعمل'],
      scenarios: [{ scenarioName: 'نموذج فتح وردية', dataState: 'no-active-shift', setup: [], tests: [
        { stepName: 'الانتقال لفتح وردية', action: 'navigate', selectorStrategy: { aria: '[aria-label*="open" i]', text: 'text=/open.*shift|بدء.*وردية/i', css: '.shift-open-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من حقل الرصيد الافتتاحي', action: 'exists', selectorStrategy: { aria: 'input[type="number"]', text: 'text=/opening.*cash|رصيد.*افتتاحي/i', css: 'input' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر البدء', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/start|open|بدء|فتح/i', css: 'button[type="submit"]' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: ['قد يُعاد التوجيه إذا كانت هناك وردية مفتوحة بالفعل'],
    },

    // ── 3. إغلاق وردية ──
    {
      name: 'Close Shift',
      nameAr: 'إغلاق وردية',
      path: '/shifts/close',
      screenSlug: 'shift-close',
      descriptionAr: 'شاشة إغلاق الوردية الحالية تتطلب من الموظف إدخال المبلغ النقدي الفعلي في الصندوق. يقارن النظام تلقائياً بين المبلغ المتوقع (بناءً على المبيعات والإيداعات والسحوبات) والمبلغ الفعلي، ويحسب الفرق. يظهر ملخص سريع للوردية قبل التأكيد النهائي للإغلاق.',
      features: ['جرد النقد عند الإغلاق', 'معاينة ملخص الوردية', 'حساب الفرق', 'تأكيد الإغلاق'],
      expectedBehaviors: ['عرض ملخص الوردية إذا كانت هناك وردية نشطة', 'حقل إدخال النقد موجود', 'زر الإغلاق يعمل'],
      scenarios: [{ scenarioName: 'نموذج إغلاق وردية', dataState: 'active-shift-required', setup: [], tests: [
        { stepName: 'الانتقال لإغلاق وردية', action: 'navigate', selectorStrategy: { aria: '[aria-label*="close" i]', text: 'text=/close.*shift|إغلاق.*وردية/i', css: '.shift-close-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من الملخص أو إعادة التوجيه', action: 'check-content', selectorStrategy: { aria: '[role="form"], [role="alert"]', text: 'text=/summary|ملخص|no.*active|لا.*وردية/i', css: '.shift-summary, .no-shift, form' }, expect: 'content-or-empty', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإغلاق', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/close|confirm|إغلاق|تأكيد/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج وردية مفتوحة؛ قد يظهر خطأ/إعادة توجيه إذا لم توجد'],
    },

    // ── 4. ملخص الوردية ──
    {
      name: 'Shift Summary',
      nameAr: 'ملخص الوردية',
      path: '/shifts/summary',
      screenSlug: 'shift-summary',
      descriptionAr: 'شاشة ملخص الوردية تعرض تقريراً تفصيلياً شاملاً بعد إغلاق الوردية. تتضمن: بانر نجاح الإغلاق مع التاريخ والوقت، حالة الصندوق (المتوقع والفعلي والفرق)، إحصائيات الوردية (المدة، عدد الفواتير، إجمالي المبيعات، مبيعات البطاقة والنقد، المرتجعات). توفر أزرار مشاركة التقرير وطباعته وفتح وردية جديدة.',
      features: ['إجمالي المبيعات', 'عدد المعاملات', 'تفصيل طرق الدفع', 'تقسيم نقد/بطاقة', 'تقرير الفروقات', 'طباعة الملخص'],
      expectedBehaviors: ['عرض بيانات الملخص أو حالة فارغة', 'الإجماليات ظاهرة', 'تفصيل طرق الدفع ظاهر'],
      scenarios: [{ scenarioName: 'عرض ملخص الوردية', dataState: 'completed-shift-required', setup: [], tests: [
        { stepName: 'الانتقال لملخص الوردية', action: 'navigate', selectorStrategy: { aria: '[aria-label*="summary" i]', text: 'text=/summary|ملخص/i', css: '.shift-summary-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من محتوى الملخص', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/total|إجمالي|sales|مبيعات/i', css: '.summary-card, .total-display' }, expect: 'content-or-empty', onFailScreenshot: true },
        { stepName: 'التحقق من زر الطباعة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/print|طباعة/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج بيانات وردية مكتملة؛ قد يظهر فارغاً بدون ورديات سابقة'],
    },
  ],
};
