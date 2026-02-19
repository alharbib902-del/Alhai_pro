/**
 * Agent D: Marketing & Promotions (التسويق والعروض)
 * الوكيل المسؤول عن شاشات التسويق والعروض الترويجية وبرنامج الولاء
 */

module.exports = {
  categorySlug: 'marketing-promotions',
  categoryName: 'Marketing & Promotions',
  categoryNameAr: 'التسويق والعروض',
  categoryDescriptionAr: 'يشمل هذا القسم أدوات التسويق والترويج: إدارة الخصومات بأنواعها، إدارة الكوبونات الترويجية، العروض الخاصة (اشترِ واحصل، باقات)، العروض الذكية المقترحة بالذكاء الاصطناعي، وبرنامج ولاء العملاء بنظام النقاط والمستويات.',
  screens: [
    // ── 1. الخصومات ──
    {
      name: 'Discounts',
      nameAr: 'الخصومات',
      path: '/marketing/discounts',
      screenSlug: 'discounts',
      descriptionAr: 'شاشة إدارة الخصومات تعرض جميع قواعد الخصم المُعرَّفة مع بطاقات إحصائية (الإجمالي، النشط، المتوقف). كل خصم يظهر باسمه ونسبته/مبلغه والمنتجات المُطبَّق عليها (جميع المنتجات أو تصنيف محدد) وفترة صلاحيته ومفتاح تفعيل/إيقاف. يدعم أنواع: خصم نسبي (مثل 15%) وخصم ثابت (مثل 5 ر.س). يمكن إنشاء خصم جديد وتعديل الموجود.',
      features: ['قائمة قواعد الخصم', 'إنشاء خصم', 'أنواع نسبي/ثابت', 'تفعيل/إيقاف', 'فترة الصلاحية'],
      expectedBehaviors: ['عرض قائمة الخصومات أو حالة فارغة', 'زر الإنشاء موجود', 'مؤشرات الحالة ظاهرة'],
      scenarios: [{ scenarioName: 'عرض الخصومات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للخصومات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="discount" i]', text: 'text=/discount|الخصومات/i', css: '.discounts-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/discount|خصم/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإنشاء', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|خصم.*جديد|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من القائمة أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*discount|لا.*خصم/i', css: '.list-view, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 2. الكوبونات ──
    {
      name: 'Coupon Management',
      nameAr: 'إدارة الكوبونات',
      path: '/marketing/coupons',
      screenSlug: 'coupons',
      descriptionAr: 'شاشة إدارة الكوبونات الترويجية تعرض جميع أكواد الكوبون مع بطاقات إحصائية (إجمالي الكوبونات، النشط، الاستخدامات). كل كوبون يظهر بكوده (مثل WELCOME10, SAVE50, FREESHIP) ونوعه (خصم نسبي، خصم ثابت، توصيل مجاني) وعدد الاستخدامات من الحد الأقصى وحالته (نشط/منتهي). يمكن إنشاء كوبون جديد وتتبع استخدامات كل كوبون.',
      features: ['قائمة أكواد الكوبونات', 'إنشاء كوبون', 'تتبع الاستخدام', 'تواريخ الانتهاء', 'أنواع الكوبونات (نسبي/ثابت/توصيل)'],
      expectedBehaviors: ['عرض قائمة الكوبونات أو حالة فارغة', 'زر الإنشاء موجود', 'أكواد الكوبون معروضة'],
      scenarios: [{ scenarioName: 'عرض الكوبونات', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للكوبونات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="coupon" i]', text: 'text=/coupon|كوبون/i', css: '.coupons-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/coupon|كوبون/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإنشاء', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|كوبون.*جديد|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 3. العروض الخاصة ──
    {
      name: 'Special Offers',
      nameAr: 'العروض الخاصة',
      path: '/marketing/offers',
      screenSlug: 'special-offers',
      descriptionAr: 'شاشة العروض الخاصة تعرض جميع العروض الترويجية الموسمية والمناسباتية. تتضمن بطاقات إحصائية (الإجمالي، النشط، ينتهي قريباً). كل عرض يظهر باسمه (مثل "عرض رمضان"، "اشترِ 2 واحصل على 1") ونوعه (باقة، اشترِ واحصل مجاناً، خصم نسبي) وتاريخ انتهائه وحالته. يدعم أنواع متعددة من العروض مع تحديد فترة الصلاحية.',
      features: ['قائمة العروض', 'إنشاء عرض', 'نوع اشترِ X واحصل Y', 'صفقات الباقات', 'فترة الصلاحية'],
      expectedBehaviors: ['عرض قائمة العروض أو حالة فارغة', 'زر الإنشاء موجود'],
      scenarios: [{ scenarioName: 'عرض العروض الخاصة', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للعروض', action: 'navigate', selectorStrategy: { aria: '[aria-label*="offer" i]', text: 'text=/offer|عروض/i', css: '.offers-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/offer|عرو/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من زر الإنشاء', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|عرض.*جديد|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
      ]}],
      limitations: [],
    },

    // ── 4. العروض الذكية ──
    {
      name: 'Smart Promotions',
      nameAr: 'العروض الذكية',
      path: '/promotions',
      screenSlug: 'smart-promotions',
      descriptionAr: 'شاشة العروض الذكية تعمل بالذكاء الاصطناعي لتحليل المبيعات والمخزون واقتراح عروض ترويجية فعّالة تلقائياً. تحتوي على 3 تبويبات: اقتراحات AI (تعرض منتجات مع نسبة خصم مقترحة وسبب الاقتراح مثل "حركة بطيئة - 15 يوم بدون بيع" أو "قرب انتهاء الصلاحية"، مع أزرار تطبيق/تجاهل لكل اقتراح)، العروض النشطة، والسجل.',
      features: ['اقتراحات عروض بالذكاء الاصطناعي', 'قائمة العروض النشطة', 'مقاييس الأداء', 'إنشاء عرض', 'اختيار الجمهور المستهدف'],
      expectedBehaviors: ['عرض الاقتراحات أو العروض النشطة', 'لوحة الأداء ظاهرة', 'زر الإنشاء موجود'],
      scenarios: [{ scenarioName: 'عرض العروض الذكية', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال للعروض الذكية', action: 'navigate', selectorStrategy: { aria: '[aria-label*="promotion" i]', text: 'text=/promotion|العروض.*الذكية/i', css: '.promotions-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/promotion|عرو.*ذكي/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*promotion|لا.*عرو|اقتراحات/i', css: '.promotion-list, .empty-state, .suggestion-cards' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['اقتراحات AI تحتاج بيانات مبيعات'],
    },

    // ── 5. برنامج الولاء ──
    {
      name: 'Loyalty Program',
      nameAr: 'برنامج الولاء',
      path: '/loyalty',
      screenSlug: 'loyalty-program',
      descriptionAr: 'شاشة برنامج ولاء العملاء بنظام النقاط والمستويات. تحتوي على 3 تبويبات: الأعضاء (قائمة العملاء المسجلين مع نقاطهم ومستواهم: ذهبي/فضي/برونزي ومبلغ مصروفاتهم)، المكافآت (كتالوج المكافآت المتاحة)، والإعدادات (قواعد كسب النقاط ومستويات العضوية). تعرض بطاقات إحصائية في الأعلى (إجمالي الأعضاء، أعلى مستوى، إجمالي النقاط).',
      features: ['نظرة عامة على البرنامج', 'إعداد المستويات', 'نظام النقاط', 'قائمة الأعضاء', 'كتالوج المكافآت', 'سجل النقاط'],
      expectedBehaviors: ['لوحة البرنامج تُحمَّل', 'مستويات العضوية معروضة', 'عدد الأعضاء أو حالة فارغة'],
      scenarios: [{ scenarioName: 'عرض برنامج الولاء', dataState: 'any', setup: [], tests: [
        { stepName: 'الانتقال لبرنامج الولاء', action: 'navigate', selectorStrategy: { aria: '[aria-label*="loyalty" i]', text: 'text=/loyalty|الولاء/i', css: '.loyalty-screen' }, expect: 'page-visible', onFailScreenshot: true },
        { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/loyalty|ولاء/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
        { stepName: 'التحقق من محتوى البرنامج', action: 'check-content', selectorStrategy: { aria: '[role="tablist"], [role="list"]', text: 'text=/tier|مستوى|points|نقاط|member|عضو/i', css: '.tier-card, .member-list' }, expect: 'content-or-empty', onFailScreenshot: true },
      ]}],
      limitations: ['نظام المستويات والمكافآت يحتاج إعداداً مسبقاً'],
    },
  ],
};
