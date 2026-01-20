/* ===========================================
   بقالة الحي - تحليل المشروع
   Professional JavaScript - v2.0
   =========================================== */

// ===========================================
// TRANSLATIONS - 6 Languages
// ===========================================
const translations = {
    ar: {
        // Login Screen
        loginWelcome: "مرحباً بك في منصة تحليل المشروع",
        loginWelcomeDesc: "الوصول إلى الدراسات والتحليلات الحصرية",
        feature1: "دراسة تكاليف الاستضافة",
        feature2: "تحليل المنافسين",
        feature3: "خطط الأسعار المقترحة",
        feature4: "مميزات المنصة الكاملة",
        loginTitle: "تسجيل الدخول",
        loginSubtitle: "أدخل بيانات الدخول للوصول إلى الدراسة",
        username: "اسم المستخدم",
        password: "كلمة المرور",
        usernamePlaceholder: "أدخل اسم المستخدم",
        passwordPlaceholder: "أدخل كلمة المرور",
        loginBtn: "دخول",
        loginError: "بيانات الدخول غير صحيحة",
        studyBy: "الدراسة مقدمة من:",
        changeLanguage: "تغيير اللغة",

        // Oath Screen
        oathTitle: "إقرار السرية والأمانة",
        oathSubtitle: "يجب الموافقة على الشروط للمتابعة",
        oathContent: `<p class="oath-intro"><strong>أقسم بالله العظيم</strong> أنني:</p>
            <ul class="oath-list">
                <li>لن أفشي أي معلومات من هذه الدراسة لأي طرف ثالث</li>
                <li>لن أشارك رابط هذا الموقع مع أي شخص بدون إذن كتابي</li>
                <li>لن أنسخ أو أصور أي محتوى بدون إذن مسبق</li>
                <li>أتعهد بالحفاظ على سرية جميع البيانات والتحليلات</li>
                <li>أفهم أن أي مخالفة تُعرّضني للمساءلة القانونية</li>
            </ul>`,
        authorizedTitle: "المخولون بمنح الإذن:",
        agreeOath: "أقسم بالله العظيم أنني قرأت وفهمت وأوافق على جميع الشروط أعلاه",
        proceedBtn: "المتابعة إلى المنصة",

        // Dashboard Navigation
        navFeatures: "مميزات المنصة",
        navHosting: "تكاليف الاستضافة",
        navCompetitor: "تحليل المنافسين",
        logout: "خروج",

        // Features Page
        featuresTitle: "⭐ مميزات منصة بقالة الحي",
        featuresSubtitle: "7 تطبيقات متكاملة لإدارة البقالات الذكية",
        apps: "تطبيقات",
        screens: "شاشة",
        languages: "لغات",
        distributors: "موزع",
        allApps: "التطبيقات السبعة",
        adminPosDesc: "إدارة كاملة للمتجر + B2B",
        adminLiteDesc: "وصول سريع + AI إعادة الطلب",
        posDesc: "نقطة البيع + Split Payment",
        customerDesc: "طلب البقالة أونلاين",
        driverDesc: "إدارة التوصيل والطرود",
        distributorDesc: "B2B marketplace للموزعين",
        superDesc: "التحكم الكامل بالمنصة",
        uniqueFeatures: "المميزات الفريدة",
        aiTitle: "الذكاء الاصطناعي",
        ai1: "اقتراحات المنتجات الذكية",
        ai2: "تنبيهات المنتجات الراكدة",
        ai3: "طلب ذكي حسب الميزانية",
        ai4: "توقع المخزون المطلوب",
        ocrTitle: "OCR الفواتير",
        ocr1: "رفع صورة الفاتورة",
        ocr2: "استخراج تلقائي للبيانات",
        ocr3: "30 ثانية بدل 30 دقيقة",
        ocr4: "إدخال مباشر للمستودع",
        b2bTitle: "B2B الموزعين",
        b2b1: "15 موزع نشط",
        b2b2: "تكامل مع POS",
        b2b3: "طلب بضغطة واحدة",
        b2b4: "عروض الهايبر الكبيرة",
        paymentTitle: "Split Payment",
        pay1: "دفع بأكثر من طريقة",
        pay2: "نقد + بطاقة + دين",
        pay3: "ربط مدى دايركت",
        pay4: "طباعة تلقائية",
        whatsappTitle: "واتساب ذكي",
        wa1: "إرسال العروض تلقائياً",
        wa2: "تذكير الديون",
        wa3: "إشعارات الطلبات",
        wa4: "رسائل غير محدودة",
        chainsTitle: "إدارة السلاسل",
        ch1: "نقل المنتجات بين الفروع",
        ch2: "مقارنات ذكية",
        ch3: "تقارير كل فرع",
        ch4: "قرارات مبنية على البيانات",
        b2bFlowTitle: "تدفق العمل B2B",
        flowStep1: "الموزع يعرض العرض",
        flowStep2: "يصل لـ POS تلقائياً",
        flowStep3: "الدفع أونلاين/كاش",
        flowStep4: "ضغطة زر واحدة",
        flowStep5: "المراجعة والموافقة",
        flowStep6: "دخول المستودع",

        // Hosting Page
        hostingTitle: "💰 دراسة تكاليف الاستضافة والخدمات السحابية",
        smallLevel: "المستوى الصغير",
        mediumLevel: "المستوى المتوسط",
        largeLevel: "المستوى الكبير",
        targetLevel: "المستهدف",
        assumptions: "🏪 افتراضات السيناريو",
        costBreakdown: "💰 تفصيل التكاليف الشهرية",
        costTable: "📋 جدول التكاليف",
        service: "الخدمة",
        monthlyCost: "التكلفة الشهرية",
        percentage: "النسبة",
        periodCosts: "📅 التكاليف حسب الفترة",
        monthly: "شهري",
        semiAnnual: "نصف سنوي",
        annual: "سنوي",
        roi: "💰 العائد على الاستثمار (ROI)",
        infrastructureCost: "تكلفة البنية التحتية",
        revenue: "إيرادات الاشتراكات (299 × 100)",
        profitMargin: "هامش الربح",

        // Competitor Page
        competitorTitle: "📊 تحليل المنافسين ودراسة الأسعار",
        keyFinding: "النتيجة الرئيسية",
        keyFindingText: "لا يوجد منافس واحد في السعودية يقدم OCR + AI + B2B معاً!",
        competitorPricing: "💵 أسعار المنافسين",
        competitor: "المنافس",
        monthlyPrice: "السعر الشهري",
        featureComparison: "📈 مقارنة الميزات",
        proposedPricing: "💰 الباقات المقترحة",
        basicPlan: "الباقة الأساسية",
        proPlan: "الباقة الاحترافية",
        chainsPlan: "باقة السلاسل",
        popular: "الأكثر طلباً",
        customerRoi: "📈 العائد للعميل (ROI)",
        pays: "يدفع شهرياً",
        saves: "يوفر شهرياً",

        // Financial Page
        navFinancial: "الجدوى المالية",
        financialTitle: "📈 دراسة الجدوى المالية وتوقعات الأرباح",
        investmentRequired: "الاستثمار المطلوب",
        developmentPeriod: "فترة التطوير: 4 أشهر",
        investmentBreakdown: "📋 توزيع الاستثمار",
        development: "التطوير البرمجي",
        design: "التصميم والـ UX",
        reserve: "احتياطي طوارئ",
        breakEvenTitle: "🎯 نقطة التعادل (Break-Even)",
        optimistic: "متفائل",
        moderate: "متوسط",
        pessimistic: "غير متفائل",
        mostLikely: "الأرجح",
        month: "الشهر",
        stores: "بقالة",
        storesPerMonth: "بقالة/شهر",
        breakEvenChart: "📊 رسم بياني لنقطة التعادل",
        profitProjections: "💰 توقعات الأرباح (السيناريو المتوسط)",
        year: "السنة",
        storesCount: "البقالات",
        annualRevenue: "الإيرادات السنوية",
        netProfit: "صافي الربح",
        cumulativeProfit: "الربح التراكمي",
        year1: "السنة 1",
        year2: "السنة 2",
        year3: "السنة 3",
        projectOwners: "👥 أصحاب المشروع",
        roiSummary: "🚀 ملخص للمستثمر",
        investmentLabel: "الاستثمار",
        devPeriod: "فترة التطوير",
        breakEvenLabel: "نقطة التعادل",
        year1Profit: "ربح السنة الأولى",
        year3Profit: "ربح 3 سنوات",
        months: "أشهر",
        years: "سنوات",
        competitiveAdvantage: "الميزة التنافسية",
        noCompetitor: "لا يوجد منافس مباشر في السعودية يقدم OCR + AI + B2B معاً!",

        // Footer
        footerText: "الدراسة مقدمة من <strong>باسم محمد الحجري</strong> و <strong>عبدالحافظ محمد على المغربي</strong> - جميع الحقوق محفوظة © 2026"
    },

    en: {
        loginWelcome: "Welcome to the Project Analysis Platform",
        loginWelcomeDesc: "Access exclusive studies and analyses",
        feature1: "Hosting Cost Study",
        feature2: "Competitor Analysis",
        feature3: "Proposed Pricing Plans",
        feature4: "Complete Platform Features",
        loginTitle: "Login",
        loginSubtitle: "Enter your credentials to access the study",
        username: "Username",
        password: "Password",
        usernamePlaceholder: "Enter username",
        passwordPlaceholder: "Enter password",
        loginBtn: "Login",
        loginError: "Invalid credentials",
        studyBy: "Study provided by:",
        changeLanguage: "Change Language",
        oathTitle: "Confidentiality & Trust Agreement",
        oathSubtitle: "You must agree to the terms to continue",
        oathContent: `<p class="oath-intro"><strong>I solemnly swear</strong> that:</p>
            <ul class="oath-list">
                <li>I will not disclose any information from this study to any third party</li>
                <li>I will not share this website link with anyone without written permission</li>
                <li>I will not copy or screenshot any content without prior permission</li>
                <li>I commit to maintaining the confidentiality of all data and analyses</li>
                <li>I understand that any violation will subject me to legal accountability</li>
            </ul>`,
        authorizedTitle: "Authorized to Grant Permission:",
        agreeOath: "I solemnly swear that I have read, understood, and agree to all the above terms",
        proceedBtn: "Proceed to Platform",
        navFeatures: "Platform Features",
        navHosting: "Hosting Costs",
        navCompetitor: "Competitor Analysis",
        logout: "Logout",
        featuresTitle: "⭐ Alhai Platform Features",
        featuresSubtitle: "7 integrated applications for smart grocery management",
        apps: "Applications",
        screens: "Screens",
        languages: "Languages",
        distributors: "Distributors",
        allApps: "All 7 Applications",
        adminPosDesc: "Complete store management + B2B",
        adminLiteDesc: "Quick access + AI reordering",
        posDesc: "Point of Sale + Split Payment",
        customerDesc: "Online grocery ordering",
        driverDesc: "Delivery and package management",
        distributorDesc: "B2B marketplace for distributors",
        superDesc: "Complete platform control",
        uniqueFeatures: "Unique Features",
        aiTitle: "Artificial Intelligence",
        ai1: "Smart product suggestions",
        ai2: "Stale product alerts",
        ai3: "Smart ordering by budget",
        ai4: "Inventory prediction",
        ocrTitle: "Invoice OCR",
        ocr1: "Upload invoice photo",
        ocr2: "Automatic data extraction",
        ocr3: "30 seconds instead of 30 minutes",
        ocr4: "Direct warehouse entry",
        b2bTitle: "B2B Distributors",
        b2b1: "15 active distributors",
        b2b2: "POS integration",
        b2b3: "One-click ordering",
        b2b4: "Hypermarket offers",
        paymentTitle: "Split Payment",
        pay1: "Pay with multiple methods",
        pay2: "Cash + Card + Credit",
        pay3: "Mada Direct integration",
        pay4: "Automatic printing",
        whatsappTitle: "Smart WhatsApp",
        wa1: "Automatic offer sending",
        wa2: "Debt reminders",
        wa3: "Order notifications",
        wa4: "Unlimited messages",
        chainsTitle: "Chain Management",
        ch1: "Product transfer between branches",
        ch2: "Smart comparisons",
        ch3: "Branch reports",
        ch4: "Data-driven decisions",
        b2bFlowTitle: "B2B Workflow",
        flowStep1: "Distributor posts offer",
        flowStep2: "Arrives at POS automatically",
        flowStep3: "Payment online/cash",
        flowStep4: "One-click order",
        flowStep5: "Review and approve",
        flowStep6: "Warehouse entry",
        hostingTitle: "💰 Hosting & Cloud Services Cost Study",
        smallLevel: "Small Level",
        mediumLevel: "Medium Level",
        largeLevel: "Large Level",
        targetLevel: "Target",
        assumptions: "🏪 Scenario Assumptions",
        costBreakdown: "💰 Monthly Cost Breakdown",
        costTable: "📋 Cost Table",
        service: "Service",
        monthlyCost: "Monthly Cost",
        percentage: "Percentage",
        periodCosts: "📅 Costs by Period",
        monthly: "Monthly",
        semiAnnual: "Semi-Annual",
        annual: "Annual",
        roi: "💰 Return on Investment (ROI)",
        infrastructureCost: "Infrastructure Cost",
        revenue: "Subscription Revenue (299 × 100)",
        profitMargin: "Profit Margin",
        competitorTitle: "📊 Competitor Analysis & Pricing Study",
        keyFinding: "Key Finding",
        keyFindingText: "No competitor in Saudi Arabia offers OCR + AI + B2B together!",
        competitorPricing: "💵 Competitor Pricing",
        competitor: "Competitor",
        monthlyPrice: "Monthly Price",
        featureComparison: "📈 Feature Comparison",
        proposedPricing: "💰 Proposed Packages",
        basicPlan: "Basic Plan",
        proPlan: "Professional Plan",
        chainsPlan: "Chains Plan",
        popular: "Most Popular",
        customerRoi: "📈 Customer ROI",
        pays: "Pays Monthly",
        saves: "Saves Monthly",

        // Financial Page
        navFinancial: "Financial Study",
        financialTitle: "📈 Financial Feasibility & Profit Projections",
        investmentRequired: "Investment Required",
        developmentPeriod: "Development Period: 4 months",
        investmentBreakdown: "📋 Investment Breakdown",
        development: "Software Development",
        design: "Design & UX",
        reserve: "Emergency Reserve",
        breakEvenTitle: "🎯 Break-Even Point",
        optimistic: "Optimistic",
        moderate: "Moderate",
        pessimistic: "Pessimistic",
        mostLikely: "Most Likely",
        month: "Month",
        stores: "stores",
        storesPerMonth: "stores/month",
        breakEvenChart: "📊 Break-Even Chart",
        profitProjections: "💰 Profit Projections (Moderate Scenario)",
        year: "Year",
        storesCount: "Stores",
        annualRevenue: "Annual Revenue",
        netProfit: "Net Profit",
        cumulativeProfit: "Cumulative Profit",
        year1: "Year 1",
        year2: "Year 2",
        year3: "Year 3",
        projectOwners: "👥 Project Owners",
        roiSummary: "🚀 Investor Summary",
        investmentLabel: "Investment",
        devPeriod: "Development Period",
        breakEvenLabel: "Break-Even",
        year1Profit: "Year 1 Profit",
        year3Profit: "3 Years Profit",
        months: "months",
        years: "years",
        competitiveAdvantage: "Competitive Advantage",
        noCompetitor: "No direct competitor in Saudi Arabia offers OCR + AI + B2B together!",

        footerText: "Study provided by <strong>Basem Mohammed Alhajri</strong> & <strong>Abdulhafiz Mohammed Ali Almaghribi</strong> - All Rights Reserved © 2026"
    },

    ur: {
        loginWelcome: "پروجیکٹ تجزیہ پلیٹ فارم میں خوش آمدید",
        loginWelcomeDesc: "خصوصی مطالعات اور تجزیوں تک رسائی",
        loginTitle: "لاگ ان",
        loginSubtitle: "مطالعے تک رسائی کے لیے اپنی تفصیلات درج کریں",
        username: "صارف نام",
        password: "پاس ورڈ",
        loginBtn: "داخل ہوں",
        loginError: "غلط تفصیلات",
        changeLanguage: "زبان تبدیل کریں",
        oathTitle: "رازداری اور امانت کا عہد",
        oathSubtitle: "جاری رکھنے کے لیے شرائط سے اتفاق کرنا ضروری ہے",
        oathContent: `<p class="oath-intro"><strong>میں اللہ کی قسم کھاتا/کھاتی ہوں</strong> کہ:</p>
            <ul class="oath-list">
                <li>اس مطالعے کی کوئی معلومات کسی تیسرے فریق کو ظاہر نہیں کروں گا</li>
                <li>تحریری اجازت کے بغیر یہ لنک کسی کے ساتھ شیئر نہیں کروں گا</li>
                <li>بغیر اجازت کوئی مواد کاپی یا اسکرین شاٹ نہیں لوں گا</li>
                <li>تمام ڈیٹا کی رازداری کو برقرار رکھوں گا</li>
                <li>سمجھتا ہوں کہ خلاف ورزی قانونی جوابدہی کا سبب بنے گی</li>
            </ul>`,
        agreeOath: "میں اللہ کی قسم کھاتا ہوں کہ میں نے تمام شرائط پڑھ لی ہیں اور متفق ہوں",
        proceedBtn: "پلیٹ فارم پر جائیں",
        navFeatures: "پلیٹ فارم کی خصوصیات",
        navHosting: "ہوسٹنگ اخراجات",
        navCompetitor: "مقابلہ تجزیہ",
        logout: "لاگ آؤٹ",
        footerText: "مطالعہ پیش کردہ <strong>باسم محمد الحجری</strong> - تمام حقوق محفوظ © 2026"
    },

    hi: {
        loginWelcome: "प्रोजेक्ट विश्लेषण प्लेटफॉर्म में आपका स्वागत है",
        loginWelcomeDesc: "विशेष अध्ययन और विश्लेषण तक पहुंच",
        loginTitle: "लॉगिन",
        loginSubtitle: "अध्ययन तक पहुंचने के लिए अपना विवरण दर्ज करें",
        username: "उपयोगकर्ता नाम",
        password: "पासवर्ड",
        loginBtn: "प्रवेश करें",
        loginError: "गलत विवरण",
        changeLanguage: "भाषा बदलें",
        oathTitle: "गोपनीयता और विश्वास समझौता",
        oathSubtitle: "जारी रखने के लिए शर्तों से सहमत होना होगा",
        oathContent: `<p class="oath-intro"><strong>मैं अल्लाह की कसम खाता/खाती हूं</strong> कि:</p>
            <ul class="oath-list">
                <li>इस अध्ययन की कोई जानकारी किसी तीसरे पक्ष को नहीं बताऊंगा</li>
                <li>लिखित अनुमति के बिना यह लिंक किसी के साथ साझा नहीं करूंगा</li>
                <li>बिना अनुमति कोई सामग्री कॉपी या स्क्रीनशॉट नहीं लूंगा</li>
                <li>सभी डेटा की गोपनीयता बनाए रखूंगा</li>
                <li>समझता हूं कि उल्लंघन कानूनी जवाबदेही का कारण बनेगा</li>
            </ul>`,
        agreeOath: "मैं कसम खाता हूं कि मैंने सभी शर्तें पढ़ ली हैं और सहमत हूं",
        proceedBtn: "प्लेटफॉर्म पर जाएं",
        navFeatures: "प्लेटफॉर्म सुविधाएं",
        navHosting: "होस्टिंग लागत",
        navCompetitor: "प्रतिस्पर्धी विश्लेषण",
        logout: "लॉगआउट",
        footerText: "अध्ययन प्रस्तुतकर्ता <strong>बासिम मोहम्मद अलहजरी</strong> - सर्वाधिकार सुरक्षित © 2026"
    },

    bn: {
        loginWelcome: "প্রকল্প বিশ্লেষণ প্ল্যাটফর্মে স্বাগতম",
        loginWelcomeDesc: "বিশেষ অধ্যয়ন এবং বিশ্লেষণে প্রবেশ",
        loginTitle: "লগইন",
        loginSubtitle: "অধ্যয়নে প্রবেশ করতে আপনার তথ্য প্রদান করুন",
        username: "ব্যবহারকারীর নাম",
        password: "পাসওয়ার্ড",
        loginBtn: "প্রবেশ করুন",
        loginError: "ভুল তথ্য",
        changeLanguage: "ভাষা পরিবর্তন করুন",
        oathTitle: "গোপনীয়তা ও বিশ্বস্ততার অঙ্গীকার",
        oathSubtitle: "চালিয়ে যেতে শর্তাবলীতে সম্মত হতে হবে",
        oathContent: `<p class="oath-intro"><strong>আমি আল্লাহর নামে শপথ করছি</strong> যে:</p>
            <ul class="oath-list">
                <li>এই অধ্যয়নের কোনো তথ্য কোনো তৃতীয় পক্ষের কাছে প্রকাশ করব না</li>
                <li>লিখিত অনুমতি ছাড়া এই লিংক কারো সাথে শেয়ার করব না</li>
                <li>অনুমতি ছাড়া কোনো বিষয়বস্তু কপি বা স্ক্রিনশট নেব না</li>
                <li>সমস্ত ডেটার গোপনীয়তা বজায় রাখব</li>
                <li>বুঝি যে লঙ্ঘন আইনি জবাবদিহিতার কারণ হবে</li>
            </ul>`,
        agreeOath: "আমি শপথ করছি যে আমি সমস্ত শর্তাবলী পড়েছি এবং সম্মত আছি",
        proceedBtn: "প্ল্যাটফর্মে যান",
        navFeatures: "প্ল্যাটফর্ম বৈশিষ্ট্য",
        navHosting: "হোস্টিং খরচ",
        navCompetitor: "প্রতিযোগী বিশ্লেষণ",
        logout: "লগআউট",
        footerText: "অধ্যয়ন উপস্থাপনকারী <strong>বাসিম মোহাম্মদ আলহাজরি</strong> - সর্বস্বত্ব সংরক্ষিত © 2026"
    },

    id: {
        loginWelcome: "Selamat datang di Platform Analisis Proyek",
        loginWelcomeDesc: "Akses studi dan analisis eksklusif",
        loginTitle: "Masuk",
        loginSubtitle: "Masukkan kredensial Anda untuk mengakses studi",
        username: "Nama Pengguna",
        password: "Kata Sandi",
        loginBtn: "Masuk",
        loginError: "Kredensial tidak valid",
        changeLanguage: "Ubah Bahasa",
        oathTitle: "Perjanjian Kerahasiaan & Kepercayaan",
        oathSubtitle: "Anda harus menyetujui persyaratan untuk melanjutkan",
        oathContent: `<p class="oath-intro"><strong>Saya bersumpah demi Allah</strong> bahwa:</p>
            <ul class="oath-list">
                <li>Tidak akan mengungkapkan informasi apapun dari studi ini kepada pihak ketiga</li>
                <li>Tidak akan membagikan tautan ini kepada siapapun tanpa izin tertulis</li>
                <li>Tidak akan menyalin atau screenshot konten apapun tanpa izin</li>
                <li>Akan menjaga kerahasiaan semua data</li>
                <li>Memahami bahwa pelanggaran akan dikenakan tanggung jawab hukum</li>
            </ul>`,
        agreeOath: "Saya bersumpah bahwa saya telah membaca semua persyaratan dan menyetujui",
        proceedBtn: "Lanjutkan ke Platform",
        navFeatures: "Fitur Platform",
        navHosting: "Biaya Hosting",
        navCompetitor: "Analisis Pesaing",
        logout: "Keluar",
        footerText: "Studi disediakan oleh <strong>Basem Mohammed Alhajri</strong> - Hak Cipta Dilindungi © 2026"
    }
};

// ===========================================
// APP STATE
// ===========================================
let currentLang = 'ar';
let currentTheme = 'light';
let isAuthenticated = false;

// Credentials
const VALID_USERNAME = '0558048004';
const VALID_PASSWORD = 'Zxcvb123asd@';

// ===========================================
// DOM ELEMENTS
// ===========================================
const screens = {
    splash: document.getElementById('splash-screen'),
    language: document.getElementById('language-screen'),
    login: document.getElementById('login-screen'),
    oath: document.getElementById('oath-screen'),
    presentation: document.getElementById('presentation-screen'),
    dashboard: document.getElementById('dashboard-screen')
};

// ===========================================
// UTILITY FUNCTIONS
// ===========================================

function showScreen(screenName) {
    // Hide all screens
    Object.values(screens).forEach(screen => {
        if (screen) screen.classList.remove('active');
    });

    // Show target screen
    if (screens[screenName]) {
        screens[screenName].classList.add('active');
    }
}

function setLanguage(lang) {
    currentLang = lang;

    // Set direction
    const rtlLangs = ['ar', 'ur'];
    const dir = rtlLangs.includes(lang) ? 'rtl' : 'ltr';
    document.documentElement.setAttribute('dir', dir);
    document.documentElement.setAttribute('lang', lang);

    // Update all translatable elements
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (translations[lang] && translations[lang][key]) {
            el.innerHTML = translations[lang][key];
        } else if (translations.en && translations.en[key]) {
            // Fallback to English
            el.innerHTML = translations.en[key];
        }
    });

    // Update placeholders
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
        const key = el.getAttribute('data-i18n-placeholder');
        if (translations[lang] && translations[lang][key]) {
            el.placeholder = translations[lang][key];
        } else if (translations.en && translations.en[key]) {
            el.placeholder = translations.en[key];
        }
    });
}

function setTheme(theme) {
    currentTheme = theme;
    document.documentElement.setAttribute('data-theme', theme);

    const themeBtn = document.getElementById('theme-toggle');
    if (themeBtn) {
        themeBtn.querySelector('span').textContent = theme === 'dark' ? '☀️' : '🌙';
    }

    // Re-init charts if authenticated
    if (isAuthenticated) {
        setTimeout(initCharts, 100);
    }
}

// ===========================================
// SCREEN 1: SPLASH - Auto transition after 3 seconds
// ===========================================
document.addEventListener('DOMContentLoaded', () => {
    // Show splash first
    showScreen('splash');

    // Auto transition to language screen after 3 seconds
    setTimeout(() => {
        showScreen('language');
    }, 3000);
});

// ===========================================
// SCREEN 2: LANGUAGE SELECTION
// ===========================================
document.querySelectorAll('.lang-card').forEach(card => {
    card.addEventListener('click', () => {
        const lang = card.getAttribute('data-lang');
        setLanguage(lang);
        showScreen('login');
    });
});

// ===========================================
// SCREEN 3: LOGIN
// ===========================================
const loginForm = document.getElementById('login-form');
const loginError = document.getElementById('login-error');
const togglePasswordBtn = document.getElementById('toggle-password');
const passwordInput = document.getElementById('password');
const backToLanguageBtn = document.getElementById('back-to-language');

if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
        e.preventDefault();

        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        if (username === VALID_USERNAME && password === VALID_PASSWORD) {
            loginError.style.display = 'none';
            showScreen('oath');
        } else {
            loginError.style.display = 'flex';
        }
    });
}

if (togglePasswordBtn && passwordInput) {
    togglePasswordBtn.addEventListener('click', () => {
        const type = passwordInput.type === 'password' ? 'text' : 'password';
        passwordInput.type = type;
        togglePasswordBtn.textContent = type === 'password' ? '👁️' : '🙈';
    });
}

if (backToLanguageBtn) {
    backToLanguageBtn.addEventListener('click', () => {
        showScreen('language');
    });
}

// ===========================================
// SCREEN 4: OATH
// ===========================================
const oathCheckbox = document.getElementById('oath-checkbox');
const proceedBtn = document.getElementById('proceed-btn');

if (oathCheckbox && proceedBtn) {
    oathCheckbox.addEventListener('change', () => {
        proceedBtn.disabled = !oathCheckbox.checked;
    });

    proceedBtn.addEventListener('click', () => {
        if (oathCheckbox.checked) {
            showScreen('presentation');
        }
    });
}

// ===========================================
// SCREEN 5: PRESENTATION
// ===========================================

// Skip presentation button
const skipPresBtn = document.getElementById('skip-pres-btn');
if (skipPresBtn) {
    skipPresBtn.addEventListener('click', () => {
        isAuthenticated = true;
        showScreen('dashboard');
        initCharts();
    });
}

// Continue to dashboard button
const continueBtn = document.getElementById('continue-btn');
if (continueBtn) {
    continueBtn.addEventListener('click', () => {
        isAuthenticated = true;
        showScreen('dashboard');
        initCharts();
    });
}

// Scroll progress bar for presentation
const presContent = document.querySelector('.pres-content');
const progressBar = document.getElementById('pres-progress-bar');

if (presContent && progressBar) {
    window.addEventListener('scroll', () => {
        const presScreen = document.getElementById('presentation-screen');
        if (presScreen && presScreen.classList.contains('active')) {
            const scrollTop = window.scrollY;
            const fullHeight = document.documentElement.scrollHeight - window.innerHeight;
            const progress = (scrollTop / fullHeight) * 100;
            progressBar.style.width = Math.min(progress, 100) + '%';
        }
    });
}

// ===========================================
// SCREEN 6: DASHBOARD
// ===========================================

// Navigation Tabs
document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.addEventListener('click', () => {
        const page = tab.getAttribute('data-page');

        // Update tabs
        document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');

        // Update pages
        document.querySelectorAll('.dash-page').forEach(p => p.classList.remove('active'));
        const targetPage = document.getElementById(`${page}-page`);
        if (targetPage) targetPage.classList.add('active');

        // Re-init charts when switching pages (needed for proper rendering)
        setTimeout(() => {
            initCharts();
        }, 100);
    });
});

// Theme Toggle
const themeToggle = document.getElementById('theme-toggle');
if (themeToggle) {
    themeToggle.addEventListener('click', () => {
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        setTheme(newTheme);
    });
}

// Language Dropdown
const langToggle = document.getElementById('lang-toggle');
const langDropdown = document.getElementById('lang-dropdown');

if (langToggle && langDropdown) {
    langToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        langDropdown.classList.toggle('show');
    });

    document.addEventListener('click', () => {
        langDropdown.classList.remove('show');
    });

    langDropdown.querySelectorAll('button').forEach(btn => {
        btn.addEventListener('click', () => {
            const lang = btn.getAttribute('data-lang');
            setLanguage(lang);
            langDropdown.classList.remove('show');
        });
    });
}

// Logout
const logoutBtn = document.getElementById('logout-btn');
if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
        isAuthenticated = false;

        // Reset form
        if (document.getElementById('username')) document.getElementById('username').value = '';
        if (document.getElementById('password')) document.getElementById('password').value = '';
        if (oathCheckbox) oathCheckbox.checked = false;
        if (proceedBtn) proceedBtn.disabled = true;
        if (loginError) loginError.style.display = 'none';

        // Go back to splash
        showScreen('splash');

        // Auto transition to language after 3 seconds
        setTimeout(() => {
            showScreen('language');
        }, 3000);
    });
}

// ===========================================
// CHARTS
// ===========================================
let costPieChart, radarChart;

function initCharts() {
    const isDark = currentTheme === 'dark';
    const textColor = isDark ? '#f1f5f9' : '#1e293b';
    const gridColor = isDark ? '#334155' : '#e2e8f0';

    Chart.defaults.color = textColor;
    Chart.defaults.borderColor = gridColor;

    // Cost Pie Chart
    const costPieCtx = document.getElementById('costPieChart');
    if (costPieCtx) {
        if (costPieChart) costPieChart.destroy();
        costPieChart = new Chart(costPieCtx, {
            type: 'doughnut',
            data: {
                labels: ['WhatsApp', 'Google Maps', 'Supabase', 'OCR', 'Translation', 'Hosting', 'R2 Storage', 'AI'],
                datasets: [{
                    data: [3000, 375, 187, 169, 150, 94, 26, 5],
                    backgroundColor: [
                        '#10b981', '#3b82f6', '#8b5cf6', '#f59e0b',
                        '#ec4899', '#06b6d4', '#84cc16', '#f43f5e'
                    ],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { padding: 15, usePointStyle: true }
                    },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                const pct = ((ctx.parsed / total) * 100).toFixed(1);
                                return `${ctx.label}: ${ctx.parsed} ر.س (${pct}%)`;
                            }
                        }
                    }
                }
            }
        });
    }

    // Radar Chart
    const radarCtx = document.getElementById('radarChart');
    if (radarCtx) {
        if (radarChart) radarChart.destroy();
        radarChart = new Chart(radarCtx, {
            type: 'radar',
            data: {
                labels: ['POS', 'المخزون', 'التقارير', 'AI', 'OCR', 'B2B', 'تطبيقات', 'واتساب'],
                datasets: [{
                    label: 'بقالة الحي',
                    data: [10, 10, 10, 10, 10, 10, 10, 10],
                    backgroundColor: 'rgba(16, 185, 129, 0.2)',
                    borderColor: '#10b981',
                    borderWidth: 3,
                    pointBackgroundColor: '#10b981'
                }, {
                    label: 'المنافسون',
                    data: [8, 7, 7, 0, 0, 0, 2, 0],
                    backgroundColor: 'rgba(239, 68, 68, 0.2)',
                    borderColor: '#ef4444',
                    borderWidth: 2,
                    pointBackgroundColor: '#ef4444'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    r: {
                        beginAtZero: true,
                        max: 10,
                        ticks: { stepSize: 2 }
                    }
                },
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    }

    // Break-Even Chart
    const breakEvenCtx = document.getElementById('breakEvenChart');
    if (breakEvenCtx) {
        if (window.breakEvenChartInstance && typeof window.breakEvenChartInstance.destroy === 'function') {
            window.breakEvenChartInstance.destroy();
        }
        window.breakEvenChartInstance = new Chart(breakEvenCtx, {
            type: 'line',
            data: {
                labels: ['شهر 1', 'شهر 2', 'شهر 3', 'شهر 4', 'شهر 5', 'شهر 6', 'شهر 7', 'شهر 8', 'شهر 9', 'شهر 10', 'شهر 11', 'شهر 12'],
                datasets: [
                    {
                        label: 'متفائل (الربح التراكمي)',
                        data: [2408, 7412, 15012, 25208, 38000, 53388, 71376, 92000, 115000, 140000, 167000, 196000],
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'متوسط (الربح التراكمي)',
                        data: [990, 3158, 6504, 11028, 16730, 23610, 31668, 40904, 51320, 62916, 75692, 89648],
                        borderColor: '#f59e0b',
                        backgroundColor: 'rgba(245, 158, 11, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'غير متفائل (الربح التراكمي)',
                        data: [366, 1286, 2760, 4788, 7369, 10504, 14193, 18436, 23233, 28583, 34493, 40963],
                        borderColor: '#ef4444',
                        backgroundColor: 'rgba(239, 68, 68, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'نقطة التعادل (20,000 ر.س)',
                        data: [20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000],
                        borderColor: '#6366f1',
                        borderWidth: 2,
                        borderDash: [10, 5],
                        fill: false,
                        pointRadius: 0
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { usePointStyle: true }
                    },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString()} ر.س`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: (value) => value.toLocaleString() + ' ر.س'
                        }
                    }
                }
            }
        });
    }
}

// ===========================================
// INITIALIZE
// ===========================================
// Set default language on load
setLanguage('ar');
setTheme('light');
