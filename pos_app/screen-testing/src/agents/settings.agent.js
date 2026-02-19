/**
 * Agent F: Settings (الإعدادات)
 * الوكيل المسؤول عن جميع شاشات الإعدادات والتهيئة
 */

const SECURITY_TIMEOUT_MS = 10000;

module.exports = {
  categorySlug: 'settings',
  categoryName: 'Settings',
  categoryNameAr: 'الإعدادات',
  categoryDescriptionAr: 'يشمل هذا القسم جميع إعدادات النظام وتهيئته: إعدادات المتجر، نقطة البيع، الطابعة، أجهزة الدفع، الباركود، قالب الإيصال، الضريبة، الخصم، الفوائد، المظهر، اللغة، الأمان، المستخدمين، الأدوار والصلاحيات، سجل النشاط، النسخ الاحتياطي، إعدادات الإشعارات، هيئة الزكاة والضريبة (ZATCA)، والمساعدة والدعم.',
  securityTimeout: SECURITY_TIMEOUT_MS,
  screens: [
    // ── 1. الإعدادات الرئيسية ──
    {
      name: 'Settings',
      nameAr: 'الإعدادات الرئيسية',
      path: '/settings',
      screenSlug: 'settings-main',
      descriptionAr: 'شاشة الإعدادات الرئيسية تعرض شبكة من بطاقات فئات الإعدادات المتاحة. تتضمن البطاقات: المتجر (معلومات المنشأة)، نقطة البيع (إعدادات الكاشير)، الطابعة (إعداد طابعة الإيصالات)، أجهزة الدفع (ربط أجهزة الدفع الإلكتروني)، الباركود (إعدادات قارئ الباركود)، الإيصال (تخصيص قالب الإيصال)، الضريبة (إعدادات ضريبة القيمة المضافة)، الخصم (قواعد الخصم الافتراضية)، الفوائد (إعدادات الفائدة على الآجل)، المظهر (الوضع الفاتح/الداكن)، اللغة (اختيار لغة الواجهة)، الأمان (PIN وحماية الحساب). كل بطاقة تظهر بأيقونة ووصف مختصر.',
      features: ['شبكة فئات الإعدادات', 'التنقل للإعدادات الفرعية', 'نظرة عامة على التفضيلات'],
      expectedBehaviors: ['شبكة/قائمة الإعدادات تُحمَّل', 'روابط الفئات تعمل'],
      scenarios: [{
        scenarioName: 'عرض الإعدادات الرئيسية',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للإعدادات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="setting" i]', text: 'text=/settings|الإعدادات/i', css: '.settings-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/settings|إعدادات/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من فئات الإعدادات', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="navigation"]', text: 'text=/store|متجر|general|عام/i', css: '.settings-grid, .settings-list, .category-card' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 2. إعدادات المتجر ──
    {
      name: 'Store Settings',
      nameAr: 'إعدادات المتجر',
      path: '/settings/store',
      screenSlug: 'store-settings',
      descriptionAr: 'شاشة إعدادات المتجر تتيح تعديل المعلومات الأساسية للمنشأة. تتضمن: اسم المتجر، العنوان، المدينة، الرمز البريدي، رقم الهاتف، البريد الإلكتروني، الرقم الضريبي، رقم السجل التجاري، ورفع شعار المتجر. جميع الحقول قابلة للتعديل مع زر حفظ في الأسفل. هذه المعلومات تظهر في رأس الإيصالات والفواتير.',
      features: ['اسم المتجر', 'العنوان', 'معلومات الاتصال', 'رفع الشعار', 'معلومات تجارية'],
      expectedBehaviors: ['النموذج يُحمَّل بالقيم الحالية', 'الحقول قابلة للتعديل', 'زر الحفظ موجود'],
      scenarios: [{
        scenarioName: 'عرض إعدادات المتجر',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات المتجر', action: 'navigate', selectorStrategy: { aria: '[aria-label*="store" i]', text: 'text=/store.*setting|إعدادات.*المتجر/i', css: '.store-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من حقول النموذج', action: 'exists', selectorStrategy: { aria: 'input, textarea', text: 'text=/name|store|اسم|متجر/i', css: 'input, textarea, .form-field' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button[type="submit"], .save-button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 3. إعدادات نقطة البيع ──
    {
      name: 'POS Settings',
      nameAr: 'إعدادات نقطة البيع',
      path: '/settings/pos',
      screenSlug: 'pos-settings',
      descriptionAr: 'شاشة إعدادات نقطة البيع تتيح تهيئة سلوك شاشة الكاشير. تتضمن: تخطيط شاشة البيع، الأزرار السريعة، طريقة الدفع الافتراضية، الطباعة التلقائية بعد البيع، تفعيل/تعطيل الخصم اليدوي، إظهار صور المنتجات، عدد الأعمدة في شبكة المنتجات، وإعدادات الضريبة الشاملة. كل إعداد يظهر بمفتاح تفعيل (toggle) أو قائمة اختيار.',
      features: ['تخطيط شاشة البيع', 'الأزرار السريعة', 'طريقة الدفع الافتراضية', 'الطباعة التلقائية'],
      expectedBehaviors: ['نموذج التهيئة يُحمَّل', 'مفاتيح التفعيل تعمل'],
      scenarios: [{
        scenarioName: 'عرض إعدادات نقطة البيع',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات نقطة البيع', action: 'navigate', selectorStrategy: { aria: '[aria-label*="pos" i]', text: 'text=/pos.*setting|إعدادات.*نقطة/i', css: '.pos-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من عناصر التحكم', action: 'exists', selectorStrategy: { aria: 'input, [role="switch"], [role="checkbox"]', text: 'text=/layout|تخطيط|receipt|إيصال/i', css: 'input, .toggle, .switch' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 4. إعدادات الطابعة ──
    {
      name: 'Printer Settings',
      nameAr: 'إعدادات الطابعة',
      path: '/settings/printer',
      screenSlug: 'printer-settings',
      descriptionAr: 'شاشة إعدادات الطابعة تتيح تهيئة طابعة الإيصالات. تتضمن: اختيار الطابعة من القائمة المتاحة، تحديد حجم الورق (58mm/80mm)، تعيين الطابعة الافتراضية، اختبار الطباعة، وإعدادات الاتصال (USB/Bluetooth/Network). تعرض حالة الطابعة المتصلة حالياً مع إمكانية إضافة طابعات جديدة.',
      features: ['قائمة الطابعات', 'إضافة طابعة', 'اختبار الطباعة', 'حجم الورق', 'الطابعة الافتراضية'],
      expectedBehaviors: ['نموذج إعداد الطابعة يُحمَّل', 'زر اختبار الطباعة موجود'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الطابعة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الطابعة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="printer" i]', text: 'text=/printer|الطابعة/i', css: '.printer-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من إعدادات الطابعة', action: 'exists', selectorStrategy: { aria: 'select, input, [role="combobox"]', text: 'text=/printer|طابعة|paper|ورق/i', css: 'select, input, .printer-config' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الاختبار', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/test|print|اختبار|طباعة/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['اختبار الطباعة يحتاج طابعة متصلة'],
    },

    // ── 5. إعدادات اللغة ──
    {
      name: 'Language Settings',
      nameAr: 'إعدادات اللغة',
      path: '/settings/language',
      screenSlug: 'language-settings',
      descriptionAr: 'شاشة إعدادات اللغة تتيح اختيار لغة واجهة التطبيق. تعرض قائمة بـ 7 لغات مدعومة: العربية، الإنجليزية، الهندية، الأوردو، الفلبينية، البنغالية، والنيبالية. اللغة الحالية المفعّلة تظهر بعلامة اختيار أو تمييز لوني. عند تغيير اللغة يتم تحديث جميع نصوص الواجهة فوراً بما في ذلك اتجاه النص (RTL/LTR).',
      features: ['قائمة اللغات (7 لغات)', 'مؤشر اللغة الحالية', 'تبديل اللغة'],
      expectedBehaviors: ['خيارات اللغة معروضة', 'الاختيار الحالي مميز'],
      scenarios: [{
        scenarioName: 'عرض إعدادات اللغة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات اللغة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="language" i]', text: 'text=/language|اللغة/i', css: '.language-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من خيارات اللغة', action: 'exists', selectorStrategy: { aria: '[role="radio"], [role="option"], [role="listbox"]', text: 'text=/english|العربية|عربي|hindi|urdu/i', css: '.language-option, .language-card, [class*="language"]' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من تعدد اللغات', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/english|العربية|हिन्दी|اردو/i', css: '.language-list' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 6. إعدادات المظهر ──
    {
      name: 'Theme Settings',
      nameAr: 'إعدادات المظهر',
      path: '/settings/theme',
      screenSlug: 'theme-settings',
      descriptionAr: 'شاشة إعدادات المظهر تتيح التبديل بين الوضع الفاتح والداكن للتطبيق. تعرض خيارات المظهر: فاتح (خلفية بيضاء)، داكن (خلفية داكنة)، ونظام (يتبع إعداد الجهاز تلقائياً). كل خيار يظهر بمعاينة مصغرة للمظهر. التغيير يُطبَّق فوراً على جميع شاشات التطبيق.',
      features: ['تبديل فاتح/داكن', 'معاينة المظهر', 'خيارات الألوان', 'خيار النظام'],
      expectedBehaviors: ['خيارات المظهر ظاهرة', 'مفاتيح التبديل تعمل', 'المعاينة تتحدث مباشرة'],
      scenarios: [{
        scenarioName: 'عرض إعدادات المظهر',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات المظهر', action: 'navigate', selectorStrategy: { aria: '[aria-label*="theme" i]', text: 'text=/theme|المظهر/i', css: '.theme-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من تبديل المظهر', action: 'exists', selectorStrategy: { aria: '[role="switch"], [role="radio"], input[type="checkbox"]', text: 'text=/dark|light|داكن|فاتح/i', css: '.theme-toggle, .switch, input[type="checkbox"]' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من خيارات المظهر', action: 'check-content', selectorStrategy: { aria: '[role="radiogroup"], [role="list"]', text: 'text=/dark|light|system|داكن|فاتح|نظام/i', css: '.theme-options, .theme-cards' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 7. أجهزة الدفع ──
    {
      name: 'Payment Devices',
      nameAr: 'أجهزة الدفع',
      path: '/settings/payment-devices',
      screenSlug: 'payment-devices',
      descriptionAr: 'شاشة أجهزة الدفع تتيح إدارة وربط أجهزة الدفع الإلكتروني (مدى، فيزا، ماستركارد). تعرض قائمة الأجهزة المربوطة مع حالة الاتصال لكل جهاز (متصل/غير متصل). يمكن إضافة جهاز جديد واختبار الاتصال. في حالة عدم وجود أجهزة تظهر رسالة إرشادية لإعداد أول جهاز.',
      features: ['قائمة الأجهزة', 'إضافة جهاز', 'حالة الاتصال', 'اختبار الاتصال'],
      expectedBehaviors: ['قائمة الأجهزة أو رسالة إعداد', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض أجهزة الدفع',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لأجهزة الدفع', action: 'navigate', selectorStrategy: { aria: '[aria-label*="payment" i]', text: 'text=/payment.*device|أجهزة.*دفع/i', css: '.payment-devices' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/payment|دفع|device|جهاز/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*device|لا.*جهاز/i', css: '.device-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['اختبار الاتصال يحتاج أجهزة دفع فعلية'],
    },

    // ── 8. إعدادات الباركود ──
    {
      name: 'Barcode Settings',
      nameAr: 'إعدادات الباركود',
      path: '/settings/barcode',
      screenSlug: 'barcode-settings',
      descriptionAr: 'شاشة إعدادات الباركود تتيح تهيئة قارئ الباركود وتنسيق الأكواد. تتضمن: اختيار نوع الماسح (USB/Bluetooth/Camera)، تنسيق الباركود (EAN-13, Code128, QR)، إعداد البادئة واللاحقة، سرعة المسح، وصوت التأكيد. يمكن اختبار القراءة مباشرة من الشاشة.',
      features: ['تنسيق الباركود', 'اختيار نوع الماسح', 'اختبار الباركود', 'إعدادات البادئة'],
      expectedBehaviors: ['نموذج التهيئة يُحمَّل', 'إعدادات الماسح موجودة'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الباركود',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الباركود', action: 'navigate', selectorStrategy: { aria: '[aria-label*="barcode" i]', text: 'text=/barcode|باركود/i', css: '.barcode-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من الإعدادات', action: 'exists', selectorStrategy: { aria: 'input, select', text: 'text=/barcode|باركود|format|تنسيق/i', css: 'input, select, .form-field' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 9. قالب الإيصال ──
    {
      name: 'Receipt Template',
      nameAr: 'قالب الإيصال',
      path: '/settings/receipt',
      screenSlug: 'receipt-template',
      descriptionAr: 'شاشة قالب الإيصال تتيح تخصيص شكل ومحتوى إيصال البيع المطبوع. تتضمن: تعديل الترويسة (اسم المتجر، العنوان، الهاتف)، التذييل (رسالة شكر، شروط الإرجاع)، اختيار مكان الشعار، إظهار/إخفاء حقول (الرقم الضريبي، QR Code، معلومات الفرع)، وحجم الخط. تتوفر معاينة حية للإيصال أثناء التعديل.',
      features: ['محرر القالب', 'معاينة حية', 'مكان الشعار', 'نص التذييل', 'مفاتيح إظهار/إخفاء الحقول'],
      expectedBehaviors: ['محرر القالب يُحمَّل', 'المعاينة ظاهرة', 'زر الحفظ يعمل'],
      scenarios: [{
        scenarioName: 'عرض قالب الإيصال',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لقالب الإيصال', action: 'navigate', selectorStrategy: { aria: '[aria-label*="receipt" i]', text: 'text=/receipt|إيصال/i', css: '.receipt-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من محتوى القالب', action: 'exists', selectorStrategy: { aria: '[role="form"], textarea, input', text: 'text=/template|قالب|header|footer|ترويسة/i', css: '.template-editor, form, textarea' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من المعاينة أو الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/preview|save|معاينة|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 10. إعدادات الضريبة ──
    {
      name: 'Tax Settings',
      nameAr: 'إعدادات الضريبة',
      path: '/settings/tax',
      screenSlug: 'tax-settings',
      descriptionAr: 'شاشة إعدادات الضريبة تتيح تهيئة ضريبة القيمة المضافة (VAT). تتضمن: تحديد نسبة الضريبة (مثل 15%)، اختيار طريقة احتساب الضريبة (شاملة السعر أو مضافة على السعر)، تحديد فئات الضريبة (معفاة، صفرية، قياسية)، والرقم الضريبي للمنشأة. التغييرات تؤثر على جميع الفواتير الجديدة.',
      features: ['نسبة الضريبة', 'إعدادات VAT', 'فئات الضريبة', 'ضريبة شاملة/مضافة'],
      expectedBehaviors: ['نموذج إعداد الضريبة يُحمَّل', 'حقول النسبة موجودة', 'زر الحفظ يعمل'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الضريبة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الضريبة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="tax" i]', text: 'text=/tax|الضريبة/i', css: '.tax-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من حقول الضريبة', action: 'exists', selectorStrategy: { aria: 'input[type="number"], input', text: 'text=/rate|vat|نسبة|ضريبة|15%/i', css: 'input, .tax-rate, .form-field' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 11. إعدادات الخصم ──
    {
      name: 'Discounts Settings',
      nameAr: 'إعدادات الخصم',
      path: '/settings/discounts',
      screenSlug: 'discounts-settings',
      descriptionAr: 'شاشة إعدادات الخصم تتيح تحديد قواعد الخصم الافتراضية للنظام. تتضمن: الحد الأقصى للخصم المسموح (مثل 50%)، السماح بالخصم اليدوي من الكاشير، تحديد صلاحيات الخصم لكل دور (كاشير/مدير)، وقواعد الخصم التلقائي. يمكن تفعيل أو تعطيل كل قاعدة بشكل مستقل.',
      features: ['قواعد الخصم الافتراضية', 'الحد الأقصى للخصم', 'صلاحيات خصم الموظفين'],
      expectedBehaviors: ['نموذج التهيئة يُحمَّل', 'قواعد الخصم ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الخصم',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الخصم', action: 'navigate', selectorStrategy: { aria: '[aria-label*="discount" i]', text: 'text=/discount.*setting|إعدادات.*خصم/i', css: '.discounts-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من الحقول', action: 'exists', selectorStrategy: { aria: 'input, [role="switch"]', text: 'text=/discount|max|خصم|حد/i', css: 'input, .form-field, .switch' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 12. إعدادات الفوائد ──
    {
      name: 'Interest Settings',
      nameAr: 'إعدادات الفوائد',
      path: '/settings/interest',
      screenSlug: 'interest-settings',
      descriptionAr: 'شاشة إعدادات الفوائد تتيح تهيئة نظام الفائدة على المبيعات الآجلة (الدين). تتضمن: تحديد نسبة الفائدة الشهرية/السنوية، فترة السماح قبل احتساب الفائدة، غرامات التأخير، وطريقة الحساب (بسيطة/مركبة). هذه الإعدادات تُطبَّق تلقائياً على فواتير البيع الآجل.',
      features: ['نسبة الفائدة', 'غرامات التأخير', 'فترة السماح'],
      expectedBehaviors: ['نموذج التهيئة يُحمَّل', 'حقول النسبة موجودة'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الفوائد',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الفوائد', action: 'navigate', selectorStrategy: { aria: '[aria-label*="interest" i]', text: 'text=/interest|الفائدة/i', css: '.interest-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من الحقول', action: 'exists', selectorStrategy: { aria: 'input', text: 'text=/rate|interest|نسبة|فائدة/i', css: 'input, .form-field' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 13. إعدادات الأمان (مع حارس المهلة) ──
    {
      name: 'Security Settings',
      nameAr: 'إعدادات الأمان',
      path: '/settings/security',
      screenSlug: 'security-settings',
      descriptionAr: 'شاشة إعدادات الأمان تتيح تهيئة حماية الحساب والنظام. تتضمن: تفعيل رمز PIN لتسجيل الدخول، مهلة الجلسة (قفل تلقائي بعد فترة خمول)، المصادقة الثنائية، الحد الأقصى لمحاولات تسجيل الدخول الخاطئة، وسياسة كلمة المرور. ملاحظة: هذه الشاشة قد تعاني من بطء في التحميل (ظهور مؤشر تحميل دوّار) لذلك يتم اختبارها بمهلة زمنية محددة (10 ثوانٍ).',
      features: ['حماية PIN', 'مهلة الجلسة', 'المصادقة الثنائية', 'حد محاولات الدخول', 'سياسة كلمة المرور'],
      expectedBehaviors: ['نموذج إعداد الأمان يُحمَّل', 'مفاتيح التفعيل موجودة', 'يعرض ضمن حد المهلة الزمنية'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الأمان (مع حارس المهلة)',
        dataState: 'any',
        setup: [{ note: 'أمان: تطبيق حارس مهلة 10 ثوانٍ لهذه الشاشة' }],
        tests: [
          { stepName: 'الانتقال مع حارس المهلة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="security" i]', text: 'text=/security|الأمان/i', css: '.security-settings' }, expect: 'page-visible', onFailScreenshot: true, timeout: SECURITY_TIMEOUT_MS },
          { stepName: 'التحقق من عناصر الأمان', action: 'exists', selectorStrategy: { aria: '[role="switch"], input, [role="checkbox"]', text: 'text=/pin|password|timeout|أمان|كلمة.*مرور/i', css: 'input, .switch, .toggle, .security-control' }, expect: 'element-exists', onFailScreenshot: true, timeout: SECURITY_TIMEOUT_MS },
          { stepName: 'التحقق من عدم التحميل اللانهائي', action: 'check-content', selectorStrategy: { aria: '[role="progressbar"], [aria-busy="true"]', text: 'text=/loading|جاري/i', css: '.loading, .spinner, .progress' }, expect: 'element-not-exists', onFailScreenshot: true, timeout: SECURITY_TIMEOUT_MS },
        ],
      }],
      limitations: ['إذا استغرقت الصفحة أكثر من 10 ثوانٍ للتحميل، تُسجَّل كفشل مع ملاحظة المهلة'],
    },

    // ── 14. إدارة المستخدمين ──
    {
      name: 'Users Management',
      nameAr: 'إدارة المستخدمين',
      path: '/settings/users',
      screenSlug: 'users-management',
      descriptionAr: 'شاشة إدارة المستخدمين تعرض قائمة بجميع مستخدمي النظام (الموظفين). كل مستخدم يظهر باسمه ودوره (مدير/كاشير/محاسب) وحالته (نشط/غير نشط) وآخر تسجيل دخول. يمكن إضافة مستخدم جديد وتعديل بياناته وصلاحياته أو تعطيل حسابه. يدعم تعيين الأدوار والصلاحيات لكل مستخدم.',
      features: ['قائمة المستخدمين', 'إضافة مستخدم', 'تعديل الأدوار', 'تعطيل المستخدم'],
      expectedBehaviors: ['قائمة المستخدمين أو حالة فارغة', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض إدارة المستخدمين',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإدارة المستخدمين', action: 'navigate', selectorStrategy: { aria: '[aria-label*="user" i]', text: 'text=/users|المستخدمين/i', css: '.users-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/user|مستخدم/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الإضافة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|إضافة|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 15. الأدوار والصلاحيات ──
    {
      name: 'Roles & Permissions',
      nameAr: 'الأدوار والصلاحيات',
      path: '/settings/roles',
      screenSlug: 'roles-permissions',
      descriptionAr: 'شاشة الأدوار والصلاحيات تتيح إدارة أدوار المستخدمين وتحديد صلاحيات كل دور. تعرض قائمة الأدوار المتاحة (مثل مدير، كاشير، محاسب، مشرف) مع مصفوفة الصلاحيات لكل دور. يمكن إنشاء دور جديد وتعيين صلاحيات محددة (عرض، إنشاء، تعديل، حذف) لكل قسم من أقسام النظام.',
      features: ['قائمة الأدوار', 'مصفوفة الصلاحيات', 'إنشاء دور', 'تعيين الصلاحيات'],
      expectedBehaviors: ['قائمة الأدوار تُحمَّل', 'مفاتيح الصلاحيات ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض الأدوار والصلاحيات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للأدوار', action: 'navigate', selectorStrategy: { aria: '[aria-label*="role" i]', text: 'text=/roles|الصلاحيات|الأدوار/i', css: '.roles-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/role|permission|دور|صلاحية/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/admin|manager|مدير|كاشير/i', css: '.roles-list, table, .role-card' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 16. سجل النشاط ──
    {
      name: 'Activity Log',
      nameAr: 'سجل النشاط',
      path: '/settings/activity-log',
      screenSlug: 'activity-log',
      descriptionAr: 'شاشة سجل النشاط تعرض تاريخ جميع العمليات التي تمت في النظام. كل سجل يظهر بنوع العملية (تسجيل دخول، بيع، تعديل منتج، حذف، إعداد) والمستخدم الذي قام بها والتاريخ والوقت والتفاصيل. يدعم التصفية حسب المستخدم ونوع العملية والتاريخ. مفيد للمراجعة والتدقيق الداخلي.',
      features: ['سجلات النشاط', 'التصفية حسب المستخدم', 'التصفية حسب نوع العملية', 'نطاق التاريخ'],
      expectedBehaviors: ['سجلات النشاط أو حالة فارغة', 'عناصر التصفية موجودة'],
      scenarios: [{
        scenarioName: 'عرض سجل النشاط',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لسجل النشاط', action: 'navigate', selectorStrategy: { aria: '[aria-label*="activity" i]', text: 'text=/activity.*log|سجل.*النشاط/i', css: '.activity-log' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/activity|نشاط|سجل/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/no.*activity|لا.*نشاط/i', css: '.log-list, table, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 17. النسخ الاحتياطي ──
    {
      name: 'Backup Settings',
      nameAr: 'النسخ الاحتياطي',
      path: '/settings/backup',
      screenSlug: 'backup-settings',
      descriptionAr: 'شاشة النسخ الاحتياطي تتيح إدارة نسخ البيانات احتياطياً واستعادتها. تتضمن: إنشاء نسخة احتياطية يدوية، جدولة النسخ التلقائي (يومي/أسبوعي)، عرض سجل النسخ السابقة مع حجمها وتاريخها، واستعادة نسخة سابقة. تعرض حالة آخر نسخة احتياطية ناجحة وموقع التخزين.',
      features: ['جدولة النسخ الاحتياطي', 'نسخ يدوي', 'خيارات الاستعادة', 'سجل النسخ'],
      expectedBehaviors: ['إعدادات النسخ الاحتياطي تُحمَّل', 'زر النسخ موجود'],
      scenarios: [{
        scenarioName: 'عرض النسخ الاحتياطي',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للنسخ الاحتياطي', action: 'navigate', selectorStrategy: { aria: '[aria-label*="backup" i]', text: 'text=/backup|نسخ.*احتياطي/i', css: '.backup-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, button', text: 'text=/backup|نسخ|restore|استعادة/i', css: '.page-title, button' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر النسخ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/backup|create|إنشاء|نسخ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 18. إعدادات الإشعارات ──
    {
      name: 'Notifications Settings',
      nameAr: 'إعدادات الإشعارات',
      path: '/settings/notifications',
      screenSlug: 'notifications-settings',
      descriptionAr: 'شاشة إعدادات الإشعارات تتيح التحكم في أنواع الإشعارات وقنوات التنبيه. تتضمن: تفعيل/تعطيل كل نوع إشعار (طلب جديد، تنبيه مخزون، دفعة، تحديث نظام، انتهاء صلاحية)، اختيار قناة التنبيه (إشعار داخلي، بريد إلكتروني، صوت)، وتحديد مستوى الأهمية لكل نوع.',
      features: ['قنوات الإشعارات', 'تفضيلات التنبيه', 'إعدادات الصوت', 'إشعارات البريد'],
      expectedBehaviors: ['تفضيلات الإشعارات تُحمَّل', 'مفاتيح التفعيل تعمل'],
      scenarios: [{
        scenarioName: 'عرض إعدادات الإشعارات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات الإشعارات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="notif" i]', text: 'text=/notification.*setting|إعدادات.*إشعار/i', css: '.notifications-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من مفاتيح التفعيل', action: 'exists', selectorStrategy: { aria: '[role="switch"], input[type="checkbox"]', text: 'text=/email|sound|push|بريد|صوت/i', css: '.switch, input[type="checkbox"], .toggle' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 19. هيئة الزكاة والضريبة (ZATCA) ──
    {
      name: 'ZATCA Compliance',
      nameAr: 'هيئة الزكاة والضريبة',
      path: '/settings/zatca',
      screenSlug: 'zatca-compliance',
      descriptionAr: 'شاشة هيئة الزكاة والضريبة والجمارك (ZATCA) تتيح إعداد الامتثال للفوترة الإلكترونية في المملكة العربية السعودية. تتضمن: معلومات التسجيل (الرقم الضريبي، اسم المنشأة "مؤسسة الهاي"، رمز الفرع)، تفعيل الفوترة الإلكترونية (e-invoicing)، تفعيل رمز QR على الإيصالات، حالة شهادة CSID (الربط مع منصة فاتورة)، وحالة الامتثال العامة. تعرض مؤشرات حالة لكل عنصر (مفعّل/غير مفعّل).',
      features: ['حالة التكامل مع ZATCA', 'إعداد الفوترة الإلكترونية', 'إعدادات QR Code', 'فحص الامتثال'],
      expectedBehaviors: ['نموذج إعداد ZATCA يُحمَّل', 'مؤشرات الحالة موجودة'],
      scenarios: [{
        scenarioName: 'عرض إعدادات ZATCA',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإعدادات ZATCA', action: 'navigate', selectorStrategy: { aria: '[aria-label*="zatca" i]', text: 'text=/zatca|فاتورة.*إلكترونية|هيئة/i', css: '.zatca-settings' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/zatca|فوترة|compliance|امتثال/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من الإعدادات', action: 'check-content', selectorStrategy: { aria: 'input, [role="switch"]', text: 'text=/enable|تفعيل|status|حالة/i', css: 'input, .form-field, .switch' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تكامل ZATCA API يحتاج بيانات اعتماد'],
    },

    // ── 20. المساعدة والدعم ──
    {
      name: 'Help & Support',
      nameAr: 'المساعدة والدعم',
      path: '/settings/help',
      screenSlug: 'help-support',
      descriptionAr: 'شاشة المساعدة والدعم توفر موارد المساعدة للمستخدمين. تتضمن: قسم الأسئلة الشائعة (FAQ) مع إجابات لأكثر الأسئلة تكراراً، معلومات الاتصال بالدعم الفني (هاتف، بريد إلكتروني)، روابط التوثيق ودليل الاستخدام، ومعلومات إصدار التطبيق الحالي. توفر وسيلة سريعة للوصول للمساعدة من داخل التطبيق.',
      features: ['قسم الأسئلة الشائعة', 'التواصل مع الدعم', 'روابط التوثيق', 'معلومات الإصدار'],
      expectedBehaviors: ['محتوى المساعدة يُحمَّل', 'معلومات الاتصال ظاهرة', 'الإصدار معروض'],
      scenarios: [{
        scenarioName: 'عرض المساعدة والدعم',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للمساعدة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="help" i]', text: 'text=/help|support|المساعدة|الدعم/i', css: '.help-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/help|support|مساعدة|دعم/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من الأسئلة أو الاتصال', action: 'check-content', selectorStrategy: { aria: '[role="list"], a[href]', text: 'text=/faq|contact|email|اتصل|بريد/i', css: '.faq-list, .contact-info, a' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },
  ],
};
