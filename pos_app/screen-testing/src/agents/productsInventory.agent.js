/**
 * Agent H: Products, Inventory & Customers (المنتجات والمخزون والعملاء)
 * الوكيل المسؤول عن شاشات المنتجات والفئات والمخزون والعملاء
 */

module.exports = {
  categorySlug: 'products-inventory',
  categoryName: 'Products, Inventory & Customers',
  categoryNameAr: 'المنتجات والمخزون والعملاء',
  categoryDescriptionAr: 'يشمل هذا القسم إدارة المنتجات (عرض، إضافة، تعديل، تفاصيل)، الفئات والتصنيفات، إدارة المخزون (الكميات، التنبيهات، الجرد)، وإدارة العملاء (قائمة العملاء، تفاصيل العميل، كشف الحساب).',
  screens: [
    // ── 1. المنتجات ──
    {
      name: 'Products',
      nameAr: 'المنتجات',
      path: '/products',
      screenSlug: 'products',
      descriptionAr: 'شاشة المنتجات تعرض قائمة بجميع منتجات المتجر مع إمكانية البحث والتصفية. كل منتج يظهر باسمه وصورته وسعره وكمية المخزون المتوفرة وحالته (نشط/غير نشط). يمكن البحث عن منتج بالاسم أو الباركود، التصفية حسب الفئة، وترتيب المنتجات. يوجد زر إضافة منتج جديد.',
      features: ['قائمة المنتجات', 'بحث وتصفية', 'إضافة منتج', 'عرض التفاصيل'],
      expectedBehaviors: ['قائمة المنتجات تُحمَّل', 'البحث يعمل', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض المنتجات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للمنتجات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="product" i]', text: 'text=/products|المنتجات/i', css: '.products-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/product|منتج/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من قائمة المنتجات', action: 'check-content', selectorStrategy: { aria: '[role="grid"], [role="list"]', text: 'text=/no.*product|لا.*منتج/i', css: '.product-list, .product-grid, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تستخدم lazy loading'],
    },

    // ── 2. إضافة منتج ──
    {
      name: 'Add Product',
      nameAr: 'إضافة منتج',
      path: '/products/add',
      screenSlug: 'product-add',
      descriptionAr: 'شاشة إضافة منتج جديد تتضمن نموذجاً شاملاً لإدخال بيانات المنتج: الاسم (عربي/إنجليزي)، الباركود، الفئة، سعر الشراء، سعر البيع، الكمية الأولية، الوحدة، الوصف، رفع صورة المنتج، وإعدادات الضريبة. جميع الحقول مع تحقق من المدخلات وزر حفظ.',
      features: ['نموذج إضافة منتج', 'رفع صورة', 'اختيار الفئة', 'إعدادات السعر والضريبة'],
      expectedBehaviors: ['نموذج الإضافة يُحمَّل', 'الحقول قابلة للإدخال', 'زر الحفظ موجود'],
      scenarios: [{
        scenarioName: 'عرض نموذج إضافة منتج',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لإضافة منتج', action: 'navigate', selectorStrategy: { aria: '[aria-label*="add" i]', text: 'text=/add.*product|إضافة.*منتج/i', css: '.product-form' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من النموذج', action: 'exists', selectorStrategy: { aria: 'input, textarea, select', text: 'text=/name|اسم|price|سعر|barcode|باركود/i', css: 'input, textarea, select' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الحفظ', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/save|حفظ|add|إضافة/i', css: 'button' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 3. تفاصيل المنتج ──
    {
      name: 'Product Detail',
      nameAr: 'تفاصيل المنتج',
      path: '/products/demo-product-001',
      screenSlug: 'product-detail',
      descriptionAr: 'شاشة تفاصيل المنتج تعرض جميع معلومات المنتج المحدد: الصورة، الاسم، الباركود، الفئة، سعر الشراء، سعر البيع، هامش الربح، الكمية المتوفرة، سجل حركات المخزون، وإحصائيات المبيعات. تتضمن أزرار تعديل وحذف.',
      features: ['تفاصيل كاملة', 'سجل حركات المخزون', 'إحصائيات المبيعات', 'تعديل/حذف'],
      expectedBehaviors: ['تفاصيل المنتج تُحمَّل', 'البيانات ظاهرة أو خطأ "غير موجود"'],
      scenarios: [{
        scenarioName: 'عرض تفاصيل المنتج',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لتفاصيل المنتج', action: 'navigate', selectorStrategy: { aria: '[aria-label*="product" i]', text: 'text=/product|منتج/i', css: '.product-detail' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/product|منتج|detail|تفاصيل|not.*found|غير.*موجود/i', css: '.page-title, .error-state' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['يحتاج معرّف منتج حقيقي لعرض كامل - يستخدم ID تجريبي'],
    },

    // ── 4. الفئات ──
    {
      name: 'Categories',
      nameAr: 'الفئات والتصنيفات',
      path: '/categories',
      screenSlug: 'categories',
      descriptionAr: 'شاشة الفئات والتصنيفات تعرض قائمة بجميع فئات المنتجات (مثل: مشروبات، أغذية، منظفات، إلكترونيات). كل فئة تظهر باسمها وأيقونتها ولونها وعدد المنتجات فيها. يمكن إضافة فئة جديدة، تعديل فئة موجودة، أو حذفها. تدعم الترتيب بالسحب والإفلات.',
      features: ['قائمة الفئات', 'إضافة فئة', 'تعديل/حذف', 'عدد المنتجات'],
      expectedBehaviors: ['قائمة الفئات تُحمَّل', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض الفئات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للفئات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="categor" i]', text: 'text=/categories|الفئات|التصنيفات/i', css: '.categories-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/categor|فئ|تصنيف/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="grid"]', text: 'text=/no.*categor|لا.*فئ/i', css: '.category-list, .category-grid, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 5. المخزون ──
    {
      name: 'Inventory',
      nameAr: 'المخزون',
      path: '/inventory',
      screenSlug: 'inventory',
      descriptionAr: 'شاشة المخزون تعرض نظرة شاملة على مستويات المخزون لجميع المنتجات. تتضمن: قائمة المنتجات مع كمياتها الحالية، حد إعادة الطلب، تنبيهات النقص، المنتجات منتهية الصلاحية أو قاربت على الانتهاء. يمكن تصفية المنتجات حسب (الكل، نقص المخزون، نفد المخزون، قريب الانتهاء). يدعم تعديل الكميات وإجراء الجرد.',
      features: ['مستويات المخزون', 'تنبيهات النقص', 'تصفية المنتجات', 'تعديل الكميات'],
      expectedBehaviors: ['قائمة المخزون تُحمَّل', 'المنتجات مع كمياتها ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض المخزون',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للمخزون', action: 'navigate', selectorStrategy: { aria: '[aria-label*="inventor" i]', text: 'text=/inventory|المخزون/i', css: '.inventory-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/inventor|مخزون/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/no.*inventory|لا.*مخزون/i', css: '.inventory-list, table, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تستخدم lazy loading'],
    },

    // ── 6. العملاء ──
    {
      name: 'Customers',
      nameAr: 'العملاء',
      path: '/customers',
      screenSlug: 'customers',
      descriptionAr: 'شاشة العملاء تعرض قائمة بجميع عملاء المتجر مع بطاقات إحصائية (إجمالي العملاء، العملاء الجدد، إجمالي المستحقات). كل عميل يظهر باسمه ورقم هاتفه ورصيد حسابه (دائن/مدين) وإجمالي مشترياته. يمكن البحث عن عميل، إضافة عميل جديد، وعرض تفاصيل وكشف حساب كل عميل.',
      features: ['قائمة العملاء', 'بحث', 'إضافة عميل', 'رصيد الحساب', 'إحصائيات'],
      expectedBehaviors: ['قائمة العملاء تُحمَّل', 'البحث يعمل', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض العملاء',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للعملاء', action: 'navigate', selectorStrategy: { aria: '[aria-label*="customer" i]', text: 'text=/customers|العملاء/i', css: '.customers-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/customer|عميل|عملاء/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/no.*customer|لا.*عميل/i', css: '.customer-list, table, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تستخدم lazy loading'],
    },

    // ── 7. تفاصيل العميل ──
    {
      name: 'Customer Detail',
      nameAr: 'تفاصيل العميل',
      path: '/customers/demo-customer-001',
      screenSlug: 'customer-detail',
      descriptionAr: 'شاشة تفاصيل العميل تعرض جميع معلومات العميل المحدد: الاسم، رقم الهاتف، البريد الإلكتروني، العنوان، رصيد الحساب، حد الائتمان، إجمالي المشتريات، وسجل المعاملات. تتضمن أزرار: تعديل البيانات، كشف الحساب، إرسال رسالة واتساب.',
      features: ['بيانات العميل', 'رصيد الحساب', 'سجل المعاملات', 'كشف الحساب'],
      expectedBehaviors: ['تفاصيل العميل تُحمَّل أو رسالة "غير موجود"'],
      scenarios: [{
        scenarioName: 'عرض تفاصيل العميل',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لتفاصيل العميل', action: 'navigate', selectorStrategy: { aria: '[aria-label*="customer" i]', text: 'text=/customer|عميل/i', css: '.customer-detail' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/customer|عميل|detail|تفاصيل|not.*found|غير.*موجود/i', css: '.page-title, .error-state' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['يحتاج معرّف عميل حقيقي - يستخدم ID تجريبي'],
    },

    // ── 8. تفاصيل الفاتورة ──
    {
      name: 'Invoice Detail',
      nameAr: 'تفاصيل الفاتورة',
      path: '/invoices/demo-invoice-001',
      screenSlug: 'invoice-detail',
      descriptionAr: 'شاشة تفاصيل الفاتورة تعرض جميع معلومات فاتورة محددة: رقم الفاتورة، التاريخ، اسم العميل، قائمة المنتجات (الاسم، الكمية، سعر الوحدة، الإجمالي)، المجموع الفرعي، الخصم، الضريبة، الإجمالي النهائي، طريقة الدفع، وحالة الفاتورة. تتضمن أزرار: طباعة، استرجاع، إلغاء.',
      features: ['تفاصيل الفاتورة', 'قائمة المنتجات', 'معلومات الدفع', 'طباعة/استرجاع'],
      expectedBehaviors: ['تفاصيل الفاتورة تُحمَّل أو رسالة "غير موجودة"'],
      scenarios: [{
        scenarioName: 'عرض تفاصيل الفاتورة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لتفاصيل الفاتورة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="invoice" i]', text: 'text=/invoice|فاتورة/i', css: '.invoice-detail' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/invoice|فاتورة|detail|تفاصيل|not.*found|غير.*موجود/i', css: '.page-title, .error-state' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['يحتاج معرّف فاتورة حقيقي - يستخدم ID تجريبي'],
    },

    // ── 9. تفاصيل المورد ──
    {
      name: 'Supplier Detail',
      nameAr: 'تفاصيل المورد',
      path: '/suppliers/demo-supplier-001',
      screenSlug: 'supplier-detail',
      descriptionAr: 'شاشة تفاصيل المورد تعرض جميع معلومات المورد المحدد: الاسم، الهاتف، البريد، العنوان، الرقم الضريبي، السجل التجاري، إجمالي المشتريات منه، المستحقات، وسجل فواتير الشراء. تتضمن أزرار: تعديل البيانات، إنشاء فاتورة شراء جديدة.',
      features: ['بيانات المورد', 'سجل المشتريات', 'المستحقات', 'فاتورة شراء جديدة'],
      expectedBehaviors: ['تفاصيل المورد تُحمَّل أو رسالة "غير موجود"'],
      scenarios: [{
        scenarioName: 'عرض تفاصيل المورد',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لتفاصيل المورد', action: 'navigate', selectorStrategy: { aria: '[aria-label*="supplier" i]', text: 'text=/supplier|مورد/i', css: '.supplier-detail' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'exists', selectorStrategy: { aria: 'h1, h2', text: 'text=/supplier|مورد|detail|تفاصيل|not.*found|غير.*موجود/i', css: '.page-title, .error-state' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: ['يحتاج معرّف مورد حقيقي - يستخدم ID تجريبي'],
    },
  ],
};
