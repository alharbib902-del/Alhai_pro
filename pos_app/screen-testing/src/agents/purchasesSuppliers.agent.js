/**
 * Agent C: Purchases & Suppliers (المشتريات والموردون)
 * الوكيل المسؤول عن شاشات المشتريات والموردين واستيراد الفواتير بالذكاء الاصطناعي
 */

module.exports = {
  categorySlug: 'purchases-suppliers',
  categoryName: 'Purchases & Suppliers',
  categoryNameAr: 'المشتريات والموردون',
  categoryDescriptionAr: 'يشمل هذا القسم إدارة عمليات الشراء من الموردين: إنشاء فواتير شراء جديدة، نظام الطلب الذكي بالذكاء الاصطناعي، استيراد فواتير الموردين عبر التصوير (OCR)، مراجعة الفاتورة المستوردة، وإدارة بيانات الموردين.',
  screens: [
    // ── 1. فاتورة شراء جديدة ──
    {
      name: 'New Purchase',
      nameAr: 'فاتورة شراء جديدة',
      path: '/purchases/new',
      screenSlug: 'purchase-new',
      descriptionAr: 'شاشة إنشاء فاتورة شراء جديدة من المورد. تتضمن: اختيار المورد من القائمة المنسدلة، إدخال رقم فاتورة المورد، تحديد حالة الدفع (مدفوعة/آجل)، ثم إضافة المنتجات المُشتراة مع الكمية والسعر لكل منتج. يُحسَب الإجمالي تلقائياً ويمكن حفظ الفاتورة لتحديث المخزون.',
      features: ['اختيار المورد', 'بنود المنتجات', 'إدخال الكمية والسعر', 'حساب الإجمالي تلقائياً', 'حفظ/إرسال فاتورة الشراء'],
      expectedBehaviors: ['النموذج يُحمَّل مع قائمة الموردين', 'يمكن إضافة بنود المنتجات', 'الإجماليات تتحدث تلقائياً'],
      scenarios: [{ scenarioName: 'نموذج فاتورة الشراء', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لفاتورة شراء جديدة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="purchase" i]', text: 'text=/purchase|شراء/i', css: '.purchase-form-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من اختيار المورد', action: 'exists', selectorStrategy: { aria: 'select, [role="combobox"]', text: 'text=/supplier|مورد/i', css: 'select, .dropdown' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من حقول النموذج', action: 'exists', selectorStrategy: { aria: 'input, textarea', text: 'text=/product|منتج/i', css: 'input, .form-field' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button[type="submit"]', text: 'text=/save|حفظ/i', css: 'button[type="submit"]' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج موردين في قاعدة البيانات للقائمة المنسدلة'],
    },

    // ── 2. الطلب الذكي ──
    {
      name: 'Smart Reorder',
      nameAr: 'الطلب الذكي',
      path: '/purchases/smart-reorder',
      screenSlug: 'smart-reorder',
      descriptionAr: 'شاشة الطلب الذكي بالذكاء الاصطناعي تُحلّل حركة المخزون وتقترح كميات الشراء المثلى. يحدد المستخدم الميزانية المتاحة والمورد، ثم يضغط "حساب التوزيع الذكي" ليقوم النظام بتوزيع الميزانية على المنتجات حسب معدل الدوران والمخزون الحالي والحد الأدنى. يعرض قائمة بالمنتجات المقترحة مع الكميات والتكلفة.',
      features: ['اقتراحات إعادة الطلب بالـ AI', 'قائمة المنتجات ذات المخزون المنخفض', 'الكميات المقترحة', 'طلب بنقرة واحدة'],
      expectedBehaviors: ['عرض الاقتراحات أو حالة فارغة', 'قائمة المنتجات مع الكميات'],
      scenarios: [{ scenarioName: 'عرض الطلب الذكي', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للطلب الذكي', action: 'navigate', selectorStrategy: { aria: '[aria-label*="reorder" i]', text: 'text=/reorder|طلب.*ذكي/i', css: '.smart-reorder-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/smart.*reorder|الطلب.*الذكي/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من الاقتراحات أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*suggestion|لا توجد|حدد.*الميزانية/i', css: '.suggestion-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['يحتاج بيانات مخزون لاقتراحات ذات معنى'],
    },

    // ── 3. استيراد فاتورة AI ──
    {
      name: 'AI Invoice Import',
      nameAr: 'استيراد فاتورة AI',
      path: '/purchases/ai-import',
      screenSlug: 'ai-import',
      descriptionAr: 'شاشة استيراد فاتورة المورد بالذكاء الاصطناعي تتيح التقاط صورة لفاتورة الشراء الورقية أو اختيارها من المعرض. يقوم النظام بتقنية OCR لاستخراج البيانات تلقائياً (اسم المورد، المنتجات، الكميات، الأسعار) ثم يحوّلها إلى فاتورة شراء رقمية. يدعم صيغ الصور (JPG/PNG) و PDF.',
      features: ['رفع صورة/ملف PDF', 'معالجة OCR بالذكاء الاصطناعي', 'استخراج بيانات الفاتورة', 'مؤشر تقدم المعالجة'],
      expectedBehaviors: ['منطقة الرفع ظاهرة', 'معلومات الصيغ المدعومة معروضة', 'مؤشر المعالجة يظهر عند الرفع'],
      scenarios: [{ scenarioName: 'عرض استيراد الفاتورة', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لاستيراد الفاتورة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="import" i]', text: 'text=/import|استيراد/i', css: '.ai-import-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من منطقة الرفع', action: 'exists', selectorStrategy: { aria: 'input[type="file"]', text: 'text=/upload|رفع|التقط|المعرض/i', css: 'input[type="file"], .upload-area' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من معلومات الصيغ المدعومة', action: 'check-content', selectorStrategy: { aria: '[role="note"]', text: 'text=/pdf|image|صورة/i', css: '.format-info, .help-text' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['لا يمكن اختبار OCR بالكامل بدون صورة فاتورة فعلية'],
    },

    // ── 4. مراجعة فاتورة AI ──
    {
      name: 'AI Invoice Review',
      nameAr: 'مراجعة فاتورة AI',
      path: '/purchases/ai-review',
      screenSlug: 'ai-review',
      descriptionAr: 'شاشة مراجعة الفاتورة المستوردة بالذكاء الاصطناعي تعرض البيانات المستخرجة من الصورة/الملف للمراجعة والتعديل قبل الحفظ النهائي. يمكن تصحيح أي حقل (اسم المنتج، الكمية، السعر)، ومطابقة المنتجات مع قاعدة بيانات المخزون، والموافقة على كل بند أو رفضه. بعد المراجعة يتم إنشاء فاتورة الشراء الرسمية.',
      features: ['مراجعة البيانات المستخرجة', 'تصحيح الحقول', 'مطابقة المنتجات', 'موافقة/رفض البنود', 'إرسال الفاتورة المُراجَعة'],
      expectedBehaviors: ['عرض البيانات المستخرجة أو إعادة التوجيه للاستيراد', 'حقول قابلة للتعديل', 'إجراءات الموافقة موجودة'],
      scenarios: [{ scenarioName: 'عرض مراجعة الفاتورة (عبر التنقل المباشر)', dataState: 'requires-import-flow', setup: [
        { note: 'تحذير: هذه الشاشة تحتاج عادة المرور بتدفق استيراد AI أولاً. التنقل المباشر قد يُظهر حالة خطأ.' },
      ], tests: [
        { stepName: 'الانتقال لمراجعة الفاتورة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="review" i]', text: 'text=/review|مراجعة/i', css: '.ai-review-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من محتوى المراجعة أو إعادة التوجيه', action: 'check-content', selectorStrategy: { aria: '[role="form"], [role="alert"]', text: 'text=/review|مراجعة|no.*data|لا.*بيانات/i', css: '.review-form, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        { stepName: 'توثيق حالة الصفحة', action: 'check-content', selectorStrategy: { aria: 'body', text: 'text=/.*/i', css: 'body' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: [
        'هام: مراجعة الفاتورة تحتاج بيانات مُستوردة من تدفق استيراد AI',
        'التنقل المباشر سيظهر شاشة خطأ حمراء (Null is not a subtype of AiInvoiceResult)',
        'الاختبار الكامل يتطلب: 1) الذهاب لاستيراد AI → 2) رفع فاتورة → 3) انتظار OCR → 4) الانتقال تلقائياً هنا',
      ],
    },

    // ── 5. الموردون ──
    {
      name: 'Suppliers',
      nameAr: 'الموردون',
      path: '/suppliers',
      screenSlug: 'suppliers-list',
      descriptionAr: 'شاشة إدارة الموردين تعرض قائمة بجميع الموردين المسجلين مع بطاقات إحصائية في الأعلى (إجمالي الموردين، إجمالي المشتريات، المستحقات). كل مورد يظهر باسمه ورقم هاتفه ورصيد مستحقاته. يمكن البحث عن مورد بالاسم وإضافة مورد جديد والنقر على أي مورد لعرض تفاصيله وسجل تعاملاته.',
      features: ['قائمة الموردين', 'البحث عن مورد', 'زر إضافة مورد', 'معاينة تفاصيل المورد', 'عرض معلومات التواصل'],
      expectedBehaviors: ['عرض قائمة الموردين أو حالة فارغة', 'حقل البحث يعمل', 'زر الإضافة موجود'],
      scenarios: [{ scenarioName: 'عرض قائمة الموردين', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للموردين', action: 'navigate', selectorStrategy: { aria: '[aria-label*="supplier" i]', text: 'text=/suppliers|الموردون/i', css: '.suppliers-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/supplier|مورد/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإضافة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|مورد.*جديد|\\+/i', css: '.fab, button' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من القائمة أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="table"], [role="list"]', text: 'text=/no.*supplier|لا.*مورد/i', css: '.list-view, .empty-state, table' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 6. إضافة مورد جديد ──
    {
      name: 'New Supplier',
      nameAr: 'إضافة مورد جديد',
      path: '/suppliers/new',
      screenSlug: 'supplier-new',
      descriptionAr: 'شاشة إضافة مورد جديد تحتوي على نموذج متكامل بعدة أقسام: المعلومات الأساسية (اسم المورد/جهة الاتصال، اسم الشركة، التصنيف)، المعلومات المالية (شروط الدفع، اسم البنك، رقم IBAN)، معلومات التواصل (الهاتف الأساسي والثانوي، البريد الإلكتروني، العنوان)، المعلومات التجارية (الرقم الضريبي VAT، رقم السجل التجاري CR)، وإعدادات إضافية (تفعيل المورد، ملاحظات).',
      features: ['إدخال اسم المورد', 'حقول معلومات التواصل', 'حقول العنوان', 'شروط الدفع', 'زر الحفظ'],
      expectedBehaviors: ['النموذج يُحمَّل بحقول فارغة', 'التحقق من الحقول المطلوبة يعمل', 'زر الحفظ موجود'],
      scenarios: [{ scenarioName: 'نموذج مورد جديد', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لإضافة مورد', action: 'navigate', selectorStrategy: { aria: '[aria-label*="supplier" i]', text: 'text=/new.*supplier|مورد.*جديد/i', css: '.supplier-form-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من حقل الاسم', action: 'exists', selectorStrategy: { aria: 'input', text: 'text=/name|الاسم/i', css: 'input[type="text"]' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button[type="submit"]', text: 'text=/save|حفظ|إضافة.*المورد/i', css: 'button[type="submit"]' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: [],
    },
  ],
};
