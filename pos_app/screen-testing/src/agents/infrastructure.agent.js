/**
 * Agent E: Infrastructure (البنية التحتية)
 * الوكيل المسؤول عن شاشات البنية التحتية: الإشعارات، الطباعة، المزامنة، السائقين، الفروع
 */

module.exports = {
  categorySlug: 'infrastructure',
  categoryName: 'Infrastructure',
  categoryNameAr: 'البنية التحتية',
  categoryDescriptionAr: 'يشمل هذا القسم أدوات البنية التحتية للنظام: إدارة الإشعارات بأنواعها (طلبات، مخزون، مدفوعات، نظام)، قائمة الطباعة مع حالة الطابعة، حالة المزامنة مع السيرفر، العمليات المعلقة، حل التعارضات، إدارة السائقين والتوصيل، وإدارة الفروع.',
  screens: [
    // ── 1. الإشعارات ──
    {
      name: 'Notifications',
      nameAr: 'الإشعارات',
      path: '/notifications',
      screenSlug: 'notifications',
      descriptionAr: 'شاشة الإشعارات تعرض قائمة بجميع إشعارات النظام مع تنوع أنواعها. تتضمن أنواع الإشعارات: طلب جديد (أيقونة سلة)، تنبيه مخزون (أيقونة صندوق)، دفعة مستلمة (أيقونة نقود)، تحديث النظام (أيقونة ترس)، منتج قريب الانتهاء (أيقونة ساعة)، طلب مكتمل (أيقونة تأكيد). الإشعارات غير المقروءة تظهر بنقطة زرقاء مميزة. يوجد زر "قراءة الكل" في الأعلى لتحديد جميع الإشعارات كمقروءة.',
      features: ['قائمة الإشعارات', 'حالة مقروء/غير مقروء', 'قراءة الكل', 'أنواع الإشعارات (طلب، مخزون، نظام، دفعة، انتهاء صلاحية)', 'النقر للتنقل'],
      expectedBehaviors: ['عرض قائمة الإشعارات أو حالة فارغة', 'زر قراءة الكل موجود', 'أنواع الإشعارات ظاهرة'],
      scenarios: [{
        scenarioName: 'عرض الإشعارات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للإشعارات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="notif" i]', text: 'text=/notification|الإشعارات/i', css: '.notifications-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/notif|إشعار/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من القائمة أو حالة فارغة', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*notif|لا.*إشعار/i', css: '.notification-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 2. قائمة الطباعة ──
    {
      name: 'Print Queue',
      nameAr: 'قائمة الطباعة',
      path: '/print-queue',
      screenSlug: 'print-queue',
      descriptionAr: 'شاشة قائمة الطباعة تعرض حالة الطابعة المتصلة وجميع مهام الطباعة. في الأعلى يظهر اسم الطابعة (مثل XP-80C) مع حالة الاتصال (متصل/غير متصل). تعرض بطاقات إحصائية: إجمالي المهام، في الانتظار، فشلت. كل مهمة طباعة تظهر برقم الفاتورة (مثل INV-001) وحالتها (في الانتظار/فشلت) مع إمكانية إعادة المحاولة. يوجد زران رئيسيان: "طباعة الكل" لطباعة جميع المهام المعلقة و"مسح الكل" لحذف القائمة.',
      features: ['قائمة مهام الطباعة', 'حالة المهمة (في الانتظار/طباعة/فشلت)', 'إلغاء مهمة', 'إعادة المحاولة', 'حالة الطابعة'],
      expectedBehaviors: ['عرض قائمة الطباعة أو حالة فارغة', 'مؤشر حالة الطابعة ظاهر'],
      scenarios: [{
        scenarioName: 'عرض قائمة الطباعة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال لقائمة الطباعة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="print" i]', text: 'text=/print.*queue|طابعة|طباعة/i', css: '.print-queue-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/print|طباعة/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من محتوى القائمة', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/no.*print|لا.*طباعة|empty|فارغ/i', css: '.queue-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تحتاج مهام طباعة في القائمة لعرض الحالة الممتلئة'],
    },

    // ── 3. حالة المزامنة ──
    {
      name: 'Sync Status',
      nameAr: 'حالة المزامنة',
      path: '/sync',
      screenSlug: 'sync-status',
      descriptionAr: 'شاشة حالة المزامنة تعرض حالة الاتصال بالسيرفر ومعلومات الجهاز. في الأعلى بانر يوضح حالة الاتصال (متصل بالسيرفر/غير متصل). تعرض معلومات الجهاز: معرّف الجهاز (مثل POS-001)، إصدار التطبيق (مثل 1.0.0)، آخر وقت مزامنة. تعرض أيضاً حالة قاعدة البيانات المحلية (سليمة/بها مشاكل). يوجد زر "مزامنة الآن" لإجراء مزامنة فورية يدوية مع السيرفر.',
      features: ['مؤشر حالة المزامنة', 'آخر وقت مزامنة', 'عدد العناصر المعلقة', 'زر المزامنة الفورية', 'حالة الاتصال'],
      expectedBehaviors: ['لوحة حالة المزامنة تُحمَّل', 'المؤشرات ظاهرة', 'زر المزامنة يعمل'],
      scenarios: [{
        scenarioName: 'عرض حالة المزامنة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للمزامنة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="sync" i]', text: 'text=/sync|المزامنة/i', css: '.sync-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/sync|مزامنة/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من عرض حالة المزامنة', action: 'check-content', selectorStrategy: { aria: '[role="status"]', text: 'text=/synced|connected|متصل|محدث|last.*sync|آخر/i', css: '.sync-status, .status-indicator, .connection-status' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 4. العمليات المعلقة ──
    {
      name: 'Pending Transactions',
      nameAr: 'العمليات المعلقة',
      path: '/sync/pending',
      screenSlug: 'pending-transactions',
      descriptionAr: 'شاشة العمليات المعلقة تعرض قائمة بجميع المعاملات التي لم تتم مزامنتها بعد مع السيرفر (مثل فواتير بيع، مرتجعات، تعديلات مخزون). كل عملية تظهر بنوعها ورقمها وتاريخها وحالتها (في الانتظار/فشلت). يمكن إعادة محاولة المزامنة لكل عملية على حدة أو الكل مرة واحدة. في حالة عدم وجود عمليات معلقة تظهر رسالة تفيد بأن كل شيء مزامن.',
      features: ['قائمة العمليات المعلقة', 'تفاصيل العملية', 'إعادة المزامنة', 'حذف المعلق'],
      expectedBehaviors: ['عرض القائمة أو حالة فارغة', 'زر إعادة المحاولة موجود إن وُجدت عمليات'],
      scenarios: [{
        scenarioName: 'عرض العمليات المعلقة',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للمعلقة', action: 'navigate', selectorStrategy: { aria: '[aria-label*="pending" i]', text: 'text=/pending|معلقة/i', css: '.pending-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/pending|معلق/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="list"], [role="table"]', text: 'text=/no.*pending|لا.*معلق/i', css: '.pending-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تحتاج عمليات أوفلاين لعرض الحالة الممتلئة'],
    },

    // ── 5. حل التعارضات ──
    {
      name: 'Conflict Resolution',
      nameAr: 'حل التعارضات',
      path: '/sync/conflicts',
      screenSlug: 'conflict-resolution',
      descriptionAr: 'شاشة حل التعارضات تعرض الحالات التي يوجد فيها اختلاف بين البيانات المحلية والبيانات على السيرفر (مثل تعديل نفس المنتج من جهازين مختلفين). كل تعارض يعرض مقارنة جنباً إلى جنب بين النسخة المحلية والنسخة البعيدة مع إبراز الاختلافات. يمكن حل كل تعارض باختيار الاحتفاظ بالنسخة المحلية أو البعيدة، أو حل الكل دفعة واحدة.',
      features: ['قائمة التعارضات', 'مقارنة جنب إلى جنب', 'حل (احتفاظ بالمحلي/البعيد)', 'حل جماعي'],
      expectedBehaviors: ['عرض التعارضات أو حالة فارغة', 'إجراءات الحل موجودة إن وُجدت تعارضات'],
      scenarios: [{
        scenarioName: 'عرض التعارضات',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للتعارضات', action: 'navigate', selectorStrategy: { aria: '[aria-label*="conflict" i]', text: 'text=/conflict|تعارض/i', css: '.conflict-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/conflict|تعارض/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من المحتوى', action: 'check-content', selectorStrategy: { aria: '[role="list"]', text: 'text=/no.*conflict|لا.*تعارض/i', css: '.conflict-list, .empty-state' }, expect: 'content-or-empty', onFailScreenshot: true },
        ],
      }],
      limitations: ['تحتاج تعارضات مزامنة فعلية للاختبار الكامل'],
    },

    // ── 6. إدارة السائقين ──
    {
      name: 'Driver Management',
      nameAr: 'إدارة السائقين',
      path: '/drivers',
      screenSlug: 'drivers',
      descriptionAr: 'شاشة إدارة السائقين تعرض قائمة بجميع سائقي التوصيل مع بطاقات إحصائية في الأعلى (إجمالي التوصيلات، السائقين المتاحين، في التوصيل). كل سائق يظهر باسمه (مثل سعد محمد، فهد عبدالله، خالد عمر) وتقييمه بالنجوم وعدد توصيلاته وحالته (متاح بأيقونة خضراء، في توصيل بأيقونة برتقالية، غير متصل بأيقونة رمادية) ونوع مركبته. يمكن إضافة سائق جديد أو عرض تفاصيل كل سائق.',
      features: ['قائمة السائقين', 'إضافة سائق', 'حالة السائق (متاح/في توصيل/غير متصل)', 'تعيين التوصيل', 'مقاييس الأداء'],
      expectedBehaviors: ['عرض قائمة السائقين أو حالة فارغة', 'زر الإضافة موجود'],
      scenarios: [{
        scenarioName: 'عرض السائقين',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للسائقين', action: 'navigate', selectorStrategy: { aria: '[aria-label*="driver" i]', text: 'text=/driver|السائقين/i', css: '.drivers-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/driver|سائق/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الإضافة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|إضافة|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },

    // ── 7. إدارة الفروع ──
    {
      name: 'Branch Management',
      nameAr: 'إدارة الفروع',
      path: '/branches',
      screenSlug: 'branches',
      descriptionAr: 'شاشة إدارة الفروع تعرض قائمة بجميع فروع المنشأة مع بطاقات إحصائية (إجمالي المبيعات، الفروع النشطة). كل فرع يظهر باسمه (مثل الفرع الرئيسي - الرياض، فرع الروضة، فرع السلامة) وموقعه وعدد الموظفين وإجمالي مبيعاته وحالته (نشط/مغلق). الفروع المغلقة تظهر بلون باهت مع علامة "مغلق". يمكن إضافة فرع جديد أو عرض تفاصيل كل فرع وإحصائياته.',
      features: ['قائمة الفروع', 'إضافة فرع', 'تفاصيل الفرع', 'حالة الفرع', 'التحويل بين الفروع'],
      expectedBehaviors: ['عرض قائمة الفروع أو حالة فارغة', 'زر الإضافة موجود', 'تفاصيل الفرع قابلة للنقر'],
      scenarios: [{
        scenarioName: 'عرض الفروع',
        dataState: 'any',
        setup: [],
        tests: [
          { stepName: 'الانتقال للفروع', action: 'navigate', selectorStrategy: { aria: '[aria-label*="branch" i]', text: 'text=/branch|الفروع/i', css: '.branches-screen' }, expect: 'page-visible', onFailScreenshot: true },
          { stepName: 'التحقق من العنوان', action: 'exists', selectorStrategy: { aria: 'h1, h2, [role="heading"]', text: 'text=/branch|فرع|فروع/i', css: '.page-title' }, expect: 'element-exists', onFailScreenshot: true },
          { stepName: 'التحقق من زر الإضافة', action: 'exists', selectorStrategy: { aria: 'button', text: 'text=/add|إضافة|\\+/i', css: 'button, .fab' }, expect: 'element-exists', onFailScreenshot: true },
        ],
      }],
      limitations: [],
    },
  ],
};
