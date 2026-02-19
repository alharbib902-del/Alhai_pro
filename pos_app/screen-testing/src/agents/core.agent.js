/**
 * Agent G: Core (الشاشات الأساسية)
 * الوكيل المسؤول عن الشاشات الأساسية: لوحة المعلومات، نقطة البيع، الرئيسية، الملف الشخصي، الترحيب
 */

module.exports = {
  categorySlug: 'core',
  categoryName: 'Core',
  categoryNameAr: 'الشاشات الأساسية',
  categoryDescriptionAr: 'يشمل هذا القسم الشاشات الأساسية للتطبيق: لوحة المعلومات (Dashboard) مع الإحصائيات والمخططات، شاشة نقطة البيع (POS) الرئيسية لإتمام عمليات البيع، شاشة الدفع، شاشة الإيصال، الصفحة الرئيسية، الملف الشخصي، وشاشة الترحيب للمستخدمين الجدد.',
  screens: [
    // ── 1. لوحة المعلومات ──
    {
      name: 'Dashboard',
      nameAr: 'لوحة المعلومات',
      path: '/dashboard',
      screenSlug: 'dashboard',
      descriptionAr: 'لوحة المعلومات الرئيسية تعرض ملخصاً شاملاً لأداء المتجر. تتضمن: بطاقات إحصائية (إجمالي المبيعات اليوم، عدد الفواتير، متوسط قيمة الفاتورة، عدد العملاء)، مخطط المبيعات اليومية/الأسبوعية/الشهرية، قائمة آخر المعاملات، المنتجات الأكثر مبيعاً، وأزرار الوصول السريع (نقطة البيع، المنتجات، الفواتير، التقارير). تعتبر أول شاشة يراها المستخدم بعد تسجيل الدخول.',
      features: ['بطاقات إحصائية', 'مخطط المبيعات', 'آخر المعاملات', 'الأكثر مبيعاً', 'وصول سريع'],
      expectedBehaviors: ['اللوحة تُحمَّل بالبيانات', 'المخططات ظاهرة', 'أزرار الوصول السريع تعمل'],
      scenarios: [{
        scenarioName: 'عرض لوحة المعلومات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للوحة المعلومات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="dashboard" i]', text: 'text=/dashboard|لوحة/i', css: '.dashboard-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/dashboard|لوحة|مبيعات/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من الإحصائيات', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="grid"]', text: 'text=/sales|مبيعات|invoices|فواتير/i', css: '.stat-card, .stats-grid, .chart' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 2. نقطة البيع ──
    {
      name: 'POS Screen',
      nameAr: 'نقطة البيع',
      path: '/pos',
      screenSlug: 'pos-main',
      descriptionAr: 'شاشة نقطة البيع هي الشاشة الأساسية للكاشير لإتمام عمليات البيع. تنقسم إلى قسمين: الجهة اليسرى تعرض شبكة المنتجات مع شريط البحث وأزرار الفئات للتصفية، والجهة اليمنى تعرض سلة المشتريات مع تفاصيل كل منتج (الاسم، الكمية، السعر) والإجمالي وأزرار الدفع. تدعم البحث السريع، مسح الباركود، إضافة الكمية، تطبيق الخصم، واختيار العميل.',
      features: ['شبكة المنتجات', 'سلة المشتريات', 'البحث السريع', 'مسح الباركود', 'أزرار الفئات', 'أزرار الدفع'],
      expectedBehaviors: ['شاشة البيع تُحمَّل بالكامل', 'المنتجات ظاهرة', 'السلة تعمل'],
      scenarios: [{
        scenarioName: 'عرض نقطة البيع',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لنقطة البيع', action: 'navigate', selectorStrategy: { aria: '[aria-label*="pos" i]', text: 'text=/pos|نقطة.*البيع/i', css: '.pos-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من تحميل الشاشة', action: 'exists', selectorStrategy: { aria: 'input, [role="search"]', text: 'text=/search|بحث|product|منتج/i', css: 'input, .search-bar' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من المنتجات', action: 'check-content', selectorStrategy: { aria: '[role="grid"], [role="list"]', text: 'text=/product|منتج|cart|سلة/i', css: '.product-grid, .cart' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['شاشة ثقيلة تستخدم lazy loading'],
    },

    // ── 3. شاشة الدفع ──
    {
      name: 'Payment Screen',
      nameAr: 'شاشة الدفع',
      path: '/pos/payment',
      screenSlug: 'pos-payment',
      descriptionAr: 'شاشة الدفع تظهر بعد اختيار طريقة الدفع من شاشة نقطة البيع. تعرض ملخص الفاتورة (المنتجات، الكميات، الأسعار، الإجمالي قبل الضريبة، الضريبة، الإجمالي النهائي) مع خيارات الدفع المتاحة (نقد، بطاقة، مختلط، آجل). للدفع النقدي يظهر حقل المبلغ المدفوع مع حساب الباقي تلقائياً.',
      features: ['ملخص الفاتورة', 'خيارات الدفع', 'حساب الباقي', 'إتمام البيع'],
      expectedBehaviors: ['شاشة الدفع تُحمَّل', 'خيارات الدفع ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض شاشة الدفع',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لشاشة الدفع', action: 'navigate', selectorStrategy: { aria: '[aria-label*="payment" i]', text: 'text=/payment|الدفع/i', css: '.payment-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, button', text: 'text=/pay|دفع|total|إجمالي|cash|نقد/i', css: '.page-title, button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['قد تحتاج منتجات في السلة لعرض كامل'],
    },

    // ── 4. شاشة الإيصال ──
    {
      name: 'Receipt Screen',
      nameAr: 'شاشة الإيصال',
      path: '/pos/receipt',
      screenSlug: 'pos-receipt',
      descriptionAr: 'شاشة الإيصال تظهر بعد إتمام عملية الدفع بنجاح. تعرض إيصال البيع بتنسيق قابل للطباعة يتضمن: معلومات المتجر (الاسم، العنوان، الهاتف)، رقم الفاتورة، التاريخ والوقت، تفاصيل المنتجات المباعة، الإجمالي، طريقة الدفع، والرقم الضريبي. تتضمن أزرار: طباعة الإيصال، مشاركة عبر واتساب، وعودة لنقطة البيع.',
      features: ['عرض الإيصال', 'زر الطباعة', 'مشاركة واتساب', 'عودة للبيع'],
      expectedBehaviors: ['شاشة الإيصال تُحمَّل', 'محتوى الإيصال ظاهر'],
      scenarios: [{
        scenarioName: 'عرض شاشة الإيصال',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لشاشة الإيصال', action: 'navigate', selectorStrategy: { aria: '[aria-label*="receipt" i]', text: 'text=/receipt|إيصال/i', css: '.receipt-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, button', text: 'text=/receipt|إيصال|print|طباعة/i', css: '.page-title, button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['تحتاج فاتورة مكتملة لعرض كامل'],
    },

    // ── 5. الصفحة الرئيسية ──
    {
      name: 'Home Screen',
      nameAr: 'الصفحة الرئيسية',
      path: '/home',
      screenSlug: 'home',
      descriptionAr: 'الصفحة الرئيسية تعمل كنقطة انطلاق للمستخدم مع عرض ملخص سريع وأزرار التنقل الرئيسية. قد تتضمن رسائل ترحيب، إشعارات مهمة، اختصارات للشاشات الأكثر استخداماً، وملخص سريع لحالة المتجر.',
      features: ['رسالة ترحيب', 'اختصارات التنقل', 'ملخص الحالة'],
      expectedBehaviors: ['الصفحة تُحمَّل', 'عناصر التنقل ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض الصفحة الرئيسية',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للرئيسية', action: 'navigate', selectorStrategy: { aria: '[aria-label*="home" i]', text: 'text=/home|الرئيسية/i', css: '.home-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/home|مرحباً|welcome|الرئيسية/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 6. الملف الشخصي ──
    {
      name: 'Profile',
      nameAr: 'الملف الشخصي',
      path: '/profile',
      screenSlug: 'profile',
      descriptionAr: 'شاشة الملف الشخصي تعرض معلومات المستخدم الحالي (الاسم، الدور، البريد الإلكتروني، رقم الهاتف) مع إمكانية تعديل البيانات الشخصية، تغيير كلمة المرور، وتسجيل الخروج.',
      features: ['معلومات المستخدم', 'تعديل البيانات', 'تغيير كلمة المرور', 'تسجيل الخروج'],
      expectedBehaviors: ['بيانات المستخدم ظاهرة', 'أزرار التعديل موجودة'],
      scenarios: [{
        scenarioName: 'عرض الملف الشخصي',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للملف الشخصي', action: 'navigate', selectorStrategy: { aria: '[aria-label*="profile" i]', text: 'text=/profile|الملف/i', css: '.profile-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/profile|ملف|حساب|account/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 7. شاشة الترحيب ──
    {
      name: 'Onboarding',
      nameAr: 'شاشة الترحيب',
      path: '/onboarding',
      screenSlug: 'onboarding',
      descriptionAr: 'شاشة الترحيب تظهر للمستخدمين الجدد عند أول استخدام للتطبيق. تعرض مجموعة من الشرائح التعريفية بمميزات التطبيق مع صور توضيحية ونصوص وصفية. تتضمن أزرار التالي/السابق وزر تخطي للانتقال مباشرة.',
      features: ['شرائح تعريفية', 'صور توضيحية', 'أزرار التنقل', 'زر التخطي'],
      expectedBehaviors: ['شاشة الترحيب تُحمَّل', 'الشرائح ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض شاشة الترحيب',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للترحيب', action: 'navigate', selectorStrategy: { aria: '[aria-label*="onboard" i]', text: 'text=/onboard|welcome|مرحباً|ترحيب/i', css: '.onboarding-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, button', text: 'text=/next|skip|start|التالي|تخطي|ابدأ/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },
  ],
};
