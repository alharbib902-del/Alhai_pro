"""
Translations for 7 languages: ar, en, ur, hi, bn, fil, id
ترجمات لـ 7 لغات
"""

SUPPORTED_LANGUAGES = ("ar", "en", "ur", "hi", "bn", "fil", "id")
DEFAULT_LANGUAGE = "ar"


def _lang(lang: str) -> str:
    """Normalize and validate language code."""
    lang = (lang or DEFAULT_LANGUAGE).lower().strip()
    return lang if lang in SUPPORTED_LANGUAGES else DEFAULT_LANGUAGE


# ============================================================================
# CURRENCY
# ============================================================================

CURRENCY_SYMBOLS = {
    "ar": "ر.س", "en": "SAR", "ur": "SAR", "hi": "₹",
    "bn": "৳", "fil": "₱", "id": "Rp",
}

def get_currency_symbol(lang: str) -> str:
    return CURRENCY_SYMBOLS.get(_lang(lang), "SAR")


# ============================================================================
# PRODUCT NAMES (used in pricing, inventory, basket, etc.)
# ============================================================================

_PRODUCT_NAMES = {
    "ar": ["حليب طازج", "خبز عربي", "أرز بسمتي", "زيت زيتون", "سكر أبيض", "شاي أحمر", "صابون يد"],
    "en": ["Fresh Milk", "Arabic Bread", "Basmati Rice", "Olive Oil", "White Sugar", "Red Tea", "Hand Soap"],
    "ur": ["تازہ دودھ", "عربی روٹی", "باسمتی چاول", "زیتون کا تیل", "سفید چینی", "سرخ چائے", "ہاتھ صابن"],
    "hi": ["ताज़ा दूध", "अरबी रोटी", "बासमती चावल", "जैतून का तेल", "सफ़ेद चीनी", "लाल चाय", "हैंड सोप"],
    "bn": ["তাজা দুধ", "আরবি রুটি", "বাসমতি চাল", "জলপাই তেল", "সাদা চিনি", "লাল চা", "হ্যান্ড সোপ"],
    "fil": ["Sariwang Gatas", "Arabic Bread", "Basmati Rice", "Olive Oil", "White Sugar", "Red Tea", "Hand Soap"],
    "id": ["Susu Segar", "Roti Arab", "Beras Basmati", "Minyak Zaitun", "Gula Putih", "Teh Merah", "Sabun Tangan"],
}

def get_product_names(lang: str) -> list[str]:
    return _PRODUCT_NAMES.get(_lang(lang), _PRODUCT_NAMES["ar"])


# ============================================================================
# GENERAL TRANSLATIONS DICTIONARY
# ============================================================================

_TRANSLATIONS: dict[str, dict[str, str]] = {
    # --- Trends ---
    "trend_up": {
        "ar": "اتجاه صاعد 📈", "en": "Upward trend 📈", "ur": "اوپر کا رجحان 📈",
        "hi": "ऊपर की ओर रुझान 📈", "bn": "ঊর্ধ্বমুখী প্রবণতা 📈",
        "fil": "Pataas na trend 📈", "id": "Tren naik 📈",
    },
    "trend_down": {
        "ar": "اتجاه هابط 📉", "en": "Downward trend 📉", "ur": "نیچے کا رجحان 📉",
        "hi": "नीचे की ओर रुझान 📉", "bn": "নিম্নমুখী প্রবণতা 📉",
        "fil": "Pababa na trend 📉", "id": "Tren turun 📉",
    },
    "trend_stable": {
        "ar": "مستقر ➡️", "en": "Stable ➡️", "ur": "مستحکم ➡️",
        "hi": "स्थिर ➡️", "bn": "স্থিতিশীল ➡️",
        "fil": "Stable ➡️", "id": "Stabil ➡️",
    },

    # --- Pricing reasons ---
    "pricing_high_demand": {
        "ar": "الطلب مرتفع - يمكن رفع السعر",
        "en": "High demand - price can be increased",
        "ur": "مانگ زیادہ ہے - قیمت بڑھائی جا سکتی ہے",
        "hi": "उच्च मांग - कीमत बढ़ाई जा सकती है",
        "bn": "উচ্চ চাহিদা - মূল্য বাড়ানো যেতে পারে",
        "fil": "Mataas ang demand - pwedeng itaas ang presyo",
        "id": "Permintaan tinggi - harga bisa dinaikkan",
    },
    "pricing_competitor_lower": {
        "ar": "سعر المنافسين أقل - خفض السعر للمنافسة",
        "en": "Competitor price is lower - reduce price to compete",
        "ur": "حریفوں کی قیمت کم ہے - مقابلے کے لیے قیمت کم کریں",
        "hi": "प्रतिस्पर्धी की कीमत कम है - प्रतिस्पर्धा के लिए कम करें",
        "bn": "প্রতিযোগীর দাম কম - প্রতিযোগিতার জন্য কমান",
        "fil": "Mas mababa ang presyo ng competitor - ibaba ang presyo",
        "id": "Harga pesaing lebih rendah - turunkan harga untuk bersaing",
    },
    "pricing_low_elasticity": {
        "ar": "مرونة سعرية منخفضة - السعر الحالي مناسب مع تعديل طفيف",
        "en": "Low price elasticity - current price is suitable with minor adjustment",
        "ur": "قیمت کی لچک کم ہے - موجودہ قیمت معمولی ایڈجسٹمنٹ کے ساتھ مناسب ہے",
        "hi": "कम मूल्य लोच - मौजूदा कीमत मामूली समायोजन के साथ उपयुक्त है",
        "bn": "কম মূল্য স্থিতিস্থাপকতা - সামান্য সমন্বয়ের সাথে বর্তমান মূল্য উপযুক্ত",
        "fil": "Mababang price elasticity - angkop ang kasalukuyang presyo",
        "id": "Elastisitas harga rendah - harga saat ini sesuai dengan penyesuaian kecil",
    },
    "pricing_peak_season": {
        "ar": "موسم ذروة - فرصة لرفع الهامش",
        "en": "Peak season - opportunity to increase margin",
        "ur": "عروج کا موسم - مارجن بڑھانے کا موقع",
        "hi": "चरम सीजन - मार्जिन बढ़ाने का अवसर",
        "bn": "পিক সিজন - মার্জিন বাড়ানোর সুযোগ",
        "fil": "Peak season - pagkakataon na itaas ang margin",
        "id": "Musim puncak - peluang untuk menaikkan margin",
    },

    # --- Fraud reasons ---
    "fraud_high_value": {
        "ar": "عملية بيع بقيمة مرتفعة بشكل غير طبيعي",
        "en": "Abnormally high-value sale transaction",
        "ur": "غیر معمولی طور پر زیادہ قیمت والی فروخت",
        "hi": "असामान्य रूप से उच्च मूल्य की बिक्री",
        "bn": "অস্বাভাবিকভাবে উচ্চ মূল্যের বিক্রয়",
        "fil": "Hindi-normal na mataas na halaga ng benta",
        "id": "Transaksi penjualan bernilai tinggi yang tidak normal",
    },
    "fraud_repeated_discount": {
        "ar": "خصم متكرر من نفس الكاشير خلال ساعة",
        "en": "Repeated discount by same cashier within an hour",
        "ur": "ایک گھنٹے میں ایک ہی کیشیئر سے بار بار ڈسکاؤنٹ",
        "hi": "एक घंटे में एक ही कैशियर द्वारा बार-बार छूट",
        "bn": "এক ঘণ্টার মধ্যে একই ক্যাশিয়ার দ্বারা বারবার ছাড়",
        "fil": "Paulit-ulit na discount mula sa parehong cashier sa loob ng isang oras",
        "id": "Diskon berulang dari kasir yang sama dalam satu jam",
    },
    "fraud_multiple_void": {
        "ar": "إلغاء عمليات متعددة في وقت قصير",
        "en": "Multiple void transactions in a short time",
        "ur": "مختصر وقت میں متعدد لین دین منسوخ",
        "hi": "कम समय में कई लेनदेन रद्द",
        "bn": "অল্প সময়ে একাধিক লেনদেন বাতিল",
        "fil": "Maraming void transactions sa maikling oras",
        "id": "Pembatalan transaksi berulang dalam waktu singkat",
    },
    "fraud_off_hours": {
        "ar": "بيع خارج ساعات العمل المعتادة",
        "en": "Sale outside normal working hours",
        "ur": "عام کام کے اوقات سے باہر فروخت",
        "hi": "सामान्य कार्य समय के बाहर बिक्री",
        "bn": "স্বাভাবিক কাজের সময়ের বাইরে বিক্রয়",
        "fil": "Benta sa labas ng normal na oras ng trabaho",
        "id": "Penjualan di luar jam kerja normal",
    },
    "fraud_abnormal_qty": {
        "ar": "كمية غير طبيعية لمنتج واحد",
        "en": "Abnormal quantity for a single product",
        "ur": "ایک پروڈکٹ کے لیے غیر معمولی مقدار",
        "hi": "एक उत्पाद के लिए असामान्य मात्रा",
        "bn": "একটি পণ্যের জন্য অস্বাভাবিক পরিমাণ",
        "fil": "Hindi-normal na dami para sa isang produkto",
        "id": "Jumlah tidak normal untuk satu produk",
    },
    "fraud_manual_discount": {
        "ar": "استخدام خصم يدوي مرتفع",
        "en": "High manual discount applied",
        "ur": "زیادہ دستی ڈسکاؤنٹ کا استعمال",
        "hi": "उच्च मैनुअल छूट लागू",
        "bn": "উচ্চ ম্যানুয়াল ছাড় প্রয়োগ",
        "fil": "Mataas na manual discount na ginamit",
        "id": "Diskon manual tinggi digunakan",
    },
    "fraud_suspicious_return": {
        "ar": "نمط إرجاع مشبوه - نفس المنتج عدة مرات",
        "en": "Suspicious return pattern - same product multiple times",
        "ur": "مشکوک واپسی کا نمونہ - ایک ہی پروڈکٹ کئی بار",
        "hi": "संदिग्ध वापसी पैटर्न - एक ही उत्पाद कई बार",
        "bn": "সন্দেহজনক রিটার্ন প্যাটার্ন - একই পণ্য একাধিকবার",
        "fil": "Kahina-hinalang return pattern - parehong produkto ng maraming beses",
        "id": "Pola pengembalian mencurigakan - produk sama berkali-kali",
    },

    # --- Fraud patterns ---
    "pattern_high_value": {
        "ar": "قيمة_مرتفعة", "en": "high_value", "ur": "زیادہ_قیمت",
        "hi": "उच्च_मूल्य", "bn": "উচ্চ_মূল্য", "fil": "mataas_halaga", "id": "nilai_tinggi",
    },
    "pattern_repeated_discount": {
        "ar": "خصم_متكرر", "en": "repeated_discount", "ur": "بار_بار_ڈسکاؤنٹ",
        "hi": "बार-बार_छूट", "bn": "বারবার_ছাড়", "fil": "paulit_discount", "id": "diskon_berulang",
    },
    "pattern_multiple_void": {
        "ar": "إلغاء_متعدد", "en": "multiple_void", "ur": "متعدد_منسوخ",
        "hi": "एकाधिक_रद्द", "bn": "একাধিক_বাতিল", "fil": "maraming_void", "id": "void_berulang",
    },
    "pattern_off_hours": {
        "ar": "وقت_غير_معتاد", "en": "off_hours", "ur": "غیر_معمولی_وقت",
        "hi": "असामान्य_समय", "bn": "অস্বাভাবিক_সময়", "fil": "hindi_normal_oras", "id": "luar_jam",
    },
    "pattern_suspicious_qty": {
        "ar": "كمية_مشبوهة", "en": "suspicious_qty", "ur": "مشکوک_مقدار",
        "hi": "संदिग्ध_मात्रा", "bn": "সন্দেহজনক_পরিমাণ", "fil": "kahina_dami", "id": "jumlah_mencurigakan",
    },
    "last_72_hours": {
        "ar": "آخر 72 ساعة", "en": "Last 72 hours", "ur": "گزشتہ 72 گھنٹے",
        "hi": "पिछले 72 घंटे", "bn": "গত ৭২ ঘণ্টা",
        "fil": "Huling 72 oras", "id": "72 jam terakhir",
    },

    # --- Basket analysis ---
    "basket_bread_cheese_milk": {
        "ar": "من يشتري خبز وجبن غالباً يشتري حليب",
        "en": "Those who buy bread and cheese often buy milk",
        "ur": "جو لوگ روٹی اور پنیر خریدتے ہیں وہ اکثر دودھ بھی خریدتے ہیں",
        "hi": "जो रोटी और पनीर खरीदते हैं वे अक्सर दूध भी खरीदते हैं",
        "bn": "যারা রুটি ও পনির কেনেন তারা প্রায়ই দুধও কেনেন",
        "fil": "Ang mga bumibili ng tinapay at keso ay madalas bumili ng gatas",
        "id": "Yang membeli roti dan keju sering membeli susu",
    },
    "basket_rice_oil_spices": {
        "ar": "الأرز يُشترى مع زيت الطبخ والبهارات",
        "en": "Rice is bought with cooking oil and spices",
        "ur": "چاول کھانا پکانے کے تیل اور مسالوں کے ساتھ خریدا جاتا ہے",
        "hi": "चावल खाना पकाने के तेल और मसालों के साथ खरीदा जाता है",
        "bn": "ভাত রান্নার তেল ও মশলার সাথে কেনা হয়",
        "fil": "Ang bigas ay binibili kasama ang cooking oil at pampalasa",
        "id": "Beras dibeli bersama minyak goreng dan bumbu",
    },
    "basket_tea_sugar": {
        "ar": "الشاي والسكر يُشتريان معاً بنسبة عالية",
        "en": "Tea and sugar are frequently bought together",
        "ur": "چائے اور چینی اکثر ایک ساتھ خریدی جاتی ہیں",
        "hi": "चाय और चीनी अक्सर एक साथ खरीदी जाती हैं",
        "bn": "চা ও চিনি প্রায়ই একসাথে কেনা হয়",
        "fil": "Ang tsaa at asukal ay madalas bilhin ng sabay",
        "id": "Teh dan gula sering dibeli bersamaan",
    },
    "basket_diapers_wipes": {
        "ar": "مستلزمات الأطفال تُشترى معاً",
        "en": "Baby supplies are bought together",
        "ur": "بچوں کا سامان ایک ساتھ خریدا جاتا ہے",
        "hi": "बच्चों का सामान एक साथ खरीदा जाता है",
        "bn": "শিশুর সামগ্রী একসাথে কেনা হয়",
        "fil": "Ang baby supplies ay binibili ng sabay-sabay",
        "id": "Perlengkapan bayi dibeli bersamaan",
    },
    "basket_chicken_garlic_onion": {
        "ar": "الدجاج يُشترى مع التوابل الأساسية",
        "en": "Chicken is bought with basic seasonings",
        "ur": "مرغی بنیادی مسالوں کے ساتھ خریدی جاتی ہے",
        "hi": "चिकन बुनियादी मसालों के साथ खरीदा जाता है",
        "bn": "মুরগি মৌলিক মশলার সাথে কেনা হয়",
        "fil": "Ang manok ay binibili kasama ang basic seasonings",
        "id": "Ayam dibeli bersama bumbu dasar",
    },
    "basket_pasta_sauce": {
        "ar": "المعكرونة والصلصة زوج كلاسيكي",
        "en": "Pasta and sauce are a classic pair",
        "ur": "پاستا اور ساس ایک کلاسک جوڑا ہے",
        "hi": "पास्ता और सॉस एक क्लासिक जोड़ी है",
        "bn": "পাস্তা ও সস একটি ক্লাসিক জুটি",
        "fil": "Ang pasta at sauce ay classic na pares",
        "id": "Pasta dan saus adalah pasangan klasik",
    },
    "basket_coffee_cream_sugar": {
        "ar": "القهوة تُشترى مع الكريمة والسكر",
        "en": "Coffee is bought with cream and sugar",
        "ur": "کافی کریم اور چینی کے ساتھ خریدی جاتی ہے",
        "hi": "कॉफी क्रीम और चीनी के साथ खरीदी जाती है",
        "bn": "কফি ক্রিম ও চিনির সাথে কেনা হয়",
        "fil": "Ang kape ay binibili kasama ang cream at asukal",
        "id": "Kopi dibeli bersama krim dan gula",
    },
    "basket_shampoo_conditioner": {
        "ar": "منتجات العناية بالشعر تُشترى معاً",
        "en": "Hair care products are bought together",
        "ur": "بالوں کی دیکھ بھال کی مصنوعات ایک ساتھ خریدی جاتی ہیں",
        "hi": "बालों की देखभाल के उत्पाद एक साथ खरीदे जाते हैं",
        "bn": "চুলের যত্নের পণ্য একসাথে কেনা হয়",
        "fil": "Ang hair care products ay binibili ng sabay-sabay",
        "id": "Produk perawatan rambut dibeli bersamaan",
    },

    # --- Basket product groups ---
    "bread": {"ar": "خبز", "en": "Bread", "ur": "روٹی", "hi": "रोटी", "bn": "রুটি", "fil": "Tinapay", "id": "Roti"},
    "cheese": {"ar": "جبن", "en": "Cheese", "ur": "پنیر", "hi": "पनीर", "bn": "পনির", "fil": "Keso", "id": "Keju"},
    "milk": {"ar": "حليب", "en": "Milk", "ur": "دودھ", "hi": "दूध", "bn": "দুধ", "fil": "Gatas", "id": "Susu"},
    "rice": {"ar": "أرز", "en": "Rice", "ur": "چاول", "hi": "चावल", "bn": "চাল", "fil": "Bigas", "id": "Beras"},
    "cooking_oil": {"ar": "زيت طبخ", "en": "Cooking Oil", "ur": "کھانا پکانے کا تیل", "hi": "खाना पकाने का तेल", "bn": "রান্নার তেল", "fil": "Cooking Oil", "id": "Minyak Goreng"},
    "spices": {"ar": "بهارات", "en": "Spices", "ur": "مسالے", "hi": "मसाले", "bn": "মশলা", "fil": "Pampalasa", "id": "Bumbu"},
    "tea": {"ar": "شاي", "en": "Tea", "ur": "چائے", "hi": "चाय", "bn": "চা", "fil": "Tsaa", "id": "Teh"},
    "sugar": {"ar": "سكر", "en": "Sugar", "ur": "چینی", "hi": "चीनी", "bn": "চিনি", "fil": "Asukal", "id": "Gula"},
    "diapers": {"ar": "حفاضات", "en": "Diapers", "ur": "ڈائپرز", "hi": "डायपर", "bn": "ডায়াপার", "fil": "Diapers", "id": "Popok"},
    "wet_wipes": {"ar": "مناديل مبللة", "en": "Wet Wipes", "ur": "گیلے وائپس", "hi": "वेट वाइप्स", "bn": "ওয়েট ওয়াইপস", "fil": "Wet Wipes", "id": "Tisu Basah"},
    "chicken": {"ar": "دجاج", "en": "Chicken", "ur": "مرغی", "hi": "चिकन", "bn": "মুরগি", "fil": "Manok", "id": "Ayam"},
    "garlic": {"ar": "ثوم", "en": "Garlic", "ur": "لہسن", "hi": "लहसुन", "bn": "রসুন", "fil": "Bawang", "id": "Bawang Putih"},
    "onion": {"ar": "بصل", "en": "Onion", "ur": "پیاز", "hi": "प्याज़", "bn": "পেঁয়াজ", "fil": "Sibuyas", "id": "Bawang Merah"},
    "pasta": {"ar": "معكرونة", "en": "Pasta", "ur": "پاستا", "hi": "पास्ता", "bn": "পাস্তা", "fil": "Pasta", "id": "Pasta"},
    "tomato_sauce": {"ar": "صلصة طماطم", "en": "Tomato Sauce", "ur": "ٹماٹر کی چٹنی", "hi": "टमाटर सॉस", "bn": "টমেটো সস", "fil": "Tomato Sauce", "id": "Saus Tomat"},
    "coffee": {"ar": "قهوة", "en": "Coffee", "ur": "کافی", "hi": "कॉफी", "bn": "কফি", "fil": "Kape", "id": "Kopi"},
    "cream": {"ar": "كريمة", "en": "Cream", "ur": "کریم", "hi": "क्रीम", "bn": "ক্রিম", "fil": "Cream", "id": "Krim"},
    "shampoo": {"ar": "شامبو", "en": "Shampoo", "ur": "شیمپو", "hi": "शैम्पू", "bn": "শ্যাম্পু", "fil": "Shampoo", "id": "Sampo"},
    "conditioner": {"ar": "بلسم", "en": "Conditioner", "ur": "کنڈیشنر", "hi": "कंडीशनर", "bn": "কন্ডিশনার", "fil": "Conditioner", "id": "Kondisioner"},
    "biscuit": {"ar": "بسكويت", "en": "Biscuit", "ur": "بسکٹ", "hi": "बिस्कुट", "bn": "বিস্কুট", "fil": "Biscuit", "id": "Biskuit"},
    "oil": {"ar": "زيت", "en": "Oil", "ur": "تیل", "hi": "तेल", "bn": "তেল", "fil": "Langis", "id": "Minyak"},

    # --- Basket summary ---
    "top_product_bread": {
        "ar": "خبز عربي", "en": "Arabic Bread", "ur": "عربی روٹی", "hi": "अरबी रोटी",
        "bn": "আরবি রুটি", "fil": "Arabic Bread", "id": "Roti Arab",
    },
    "cross_sell_cheese_bread": {
        "ar": "إضافة رف الجبن بجانب الخبز سيزيد المبيعات ~15%",
        "en": "Placing cheese shelf next to bread will increase sales ~15%",
        "ur": "روٹی کے ساتھ پنیر کا شیلف رکھنے سے فروخت ~15% بڑھے گی",
        "hi": "रोटी के बगल में पनीर शेल्फ रखने से बिक्री ~15% बढ़ेगी",
        "bn": "রুটির পাশে পনিরের তাক রাখলে বিক্রি ~১৫% বাড়বে",
        "fil": "Ang paglagay ng cheese shelf sa tabi ng bread ay magpapataas ng benta ~15%",
        "id": "Menempatkan rak keju di samping roti akan meningkatkan penjualan ~15%",
    },

    # --- Inventory reasons ---
    "inv_critical_low": {
        "ar": "مخزون منخفض جداً - خطر نفاد خلال {days} أيام",
        "en": "Very low stock - risk of running out in {days} days",
        "ur": "اسٹاک بہت کم ہے - {days} دنوں میں ختم ہونے کا خطرہ",
        "hi": "बहुत कम स्टॉक - {days} दिनों में खत्म होने का खतरा",
        "bn": "খুব কম স্টক - {days} দিনে শেষ হওয়ার ঝুঁকি",
        "fil": "Napakababang stock - panganib na maubusan sa {days} araw",
        "id": "Stok sangat rendah - risiko habis dalam {days} hari",
    },
    "inv_reorder_now": {
        "ar": "يجب إعادة الطلب فوراً",
        "en": "Must reorder immediately",
        "ur": "فوری طور پر دوبارہ آرڈر کریں",
        "hi": "तुरंत दोबारा ऑर्डर करें",
        "bn": "অবিলম্বে পুনরায় অর্ডার করুন",
        "fil": "Kailangan mag-reorder agad",
        "id": "Harus segera memesan ulang",
    },
    "inv_sufficient_2weeks": {
        "ar": "مخزون كافٍ لأسبوعين",
        "en": "Sufficient stock for two weeks",
        "ur": "دو ہفتوں کے لیے کافی اسٹاک",
        "hi": "दो सप्ताह के लिए पर्याप्त स्टॉक",
        "bn": "দুই সপ্তাহের জন্য পর্যাপ্ত স্টক",
        "fil": "Sapat na stock para sa dalawang linggo",
        "id": "Stok cukup untuk dua minggu",
    },
    "inv_low_reorder_week": {
        "ar": "مخزون منخفض - أعد الطلب هذا الأسبوع",
        "en": "Low stock - reorder this week",
        "ur": "اسٹاک کم ہے - اس ہفتے دوبارہ آرڈر کریں",
        "hi": "कम स्टॉक - इस हफ्ते दोबारा ऑर्डर करें",
        "bn": "কম স্টক - এই সপ্তাহে পুনরায় অর্ডার করুন",
        "fil": "Mababang stock - mag-reorder ngayong linggo",
        "id": "Stok rendah - pesan ulang minggu ini",
    },
    "inv_near_reorder": {
        "ar": "قارب على نقطة إعادة الطلب",
        "en": "Near reorder point",
        "ur": "دوبارہ آرڈر پوائنٹ کے قریب",
        "hi": "रीऑर्डर पॉइंट के करीब",
        "bn": "পুনরায় অর্ডার পয়েন্টের কাছে",
        "fil": "Malapit na sa reorder point",
        "id": "Mendekati titik pesan ulang",
    },
    "inv_good": {
        "ar": "مخزون جيد", "en": "Good stock level", "ur": "اچھا اسٹاک",
        "hi": "अच्छा स्टॉक स्तर", "bn": "ভালো স্টক লেভেল",
        "fil": "Magandang stock level", "id": "Level stok baik",
    },
    "inv_overstock_promo": {
        "ar": "مخزون زائد - فرصة لعرض خاص",
        "en": "Overstock - opportunity for special offer",
        "ur": "زیادہ اسٹاک - خصوصی آفر کا موقع",
        "hi": "अतिरिक्त स्टॉक - विशेष ऑफर का अवसर",
        "bn": "অতিরিক্ত স্টক - বিশেষ অফারের সুযোগ",
        "fil": "Overstock - pagkakataon para sa special offer",
        "id": "Stok berlebih - peluang untuk penawaran khusus",
    },

    # --- Competitor names ---
    "competitor_1": {"ar": "سوبرماركت الرياض", "en": "Riyadh Supermarket", "ur": "ریاض سپر مارکیٹ", "hi": "रियाद सुपरमार्केट", "bn": "রিয়াদ সুপারমার্কেট", "fil": "Riyadh Supermarket", "id": "Supermarket Riyadh"},
    "competitor_2": {"ar": "بقالة النور", "en": "Al-Noor Grocery", "ur": "النور گروسری", "hi": "अल-नूर ग्रॉसरी", "bn": "আল-নূর গ্রোসারি", "fil": "Al-Noor Grocery", "id": "Toko Al-Noor"},
    "competitor_3": {"ar": "هايبر ماركت الوطن", "en": "Al-Watan Hypermarket", "ur": "الوطن ہائپر مارکیٹ", "hi": "अल-वतन हाइपरमार्केट", "bn": "আল-ওয়াতান হাইপারমার্কেট", "fil": "Al-Watan Hypermarket", "id": "Hypermarket Al-Watan"},

    # --- Employee names ---
    "emp_1": {"ar": "أحمد محمد", "en": "Ahmed Mohammed", "ur": "احمد محمد", "hi": "अहमद मोहम्मद", "bn": "আহমেদ মোহাম্মদ", "fil": "Ahmed Mohammed", "id": "Ahmed Mohammed"},
    "emp_2": {"ar": "سارة علي", "en": "Sara Ali", "ur": "سارہ علی", "hi": "सारा अली", "bn": "সারা আলী", "fil": "Sara Ali", "id": "Sara Ali"},
    "emp_3": {"ar": "خالد حسن", "en": "Khaled Hassan", "ur": "خالد حسن", "hi": "खालिद हसन", "bn": "খালেদ হাসান", "fil": "Khaled Hassan", "id": "Khaled Hassan"},
    "emp_4": {"ar": "فاطمة أحمد", "en": "Fatima Ahmed", "ur": "فاطمہ احمد", "hi": "फातिमा अहमद", "bn": "ফাতেমা আহমেদ", "fil": "Fatima Ahmed", "id": "Fatima Ahmed"},
    "emp_5": {"ar": "محمد يوسف", "en": "Mohammed Youssef", "ur": "محمد یوسف", "hi": "मोहम्मद यूसुफ", "bn": "মোহাম্মদ ইউসুফ", "fil": "Mohammed Youssef", "id": "Mohammed Youssef"},

    # --- Sentiment ---
    "sentiment_positive": {"ar": "إيجابي", "en": "Positive", "ur": "مثبت", "hi": "सकारात्मक", "bn": "ইতিবাচক", "fil": "Positibo", "id": "Positif"},
    "sentiment_negative": {"ar": "سلبي", "en": "Negative", "ur": "منفی", "hi": "नकारात्मक", "bn": "নেতিবাচক", "fil": "Negatibo", "id": "Negatif"},
    "sentiment_neutral": {"ar": "محايد", "en": "Neutral", "ur": "غیر جانبدار", "hi": "तटस्थ", "bn": "নিরপেক্ষ", "fil": "Neutral", "id": "Netral"},

    # --- Chat / Assistant greetings ---
    "greeting": {
        "ar": "مرحباً! أنا مساعدك الذكي. يمكنني مساعدتك في تحليل المبيعات والمخزون والموظفين والعملاء. كيف يمكنني مساعدتك؟",
        "en": "Hello! I'm your smart assistant. I can help you analyze sales, inventory, staff, and customers. How can I help?",
        "ur": "خوش آمدید! میں آپ کا سمارٹ اسسٹنٹ ہوں۔ میں سیلز، انوینٹری، عملے اور گاہکوں کا تجزیہ کرنے میں مدد کر سکتا ہوں۔",
        "hi": "नमस्ते! मैं आपका स्मार्ट असिस्टेंट हूं। मैं बिक्री, इन्वेंटरी, स्टाफ और ग्राहकों का विश्लेषण करने में मदद कर सकता हूं।",
        "bn": "স্বাগতম! আমি আপনার স্মার্ট অ্যাসিস্ট্যান্ট। আমি বিক্রয়, ইনভেন্টরি, কর্মী এবং গ্রাহক বিশ্লেষণে সাহায্য করতে পারি।",
        "fil": "Kumusta! Ako ang iyong smart assistant. Makakatulong ako sa pagsusuri ng sales, inventory, staff, at customers.",
        "id": "Halo! Saya asisten pintar Anda. Saya bisa membantu menganalisis penjualan, inventaris, staf, dan pelanggan.",
    },
    "assistant_greeting": {
        "ar": "مرحباً! أنا المساعد الذكي للحي. يمكنني مساعدتك في إدارة المبيعات، المخزون، الموظفين، والعملاء. ماذا تريد أن تعرف؟",
        "en": "Hello! I'm the Alhai smart assistant. I can help you manage sales, inventory, staff, and customers. What would you like to know?",
        "ur": "خوش آمدید! میں الحي کا سمارٹ اسسٹنٹ ہوں۔ سیلز، انوینٹری، عملے اور گاہکوں کے انتظام میں مدد کر سکتا ہوں۔",
        "hi": "नमस्ते! मैं अलहय का स्मार्ट असिस्टेंट हूं। बिक्री, इन्वेंटरी, स्टाफ और ग्राहकों के प्रबंधन में मदद कर सकता हूं।",
        "bn": "স্বাগতম! আমি আলহাই এর স্মার্ট অ্যাসিস্ট্যান্ট। বিক্রয়, ইনভেন্টরি, কর্মী ও গ্রাহক ব্যবস্থাপনায় সাহায্য করতে পারি।",
        "fil": "Kumusta! Ako ang Alhai smart assistant. Makakatulong ako sa pamamahala ng sales, inventory, staff, at customers.",
        "id": "Halo! Saya asisten pintar Alhai. Saya bisa membantu mengelola penjualan, inventaris, staf, dan pelanggan.",
    },

    # --- Chat suggestions ---
    "suggest_today_sales": {
        "ar": "كم مبيعات اليوم؟", "en": "What are today's sales?", "ur": "آج کی فروخت کتنی ہے؟",
        "hi": "आज की बिक्री कितनी है?", "bn": "আজকের বিক্রি কত?",
        "fil": "Magkano ang benta ngayon?", "id": "Berapa penjualan hari ini?",
    },
    "suggest_inventory_status": {
        "ar": "ما حالة المخزون؟", "en": "What's the inventory status?", "ur": "انوینٹری کی حالت کیا ہے؟",
        "hi": "इन्वेंटरी की स्थिति क्या है?", "bn": "ইনভেন্টরির অবস্থা কী?",
        "fil": "Ano ang status ng inventory?", "id": "Bagaimana status inventaris?",
    },
    "suggest_best_employee": {
        "ar": "من أفضل موظف؟", "en": "Who's the best employee?", "ur": "بہترین ملازم کون ہے؟",
        "hi": "सबसे अच्छा कर्मचारी कौन है?", "bn": "সেরা কর্মী কে?",
        "fil": "Sino ang pinakamahusay na empleyado?", "id": "Siapa karyawan terbaik?",
    },
    "suggest_next_week_forecast": {
        "ar": "ما توقعات الأسبوع القادم؟", "en": "What's next week's forecast?", "ur": "اگلے ہفتے کی پیشن گوئی کیا ہے؟",
        "hi": "अगले हफ्ते का पूर्वानुमान क्या है?", "bn": "আগামী সপ্তাহের পূর্বাভাস কী?",
        "fil": "Ano ang forecast sa susunod na linggo?", "id": "Bagaimana perkiraan minggu depan?",
    },

    # --- Report titles ---
    "report_sales_summary": {
        "ar": "ملخص المبيعات", "en": "Sales Summary", "ur": "فروخت کا خلاصہ",
        "hi": "बिक्री सारांश", "bn": "বিক্রয় সারাংশ",
        "fil": "Buod ng Benta", "id": "Ringkasan Penjualan",
    },
    "report_top_products": {
        "ar": "أفضل المنتجات", "en": "Top Products", "ur": "بہترین مصنوعات",
        "hi": "शीर्ष उत्पाद", "bn": "শীর্ষ পণ্য",
        "fil": "Nangungunang Produkto", "id": "Produk Teratas",
    },
    "report_inventory_alerts": {
        "ar": "تنبيهات المخزون", "en": "Inventory Alerts", "ur": "انوینٹری الرٹس",
        "hi": "इन्वेंटरी अलर्ट", "bn": "ইনভেন্টরি অ্যালার্ট",
        "fil": "Inventory Alerts", "id": "Peringatan Inventaris",
    },

    # --- Return prediction ---
    "return_wrong_size": {
        "ar": "مقاس غير مناسب", "en": "Wrong size", "ur": "غلط سائز",
        "hi": "गलत साइज़", "bn": "ভুল সাইজ",
        "fil": "Maling size", "id": "Ukuran salah",
    },
    "return_quality_mismatch": {
        "ar": "جودة غير مطابقة", "en": "Quality mismatch", "ur": "معیار میں فرق",
        "hi": "गुणवत्ता मेल नहीं", "bn": "মান অমিল",
        "fil": "Hindi tugma ang kalidad", "id": "Kualitas tidak sesuai",
    },
    "return_technical_defect": {
        "ar": "عطل فني", "en": "Technical defect", "ur": "تکنیکی خرابی",
        "hi": "तकनीकी दोष", "bn": "প্রযুক্তিগত ত্রুটি",
        "fil": "Technical defect", "id": "Cacat teknis",
    },
    "return_near_expiry": {
        "ar": "قرب انتهاء الصلاحية", "en": "Near expiry date", "ur": "میعاد ختم ہونے کے قریب",
        "hi": "समाप्ति तिथि के करीब", "bn": "মেয়াদ শেষ হওয়ার কাছে",
        "fil": "Malapit nang mag-expire", "id": "Mendekati tanggal kedaluwarsa",
    },
    "return_allergy": {
        "ar": "حساسية", "en": "Allergy reaction", "ur": "الرجی",
        "hi": "एलर्जी", "bn": "অ্যালার্জি",
        "fil": "Allergy", "id": "Alergi",
    },
    "return_manufacturing_defect": {
        "ar": "عيب في التصنيع", "en": "Manufacturing defect", "ur": "تصنیع میں خرابی",
        "hi": "निर्माण दोष", "bn": "উৎপাদন ত্রুটি",
        "fil": "Depekto sa pagmamanupaktura", "id": "Cacat manufaktur",
    },

    # --- Product categories for returns ---
    "cat_mens_clothing": {"ar": "ملابس رجالية", "en": "Men's Clothing", "ur": "مردانہ ملبوسات", "hi": "पुरुष कपड़े", "bn": "পুরুষদের পোশাক", "fil": "Men's Clothing", "id": "Pakaian Pria"},
    "cat_sports_shoes": {"ar": "أحذية رياضية", "en": "Sports Shoes", "ur": "کھیلوں کے جوتے", "hi": "स्पोर्ट्स शूज़", "bn": "স্পোর্টস শু", "fil": "Sports Shoes", "id": "Sepatu Olahraga"},
    "cat_electronics": {"ar": "إلكترونيات", "en": "Electronics", "ur": "الیکٹرونکس", "hi": "इलेक्ट्रॉनिक्स", "bn": "ইলেকট্রনিক্স", "fil": "Electronics", "id": "Elektronik"},
    "cat_food": {"ar": "مواد غذائية", "en": "Food Products", "ur": "کھانے کی اشیاء", "hi": "खाद्य पदार्थ", "bn": "খাদ্যদ্রব্য", "fil": "Pagkain", "id": "Produk Makanan"},
    "cat_cosmetics": {"ar": "مستحضرات تجميل", "en": "Cosmetics", "ur": "کاسمیٹکس", "hi": "कॉस्मेटिक्स", "bn": "কসমেটিক্স", "fil": "Cosmetics", "id": "Kosmetik"},
    "cat_household": {"ar": "أدوات منزلية", "en": "Household Items", "ur": "گھریلو سامان", "hi": "घरेलू सामान", "bn": "গৃহস্থালী সামগ্রী", "fil": "Household Items", "id": "Peralatan Rumah"},

    # --- Prevention tips ---
    "tip_size_chart": {
        "ar": "إضافة جدول مقاسات تفصيلي للملابس والأحذية",
        "en": "Add detailed size chart for clothing and shoes",
        "ur": "کپڑوں اور جوتوں کے لیے تفصیلی سائز چارٹ شامل کریں",
        "hi": "कपड़ों और जूतों के लिए विस्तृत साइज़ चार्ट जोड़ें",
        "bn": "পোশাক ও জুতার জন্য বিস্তারিত সাইজ চার্ট যোগ করুন",
        "fil": "Magdagdag ng detalyadong size chart para sa damit at sapatos",
        "id": "Tambahkan tabel ukuran detail untuk pakaian dan sepatu",
    },
    "tip_quality_check": {
        "ar": "فحص جودة الإلكترونيات قبل التسليم",
        "en": "Quality check electronics before delivery",
        "ur": "ترسیل سے پہلے الیکٹرونکس کا معائنہ کریں",
        "hi": "डिलीवरी से पहले इलेक्ट्रॉनिक्स की गुणवत्ता जांचें",
        "bn": "ডেলিভারির আগে ইলেকট্রনিক্সের মান পরীক্ষা করুন",
        "fil": "Quality check ang electronics bago i-deliver",
        "id": "Periksa kualitas elektronik sebelum pengiriman",
    },
    "tip_expiry_display": {
        "ar": "عرض تواريخ الصلاحية بشكل واضح",
        "en": "Display expiry dates clearly",
        "ur": "میعاد ختم ہونے کی تاریخیں واضح طور پر دکھائیں",
        "hi": "समाप्ति तिथियां स्पष्ट रूप से प्रदर्शित करें",
        "bn": "মেয়াদ শেষের তারিখ স্পষ্টভাবে প্রদর্শন করুন",
        "fil": "Ipakita nang malinaw ang expiry dates",
        "id": "Tampilkan tanggal kedaluwarsa dengan jelas",
    },
    "tip_cosmetics_samples": {
        "ar": "توفير عينات تجريبية لمستحضرات التجميل",
        "en": "Provide trial samples for cosmetics",
        "ur": "کاسمیٹکس کے لیے ٹرائل سیمپل فراہم کریں",
        "hi": "कॉस्मेटिक्स के लिए ट्रायल सैंपल प्रदान करें",
        "bn": "কসমেটিক্সের জন্য ট্রায়াল স্যাম্পল সরবরাহ করুন",
        "fil": "Magbigay ng trial samples para sa cosmetics",
        "id": "Sediakan sampel percobaan untuk kosmetik",
    },
    # --- Assistant action labels ---
    "action_sales_summary": {
        "ar": "ملخص المبيعات", "en": "Sales Summary", "ur": "فروخت کا خلاصہ",
        "hi": "बिक्री सारांश", "bn": "বিক্রয় সারাংশ",
        "fil": "Buod ng Benta", "id": "Ringkasan Penjualan",
    },
    "action_inventory_check": {
        "ar": "فحص المخزون", "en": "Inventory Check", "ur": "انوینٹری چیک",
        "hi": "इन्वेंटरी जांच", "bn": "ইনভেন্টরি চেক",
        "fil": "Inventory Check", "id": "Periksa Inventaris",
    },
    "topic_sales": {
        "ar": "المبيعات", "en": "Sales", "ur": "فروخت",
        "hi": "बिक्री", "bn": "বিক্রয়",
        "fil": "Benta", "id": "Penjualan",
    },
    "topic_inventory": {
        "ar": "المخزون", "en": "Inventory", "ur": "انوینٹری",
        "hi": "इन्वेंटरी", "bn": "ইনভেন্টরি",
        "fil": "Imbentaryo", "id": "Inventaris",
    },
    "topic_employees": {
        "ar": "الموظفين", "en": "Employees", "ur": "ملازمین",
        "hi": "कर्मचारी", "bn": "কর্মচারী",
        "fil": "Mga Empleyado", "id": "Karyawan",
    },
}


def t(key: str, lang: str) -> str:
    """Get translation for key in given language. Falls back to Arabic."""
    lang = _lang(lang)
    entry = _TRANSLATIONS.get(key)
    if entry is None:
        return key
    return entry.get(lang, entry.get("ar", key))


def t_fmt(key: str, lang: str, **kwargs) -> str:
    """Get translation with format placeholders."""
    text = t(key, lang)
    try:
        return text.format(**kwargs)
    except (KeyError, IndexError):
        return text


# ============================================================================
# OPENAI SYSTEM PROMPTS PER LANGUAGE
# ============================================================================

_SYSTEM_PROMPTS = {
    "ar": """أنت مساعد ذكي لنظام نقاط البيع "الحي" (Alhai POS).
تساعد أصحاب المتاجر والبقالات في السعودية بتحليل المبيعات والمخزون والموظفين والعملاء.
- أجب بالعربية دائماً
- كن مختصراً ومفيداً
- قدم أرقام وإحصائيات عند الإمكان
- اقترح إجراءات عملية
- استخدم عملة الريال السعودي (ر.س)""",

    "en": """You are a smart assistant for the "Alhai" POS system.
You help store and grocery owners in Saudi Arabia analyze sales, inventory, staff, and customers.
- Always answer in English
- Be concise and helpful
- Provide numbers and statistics when possible
- Suggest practical actions
- Use Saudi Riyal (SAR) currency""",

    "ur": """آپ "الحي" (Alhai POS) پوائنٹ آف سیل سسٹم کے سمارٹ اسسٹنٹ ہیں۔
آپ سعودی عرب میں دکانداروں کی سیلز، انوینٹری، عملے اور گاہکوں کا تجزیہ کرنے میں مدد کرتے ہیں۔
- ہمیشہ اردو میں جواب دیں
- مختصر اور مفید رہیں
- جب ممکن ہو نمبر اور اعداد و شمار فراہم کریں
- عملی اقدامات تجویز کریں
- سعودی ریال (SAR) کرنسی استعمال کریں""",

    "hi": """आप "अलहय" (Alhai POS) पॉइंट ऑफ सेल सिस्टम के स्मार्ट असिस्टेंट हैं।
आप सऊदी अरब में दुकान मालिकों की बिक्री, इन्वेंटरी, स्टाफ और ग्राहकों का विश्लेषण करने में मदद करते हैं।
- हमेशा हिंदी में जवाब दें
- संक्षिप्त और सहायक रहें
- जब संभव हो संख्या और आंकड़े प्रदान करें
- व्यावहारिक कार्रवाई सुझाएं
- सऊदी रियाल (SAR) मुद्रा का उपयोग करें""",

    "bn": """আপনি "আলহাই" (Alhai POS) পয়েন্ট অফ সেল সিস্টেমের স্মার্ট অ্যাসিস্ট্যান্ট।
আপনি সৌদি আরবে দোকান মালিকদের বিক্রয়, ইনভেন্টরি, কর্মী এবং গ্রাহক বিশ্লেষণে সাহায্য করেন।
- সর্বদা বাংলায় উত্তর দিন
- সংক্ষিপ্ত ও সহায়ক হোন
- সম্ভব হলে সংখ্যা ও পরিসংখ্যান প্রদান করুন
- ব্যবহারিক পদক্ষেপ প্রস্তাব করুন
- সৌদি রিয়াল (SAR) মুদ্রা ব্যবহার করুন""",

    "fil": """Ikaw ay isang smart assistant para sa "Alhai" POS system.
Tinutulungan mo ang mga may-ari ng tindahan sa Saudi Arabia na suriin ang sales, inventory, staff, at customers.
- Laging sumagot sa Filipino
- Maging maikli at kapaki-pakinabang
- Magbigay ng mga numero at estadistika kung maaari
- Magmungkahi ng praktikal na aksyon
- Gamitin ang Saudi Riyal (SAR) currency""",

    "id": """Anda adalah asisten pintar untuk sistem POS "Alhai".
Anda membantu pemilik toko di Arab Saudi menganalisis penjualan, inventaris, staf, dan pelanggan.
- Selalu jawab dalam Bahasa Indonesia
- Singkat dan bermanfaat
- Berikan angka dan statistik jika memungkinkan
- Sarankan tindakan praktis
- Gunakan mata uang Riyal Saudi (SAR)""",
}


def get_language_prompt(lang: str) -> str:
    """Get OpenAI system prompt for the given language."""
    return _SYSTEM_PROMPTS.get(_lang(lang), _SYSTEM_PROMPTS["ar"])
