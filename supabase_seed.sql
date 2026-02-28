-- =============================================
-- Supabase Seed Data for Categories & Products
-- Store ID: store-001
-- =============================================

-- Categories
INSERT INTO categories (id, org_id, store_id, name, name_en, parent_id, image_url, color, icon, sort_order, is_active, created_at, updated_at, synced_at)
VALUES
  ('cat_fruits',     NULL, 'store-001', 'فواكه',           'Fruits',            NULL, NULL, '#F97316', 'apple',     1,  true, now(), now(), now()),
  ('cat_vegetables', NULL, 'store-001', 'خضروات',          'Vegetables',        NULL, NULL, '#22C55E', 'carrot',    2,  true, now(), now(), now()),
  ('cat_dairy',      NULL, 'store-001', 'ألبان وأجبان',    'Dairy',             NULL, NULL, '#3B82F6', 'milk',      3,  true, now(), now(), now()),
  ('cat_meat',       NULL, 'store-001', 'لحوم ودواجن',     'Meat & Poultry',    NULL, NULL, '#EF4444', 'drumstick', 4,  true, now(), now(), now()),
  ('cat_bakery',     NULL, 'store-001', 'مخبوزات',         'Bakery',            NULL, NULL, '#F59E0B', 'bread',     5,  true, now(), now(), now()),
  ('cat_drinks',     NULL, 'store-001', 'مشروبات',         'Beverages',         NULL, NULL, '#06B6D4', 'bottle',    6,  true, now(), now(), now()),
  ('cat_snacks',     NULL, 'store-001', 'سناكس وحلويات',   'Snacks & Sweets',   NULL, NULL, '#8B5CF6', 'cookie',    7,  true, now(), now(), now()),
  ('cat_cleaning',   NULL, 'store-001', 'تنظيف ومنزلية',   'Cleaning & Home',   NULL, NULL, '#14B8A6', 'spray',     8,  true, now(), now(), now()),
  ('cat_grains',     NULL, 'store-001', 'حبوب وبقوليات',   'Grains & Legumes',  NULL, NULL, '#A3A3A3', 'grain',     9,  true, now(), now(), now()),
  ('cat_frozen',     NULL, 'store-001', 'مجمدات',          'Frozen',            NULL, NULL, '#60A5FA', 'snowflake', 10, true, now(), now(), now());

-- Products
INSERT INTO products (id, org_id, store_id, name, sku, barcode, price, cost_price, stock_qty, min_qty, unit, description, image_thumbnail, image_medium, image_large, image_hash, category_id, is_active, track_inventory, created_at, updated_at, synced_at)
VALUES
  -- Fruits (فواكه)
  ('prod_FRU001', NULL, 'store-001', 'تفاح أحمر',                    'FRU001', '6281000000001', 8.50,   6.00,  150, 20, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU002', NULL, 'store-001', 'موز',                          'FRU002', '6281000000002', 6.00,   4.00,  80,  15, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU003', NULL, 'store-001', 'برتقال',                       'FRU003', '6281000000003', 5.50,   3.50,  200, 30, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU004', NULL, 'store-001', 'عنب أخضر',                     'FRU004', '6281000000004', 15.00,  10.00, 45,  10, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU005', NULL, 'store-001', 'فراولة',                       'FRU005', '6281000000005', 18.00,  12.00, 30,  8,  'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU006', NULL, 'store-001', 'مانجو',                        'FRU006', '6281000000006', 12.00,  8.00,  60,  15, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),
  ('prod_FRU007', NULL, 'store-001', 'بطيخ',                         'FRU007', '6281000000007', 3.00,   1.50,  25,  5,  'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_fruits',     true, true, now(), now(), now()),

  -- Vegetables (خضروات)
  ('prod_VEG001', NULL, 'store-001', 'طماطم',                        'VEG001', '6281000000101', 4.00,   2.50,  180, 25, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG002', NULL, 'store-001', 'خيار',                         'VEG002', '6281000000102', 3.50,   2.00,  150, 20, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG003', NULL, 'store-001', 'بصل',                          'VEG003', '6281000000103', 3.00,   1.80,  200, 30, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG004', NULL, 'store-001', 'بطاطس',                        'VEG004', '6281000000104', 4.50,   3.00,  250, 40, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG005', NULL, 'store-001', 'جزر',                          'VEG005', '6281000000105', 4.00,   2.50,  120, 20, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG006', NULL, 'store-001', 'خس',                           'VEG006', '6281000000106', 5.00,   3.00,  50,  10, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG007', NULL, 'store-001', 'فلفل رومي',                    'VEG007', '6281000000107', 8.00,   5.00,  80,  15, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),
  ('prod_VEG008', NULL, 'store-001', 'كوسة',                         'VEG008', '6281000000108', 5.00,   3.00,  90,  15, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_vegetables', true, true, now(), now(), now()),

  -- Dairy (ألبان وأجبان)
  ('prod_DAI001', NULL, 'store-001', 'حليب المراعي طازج 2 لتر',     'DAI001', '6281048000001', 11.50,  9.00,  100, 20, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI002', NULL, 'store-001', 'لبن المراعي 1 لتر',           'DAI002', '6281048000002', 5.50,   4.00,  80,  15, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI003', NULL, 'store-001', 'جبنة كرافت شرائح',            'DAI003', '6281048000003', 12.00,  9.00,  60,  10, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI004', NULL, 'store-001', 'زبادي السعودية 170 جرام',     'DAI004', '6281048000004', 2.00,   1.30,  150, 30, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI005', NULL, 'store-001', 'جبنة بيضاء',                   'DAI005', '6281048000005', 18.00,  13.00, 40,  8,  'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI006', NULL, 'store-001', 'قشطة بوك',                     'DAI006', '6281048000006', 3.50,   2.50,  70,  15, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),
  ('prod_DAI007', NULL, 'store-001', 'زبدة لورباك 200 جرام',        'DAI007', '6281048000007', 14.00,  10.00, 35,  8,  'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_dairy',      true, true, now(), now(), now()),

  -- Meat & Poultry (لحوم ودواجن)
  ('prod_MEA001', NULL, 'store-001', 'دجاج كامل طازج',              'MEA001', '6281000000201', 22.00,  16.00, 50,  10, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_meat',       true, true, now(), now(), now()),
  ('prod_MEA002', NULL, 'store-001', 'صدور دجاج',                    'MEA002', '6281000000202', 32.00,  24.00, 35,  8,  'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_meat',       true, true, now(), now(), now()),
  ('prod_MEA003', NULL, 'store-001', 'لحم بقري مفروم',              'MEA003', '6281000000203', 48.00,  38.00, 25,  5,  'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_meat',       true, true, now(), now(), now()),
  ('prod_MEA004', NULL, 'store-001', 'لحم غنم',                      'MEA004', '6281000000204', 65.00,  52.00, 20,  5,  'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_meat',       true, true, now(), now(), now()),
  ('prod_MEA005', NULL, 'store-001', 'نقانق',                        'MEA005', '6281000000205', 18.00,  12.00, 40,  10, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_meat',       true, true, now(), now(), now()),

  -- Bakery (مخبوزات)
  ('prod_BAK001', NULL, 'store-001', 'خبز صامولي',                   'BAK001', '6281000000301', 3.00,   2.00,  100, 20, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_bakery',     true, true, now(), now(), now()),
  ('prod_BAK002', NULL, 'store-001', 'خبز تميس',                     'BAK002', '6281000000302', 2.50,   1.50,  80,  15, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_bakery',     true, true, now(), now(), now()),
  ('prod_BAK003', NULL, 'store-001', 'توست لوزين',                   'BAK003', '6281000000303', 8.00,   5.50,  60,  12, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_bakery',     true, true, now(), now(), now()),
  ('prod_BAK004', NULL, 'store-001', 'كرواسون',                      'BAK004', '6281000000304', 1.50,   0.80,  50,  10, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_bakery',     true, true, now(), now(), now()),
  ('prod_BAK005', NULL, 'store-001', 'صمون فرنسي',                   'BAK005', '6281000000305', 4.00,   2.50,  40,  8,  'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_bakery',     true, true, now(), now(), now()),

  -- Beverages (مشروبات)
  ('prod_DRK001', NULL, 'store-001', 'بيبسي 330 مل',                'DRK001', '6281000000401', 2.00,   1.20,  200, 50, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK002', NULL, 'store-001', 'كوكاكولا 330 مل',             'DRK002', '6281000000402', 2.00,   1.20,  180, 50, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK003', NULL, 'store-001', 'مياه أكوافينا 600 مل',        'DRK003', '6281000000403', 1.00,   0.50,  300, 80, 'زجاجة',  NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK004', NULL, 'store-001', 'عصير المراعي برتقال 1 لتر',   'DRK004', '6281000000404', 6.50,   4.50,  80,  20, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK005', NULL, 'store-001', 'ريد بول',                      'DRK005', '6281000000405', 8.00,   5.50,  60,  15, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK006', NULL, 'store-001', 'شاي ليبتون علب',              'DRK006', '6281000000406', 15.00,  10.00, 45,  10, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),
  ('prod_DRK007', NULL, 'store-001', 'نسكافيه جولد 100 جرام',       'DRK007', '6281000000407', 32.00,  24.00, 30,  8,  'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_drinks',     true, true, now(), now(), now()),

  -- Snacks & Sweets (سناكس وحلويات)
  ('prod_SNK001', NULL, 'store-001', 'شيبس ليز 170 جرام',           'SNK001', '6281000000501', 7.00,   4.50,  100, 25, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),
  ('prod_SNK002', NULL, 'store-001', 'شوكولاتة جالكسي',             'SNK002', '6281000000502', 5.00,   3.20,  80,  20, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),
  ('prod_SNK003', NULL, 'store-001', 'بسكويت أوريو',                'SNK003', '6281000000503', 4.50,   3.00,  90,  20, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),
  ('prod_SNK004', NULL, 'store-001', 'كيندر بوينو',                 'SNK004', '6281000000504', 6.00,   4.00,  70,  15, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),
  ('prod_SNK005', NULL, 'store-001', 'مكسرات مشكلة',                'SNK005', '6281000000505', 25.00,  18.00, 35,  8,  'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),
  ('prod_SNK006', NULL, 'store-001', 'تمر سكري',                     'SNK006', '6281000000506', 35.00,  25.00, 40,  10, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_snacks',     true, true, now(), now(), now()),

  -- Cleaning & Home (تنظيف ومنزلية)
  ('prod_CLN001', NULL, 'store-001', 'صابون فيري',                   'CLN001', '6281000000601', 8.50,   5.50,  60,  15, 'زجاجة',  NULL, NULL, NULL, NULL, NULL, 'cat_cleaning',   true, true, now(), now(), now()),
  ('prod_CLN002', NULL, 'store-001', 'مناديل كلينكس 200 ورقة',      'CLN002', '6281000000602', 12.00,  8.00,  80,  20, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_cleaning',   true, true, now(), now(), now()),
  ('prod_CLN003', NULL, 'store-001', 'معجون أسنان كولجيت',          'CLN003', '6281000000603', 9.00,   6.00,  50,  12, 'حبة',    NULL, NULL, NULL, NULL, NULL, 'cat_cleaning',   true, true, now(), now(), now()),
  ('prod_CLN004', NULL, 'store-001', 'شامبو هيد آند شولدرز',        'CLN004', '6281000000604', 22.00,  15.00, 35,  8,  'زجاجة',  NULL, NULL, NULL, NULL, NULL, 'cat_cleaning',   true, true, now(), now(), now()),
  ('prod_CLN005', NULL, 'store-001', 'منظف زجاج ويندكس',            'CLN005', '6281000000605', 14.00,  9.00,  25,  6,  'زجاجة',  NULL, NULL, NULL, NULL, NULL, 'cat_cleaning',   true, true, now(), now(), now()),

  -- Grains & Legumes (حبوب وبقوليات)
  ('prod_GRN001', NULL, 'store-001', 'أرز بسمتي 5 كيلو',            'GRN001', '6281000000701', 45.00,  35.00, 50,  10, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN002', NULL, 'store-001', 'سكر 5 كيلو',                  'GRN002', '6281000000702', 18.00,  14.00, 60,  15, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN003', NULL, 'store-001', 'طحين 2 كيلو',                 'GRN003', '6281000000703', 8.00,   5.50,  70,  15, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN004', NULL, 'store-001', 'معكرونة قودي',                'GRN004', '6281000000704', 4.50,   3.00,  100, 25, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN005', NULL, 'store-001', 'فول مدمس',                     'GRN005', '6281000000705', 3.50,   2.20,  80,  20, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN006', NULL, 'store-001', 'حمص حب',                      'GRN006', '6281000000706', 6.00,   4.00,  45,  10, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_GRN007', NULL, 'store-001', 'عدس',                          'GRN007', '6281000000707', 7.00,   4.50,  40,  10, 'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),

  -- Frozen (مجمدات)
  ('prod_FRZ001', NULL, 'store-001', 'بازلاء مجمدة',                'FRZ001', '6281000000801', 8.00,   5.00,  40,  10, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_frozen',     true, true, now(), now(), now()),
  ('prod_FRZ002', NULL, 'store-001', 'سمبوسة جاهزة',                'FRZ002', '6281000000802', 15.00,  10.00, 50,  12, 'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_frozen',     true, true, now(), now(), now()),
  ('prod_FRZ003', NULL, 'store-001', 'بطاطس فرنسية مجمدة',          'FRZ003', '6281000000803', 12.00,  8.00,  60,  15, 'كيس',    NULL, NULL, NULL, NULL, NULL, 'cat_frozen',     true, true, now(), now(), now()),
  ('prod_FRZ004', NULL, 'store-001', 'آيس كريم فانيلا',             'FRZ004', '6281000000804', 18.00,  12.00, 30,  8,  'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_frozen',     true, true, now(), now(), now()),
  ('prod_FRZ005', NULL, 'store-001', 'سمك فيليه',                    'FRZ005', '6281000000805', 35.00,  25.00, 20,  5,  'كيلو',   NULL, NULL, NULL, NULL, NULL, 'cat_frozen',     true, true, now(), now(), now()),

  -- Miscellaneous (in Grains & Legumes category)
  ('prod_OIL001', NULL, 'store-001', 'زيت زيتون',                    'OIL001', '6281000000901', 45.00,  35.00, 5,   10, 'زجاجة',  NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_OIL002', NULL, 'store-001', 'عسل طبيعي',                    'OIL002', '6281000000902', 65.00,  50.00, 3,   5,  'علبة',   NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now()),
  ('prod_SPC001', NULL, 'store-001', 'زعفران',                       'SPC001', '6281000000903', 120.00, 90.00, 0,   2,  'جرام',   NULL, NULL, NULL, NULL, NULL, 'cat_grains',     true, true, now(), now(), now());
