import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../providers/auth_providers.dart';
import '../providers/theme_provider.dart';
import '../security/secure_storage_service.dart';
import '../widgets/branch_card.dart';
import '../widgets/branding/mascot_widget.dart';

/// شاشة اختيار المتجر - تصميم جديد 2026
class StoreSelectScreen extends ConsumerStatefulWidget {
  const StoreSelectScreen({super.key});

  @override
  ConsumerState<StoreSelectScreen> createState() => _StoreSelectScreenState();
}

class _StoreSelectScreenState extends ConsumerState<StoreSelectScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStoreId;

  // بيانات الفروع من قاعدة البيانات
  List<BranchData> _stores = [];
  bool _isLoadingStores = true;
  String? _storesError;

  /// تحويل بيانات المتجر من قاعدة البيانات إلى BranchData
  BranchData _mapStoreToBranch(StoresTableData store, {bool isFirst = false}) {
    return BranchData(
      id: store.id,
      name: store.name,
      address: store.address,
      type: BranchType.store,
      status: store.isActive ? BranchStatus.open : BranchStatus.closed,
      isDefault: isFirst,
    );
  }

  /// تحميل الفروع (محلي أولاً → Supabase في الخلفية)
  Future<void> _loadStores() async {
    setState(() {
      _isLoadingStores = true;
      _storesError = null;
    });

    final currentUserId = await _getCurrentUserId();

    // --- المحاولة 1: Local DB (سريع جداً) ---
    try {
      final db = getIt<AppDatabase>();
      List<StoresTableData> stores = [];

      if (currentUserId != null) {
        final userStores = await db.orgMembersDao.getUserStores(currentUserId);
        if (userStores.isNotEmpty) {
          // batch query بدلاً من loop (N+1 fix)
          final activeIds = userStores
              .where((us) => us.isActive)
              .map((us) => us.storeId)
              .toList();
          stores = await db.storesDao.getStoresByIds(activeIds);
        }
      }

      // fallback: جلب كل المتاجر المحلية النشطة
      if (stores.isEmpty) {
        stores = await db.storesDao.getActiveStores();
      }

      // fallback نهائي: فحص سريع بـ LIMIT 1 بدلاً من تحميل 5000 منتج
      // Only attempts the dev-seed recovery path when DEFAULT_STORE_ID is
      // actually configured. In production builds without the define,
      // kDefaultStoreId is empty and this path is skipped — the user must
      // select a real store.
      if (stores.isEmpty && kDefaultStoreId.isNotEmpty) {
        final hasProds = await db.productsDao.hasProducts(kDefaultStoreId);
        if (hasProds) {
          debugPrint(
            '[StoreSelect] Products exist but no store record - creating default',
          );
          await db.storesDao.insertStore(
            StoresTableCompanion.insert(
              id: kDefaultStoreId,
              name: 'سوبرماركت الحي',
              createdAt: DateTime.now(),
              currency: const Value('SAR'),
              timezone: const Value('Asia/Riyadh'),
              isActive: const Value(true),
              address: const Value('الرياض، حي النزهة'),
              city: const Value('الرياض'),
              nameEn: const Value('Al-Hai Supermarket'),
            ),
          );
          final newStore = await db.storesDao.getStoreById(kDefaultStoreId);
          if (newStore != null) stores.add(newStore);
        }
      }

      if (stores.isNotEmpty) {
        final branches = stores
            .asMap()
            .entries
            .map((e) => _mapStoreToBranch(e.value, isFirst: e.key == 0))
            .toList();

        if (mounted) {
          setState(() {
            _stores = branches;
            _isLoadingStores = false;
          });
          if (branches.length == 1) {
            _selectStore(branches.first);
          }
        }

        // مزامنة من Supabase في الخلفية (لا تؤخر العرض)
        _syncStoresInBackground(db, currentUserId);
        return;
      }
    } catch (dbError) {
      debugPrint('[StoreSelect] Local DB failed: $dbError');
    }

    // --- المحاولة 2: Supabase مباشر (إذا Local فاضي) ---
    try {
      final branches = await _fetchStoresFromSupabase();
      if (mounted) {
        setState(() {
          _stores = branches;
          _isLoadingStores = false;
        });
        if (branches.length == 1) {
          _selectStore(branches.first);
        }
      }
    } catch (supaError) {
      debugPrint('[StoreSelect] Supabase fetch failed: $supaError');
      if (mounted) {
        setState(() {
          _isLoadingStores = false;
          _storesError = 'خطأ في جلب البيانات: $supaError';
        });
      }
    }
  }

  /// مزامنة المتاجر في الخلفية بدون تأخير العرض
  Future<void> _syncStoresInBackground(
    AppDatabase db,
    String? currentUserId,
  ) async {
    try {
      await _syncStoresFromSupabase(db);
      // بعد المزامنة، نتحقق إذا تغيرت القائمة
      if (currentUserId != null && mounted) {
        final userStores = await db.orgMembersDao.getUserStores(currentUserId);
        if (userStores.isNotEmpty) {
          final activeIds = userStores
              .where((us) => us.isActive)
              .map((us) => us.storeId)
              .toList();
          final stores = await db.storesDao.getStoresByIds(activeIds);
          final branches = stores
              .asMap()
              .entries
              .map((e) => _mapStoreToBranch(e.value, isFirst: e.key == 0))
              .toList();
          if (mounted && branches.length != _stores.length) {
            setState(() => _stores = branches);
          }
        }
      }
    } catch (e) {
      debugPrint('[StoreSelect] Background sync failed: $e');
    }
  }

  /// الحصول على معرف المستخدم الحالي (Supabase أولاً → SecureStorage ثانياً)
  Future<String?> _getCurrentUserId() async {
    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) return supabaseUser.id;
    } catch (e) {
      // Supabase unavailable or uninitialized — fall through to SecureStorage fallback below.
      debugPrint('[StoreSelect] Supabase currentUser lookup failed: $e');
    }
    // Fallback: SecureStorage (للوضع المحلي / Web بدون Supabase)
    try {
      return await SecureStorageService.getUserId();
    } catch (_) {
      return null;
    }
  }

  /// Retry helper with exponential backoff for Supabase RPC calls.
  ///
  /// Retries [action] up to [maxRetries] times with exponential delay
  /// (1s, 2s, 4s, ...) before giving up. Catches all exceptions and
  /// rethrows the last one if all retries are exhausted.
  Future<T> _retryRpc<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    String label = 'RPC',
  }) async {
    Exception? lastError;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await action();
      } on Exception catch (e) {
        lastError = e;
        if (attempt < maxRetries - 1) {
          final delay =
              initialDelay * (1 << attempt); // exponential: 1s, 2s, 4s
          debugPrint(
            '[$label] Attempt ${attempt + 1} failed, retrying in ${delay.inMilliseconds}ms: $e',
          );
          await Future.delayed(delay);
        }
      }
    }
    debugPrint('[$label] All $maxRetries attempts failed');
    throw lastError!;
  }

  /// جلب المتاجر مباشرة من Supabase عبر RPC (يتخطى RLS بالكامل)
  Future<List<BranchData>> _fetchStoresFromSupabase() async {
    debugPrint('[StoreSelect] _fetchStoresFromSupabase() via RPC');

    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;
    debugPrint(
      '[StoreSelect] currentUser: ${authUser?.id} / phone: ${authUser?.phone}',
    );

    if (authUser == null) {
      debugPrint('[StoreSelect] No authenticated user - returning empty');
      return [];
    }

    // استدعاء دالة RPC التي تتخطى RLS مع retry
    final response = await _retryRpc(
      () => supabase.rpc('get_my_stores').timeout(const Duration(seconds: 10)),
      label: 'get_my_stores',
      maxRetries: 2,
    );
    debugPrint('[StoreSelect] RPC get_my_stores response: $response');

    final storesList = response is List ? response : <dynamic>[];
    if (storesList.isEmpty) return [];

    final branches = <BranchData>[];
    for (var i = 0; i < storesList.length; i++) {
      final s = storesList[i];
      if (s is! Map<String, dynamic>) continue;
      final id = s['id'] as String?;
      if (id == null || id.isEmpty) continue;
      branches.add(
        BranchData(
          id: id,
          name: s['name'] as String? ?? '',
          address: s['address'] as String?,
          type: BranchType.store,
          status: (s['is_active'] as bool? ?? true)
              ? BranchStatus.open
              : BranchStatus.closed,
          isDefault: i == 0,
        ),
      );
    }
    return branches;
  }

  /// جلب المتاجر من Supabase عبر RPC وحفظها في قاعدة البيانات المحلية
  /// يحفظ كلاً من تفاصيل المتاجر (stores) وربط المستخدم بالمتاجر (user_stores)
  Future<void> _syncStoresFromSupabase(AppDatabase db) async {
    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      // استخدام RPC لتفادي مشاكل RLS مع retry
      final response = await _retryRpc(
        () =>
            supabase.rpc('get_my_stores').timeout(const Duration(seconds: 10)),
        label: 'sync_get_my_stores',
        maxRetries: 2,
      );
      final storesList = response is List ? response : <dynamic>[];
      if (storesList.isEmpty) return;

      debugPrint(
        '[StoreSelect] Syncing ${storesList.length} stores to local DB',
      );
      final now = DateTime.now();

      for (final s in storesList) {
        if (s is! Map<String, dynamic>) continue;
        final storeId = s['id'] as String? ?? '';
        if (storeId.isEmpty) continue;

        // 1. حفظ تفاصيل المتجر
        await db.storesDao.insertStore(
          StoresTableCompanion.insert(
            id: storeId,
            name: s['name'] as String? ?? '',
            createdAt:
                DateTime.tryParse(s['created_at']?.toString() ?? '') ?? now,
            currency: Value(s['currency'] as String? ?? 'SAR'),
            timezone: Value(s['timezone'] as String? ?? 'Asia/Riyadh'),
            isActive: Value(s['is_active'] as bool? ?? true),
            address: Value(s['address'] as String?),
            phone: Value(s['phone'] as String?),
            email: Value(s['email'] as String?),
            city: Value(s['city'] as String?),
            nameEn: Value(s['name_en'] as String?),
          ),
        );

        // 2. حفظ ربط المستخدم بالمتجر في user_stores
        final role = s['role_in_store'] as String? ?? 'cashier';
        await db.orgMembersDao.upsertUserStore(
          UserStoresTableCompanion.insert(
            id: 'us_${authUser.id}_$storeId',
            userId: authUser.id,
            storeId: storeId,
            role: Value(role),
            isPrimary: Value(storesList.length == 1),
            isActive: const Value(true),
            createdAt: now,
          ),
        );
      }
      debugPrint(
        '[StoreSelect] Stores + user_stores synced to local DB successfully',
      );
    } catch (e) {
      debugPrint('خطأ في مزامنة المتاجر من Supabase: $e');
    }
  }

  List<BranchData> get _filteredStores {
    if (_searchQuery.isEmpty) return _stores;
    return _stores.where((store) {
      return store.name.contains(_searchQuery) ||
          (store.address?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // تحميل الفروع من قاعدة البيانات
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSyncing = false;

  void _selectStore(BranchData store) async {
    setState(() {
      _selectedStoreId = store.id;
      _isSyncing = true;
    });

    // حفظ معرف المتجر في Provider و SecureStorage بالتوازي
    ref.read(currentStoreIdProvider.notifier).state = store.id;
    // لا ننتظر SecureStorage - يعمل في الخلفية
    _getCurrentUserId().then((userId) {
      SecureStorageService.saveUserData(
        userId: userId ?? '',
        storeId: store.id,
      );
    });

    // مزامنة البيانات مع timeout قصير - لا تمنع الانتقال
    try {
      await _syncStoreData(store.id).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[StoreSelect] Sync failed or timed out: $e');
      // لا نعرض رسالة خطأ - التطبيق يعمل offline-first
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }

    if (!mounted) return;

    // الانتقال مباشرة بدون تأخير
    context.go('/pos');
  }

  /// مزامنة التصنيفات والمنتجات من Supabase → Local DB (بالتوازي)
  Future<void> _syncStoreData(String storeId) async {
    final supabase = Supabase.instance.client;
    final db = getIt<AppDatabase>();

    debugPrint('[Sync] بدء مزامنة البيانات للمتجر: $storeId');

    // تشغيل RPC التصنيفات والمنتجات بالتوازي بدلاً من التسلسل
    final results = await Future.wait([
      _retryRpc(
        () => supabase
            .rpc('get_store_categories', params: {'p_store_id': storeId})
            .timeout(const Duration(seconds: 20)),
        label: 'get_store_categories',
      ),
      _retryRpc(
        () => supabase
            .rpc('get_store_products', params: {'p_store_id': storeId})
            .timeout(const Duration(seconds: 20)),
        label: 'get_store_products',
      ),
    ]);

    final catList = results[0] is List ? results[0] as List : <dynamic>[];
    final prodList = results[1] is List ? results[1] as List : <dynamic>[];
    debugPrint('[Sync] تصنيفات: ${catList.length}, منتجات: ${prodList.length}');

    // حفظ التصنيفات والمنتجات بالتوازي في DB
    await Future.wait([
      if (catList.isNotEmpty) _saveCategoriesLocally(db, catList),
      if (prodList.isNotEmpty) _saveProductsLocally(db, prodList),
    ]);

    debugPrint('[Sync] ✅ اكتملت المزامنة');
  }

  Future<void> _saveCategoriesLocally(
    AppDatabase db,
    List<dynamic> catList,
  ) async {
    final categories = catList.whereType<Map<String, dynamic>>().map((c) {
      final cat = c;
      return CategoriesTableCompanion.insert(
        id: cat['id'] as String? ?? '',
        storeId: cat['store_id'] as String? ?? '',
        name: cat['name'] as String? ?? '',
        createdAt:
            DateTime.tryParse(cat['created_at']?.toString() ?? '') ??
            DateTime.now(),
        orgId: Value(cat['org_id'] as String?),
        nameEn: Value(cat['name_en'] as String?),
        parentId: Value(cat['parent_id'] as String?),
        imageUrl: Value(cat['image_url'] as String?),
        color: Value(cat['color'] as String?),
        icon: Value(cat['icon'] as String?),
        sortOrder: Value(cat['sort_order'] as int? ?? 0),
        isActive: Value(cat['is_active'] as bool? ?? true),
        updatedAt: Value(
          DateTime.tryParse(cat['updated_at']?.toString() ?? ''),
        ),
        syncedAt: Value(DateTime.now()),
      );
    }).toList();

    await db.categoriesDao.insertCategories(categories);
    debugPrint('[Sync] ✅ تم مزامنة ${categories.length} تصنيف');
  }

  Future<void> _saveProductsLocally(
    AppDatabase db,
    List<dynamic> prodList,
  ) async {
    for (final p in prodList) {
      if (p is! Map<String, dynamic>) continue;
      final prod = p;
      await db.productsDao.upsertProduct(
        ProductsTableCompanion.insert(
          id: prod['id'] as String? ?? '',
          storeId: prod['store_id'] as String? ?? '',
          name: prod['name'] as String? ?? '',
          price: (prod['price'] as num?)?.toDouble() ?? 0.0,
          createdAt:
              DateTime.tryParse(prod['created_at']?.toString() ?? '') ??
              DateTime.now(),
          orgId: Value(prod['org_id'] as String?),
          sku: Value(prod['sku'] as String?),
          barcode: Value(prod['barcode'] as String?),
          costPrice: Value((prod['cost_price'] as num?)?.toDouble()),
          stockQty: Value((prod['stock_qty'] as num?)?.toDouble() ?? 0.0),
          minQty: Value((prod['min_qty'] as num?)?.toDouble() ?? 0.0),
          unit: Value(prod['unit'] as String?),
          description: Value(prod['description'] as String?),
          imageThumbnail: Value(prod['image_thumbnail'] as String?),
          imageMedium: Value(prod['image_medium'] as String?),
          imageLarge: Value(prod['image_large'] as String?),
          imageHash: Value(prod['image_hash'] as String?),
          categoryId: Value(prod['category_id'] as String?),
          isActive: Value(prod['is_active'] as bool? ?? true),
          trackInventory: Value(prod['track_inventory'] as bool? ?? true),
          updatedAt: Value(
            DateTime.tryParse(prod['updated_at']?.toString() ?? ''),
          ),
          syncedAt: Value(DateTime.now()),
        ),
      );
    }
    debugPrint('[Sync] ✅ تم مزامنة ${prodList.length} منتج');
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    // استخدام Theme.of(context) لضمان التطابق مع ThemeMode.system
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isWideScreen
          ? _buildWideLayout(isDarkMode)
          : _buildNarrowLayout(isDarkMode),
    );
  }

  // ============================================================================
  // تخطيط الشاشات العريضة (Desktop/Tablet)
  // ============================================================================
  Widget _buildWideLayout(bool isDarkMode) {
    return Row(
      children: [
        // اللوحة اليسرى - Brand Panel
        Expanded(flex: 4, child: _buildBrandPanel()),
        // اللوحة اليمنى - Content Panel
        Expanded(
          flex: 5,
          child: _buildContentPanel(isDarkMode, isMobile: false),
        ),
      ],
    );
  }

  // ============================================================================
  // تخطيط الجوال (Mobile)
  // ============================================================================
  Widget _buildNarrowLayout(bool isDarkMode) {
    return Column(
      children: [
        // Brand Header مصغر
        _buildMobileBrandHeader(),
        // Content
        Expanded(child: _buildContentPanel(isDarkMode, isMobile: true)),
      ],
    );
  }

  // ============================================================================
  // اللوحة اليسرى - Brand Panel
  // ============================================================================
  Widget _buildBrandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          // الأنماط الزخرفية في الخلفية
          _buildDecorativePatterns(),

          // المحتوى الرئيسي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.xl),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // شعار Al-HAI POS في الأعلى
                            _buildBrandLogo(),

                            const Spacer(),

                            // صورة الروبوت مع الحركة
                            _buildRobotMascot(),

                            const SizedBox(height: AlhaiSpacing.lg),

                            // العنوان والوصف
                            _buildBrandText(),

                            const Spacer(),

                            // الإحصائيات
                            _buildGlassStats(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativePatterns() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // دائرة كبيرة في الأعلى
            PositionedDirectional(
              top: -100,
              end: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 40,
                  ),
                ),
              ),
            ),
            // دائرة ضبابية في الأسفل
            PositionedDirectional(
              bottom: -50,
              start: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.point_of_sale_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        const Text(
          'Al-HAI POS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRobotMascot() {
    return const MascotWidget(
      size: MascotSize.medium,
      pose: MascotPose.waving,
      animate: true,
    );
  }

  Widget _buildBrandText() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Text(
              l10n.centralManagement,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),
        Text(
          l10n.centralManagementDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStats() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _buildStatItem('24/7', l10n.support247)),
        const SizedBox(width: AlhaiSpacing.md),
        Expanded(child: _buildStatItem('50+', l10n.analyticsTools)),
        const SizedBox(width: AlhaiSpacing.md),
        Expanded(child: _buildStatItem('99.9%', l10n.uptime)),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Header للجوال
  // ============================================================================
  Widget _buildMobileBrandHeader() {
    return Container(
      padding: EdgeInsetsDirectional.only(
        top: context.safeTop + AlhaiSpacing.md,
        start: AlhaiSpacing.mdl,
        end: AlhaiSpacing.mdl,
        bottom: AlhaiSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          // أيقونة الروبوت مصغرة
          const MascotWidget(
            size: MascotSize.small,
            pose: MascotPose.waving,
            animate: true,
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Al-HAI POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  AppLocalizations.of(context).selectYourBranchToContinue,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // اللوحة اليمنى - Content Panel
  // ============================================================================
  Widget _buildContentPanel(bool isDarkMode, {required bool isMobile}) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          _buildContentHeader(isDarkMode, isMobile: isMobile),

          // الفاصل
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white12 : Theme.of(context).dividerColor,
          ),

          // قائمة الفروع
          Expanded(child: _buildStoresList(isDarkMode)),

          // Footer
          _buildFooter(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildContentHeader(bool isDarkMode, {required bool isMobile}) {
    final localeState = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final iconSize = isMobile ? 36.0 : 44.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? AlhaiSpacing.sm : AlhaiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف الأدوات - ترتيب: خروج | معلومات المستخدم | ... | اللغة | Dark Mode
          Row(
            children: [
              // === اليسار: زر الخروج ===
              _buildIconButton(
                icon: Icons.logout_rounded,
                onTap: () => context.go('/login'),
                isDarkMode: isDarkMode,
                size: iconSize,
              ),

              SizedBox(width: isMobile ? AlhaiSpacing.xs : AlhaiSpacing.sm),

              // === معلومات المستخدم ===
              Expanded(child: _buildUserInfo(isDarkMode, isMobile: isMobile)),

              // === اليمين: اللغة + Dark Mode ===
              _buildLanguageSelector(
                isDarkMode,
                localeState,
                isMobile: isMobile,
              ),

              SizedBox(width: isMobile ? 6 : AlhaiSpacing.xs),

              // M-THEME-FIX: توحيد أيقونة الثيم مع شاشة Login
              IconButton(
                onPressed: () =>
                    ref.read(themeProvider.notifier).toggleDarkMode(),
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
                tooltip: isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
              ),
            ],
          ),

          SizedBox(height: isMobile ? AlhaiSpacing.mdl : AlhaiSpacing.xl),

          // العنوان
          Text(
            l10n.selectBranchToContinue,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AlhaiSpacing.xs),

          Text(
            l10n.youHaveAccessToBranches,
            style: TextStyle(
              color: isDarkMode ? Colors.white60 : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),

          SizedBox(height: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),

          // حقل البحث
          _buildSearchField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    double size = 44,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size * 0.27),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(size * 0.27),
        ),
        child: Icon(
          icon,
          color: isDarkMode
              ? Colors.white70
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: size * 0.45,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    bool isDarkMode,
    LocaleState localeState, {
    bool isMobile = false,
  }) {
    return PopupMenuButton<Locale>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageFlag(localeState.locale.languageCode),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            if (!isMobile) ...[
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                _getLanguageName(localeState.locale.languageCode),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
            SizedBox(width: isMobile ? 2 : 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: isMobile ? 16 : 18,
              color: isDarkMode
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => SupportedLocales.all.map((locale) {
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Text(_getLanguageFlag(locale.languageCode)),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                _getLanguageName(locale.languageCode),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (locale) {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'hi':
        return '🇮🇳';
      case 'bn':
        return '🇧🇩';
      case 'id':
        return '🇮🇩';
      case 'tl':
        return '🇵🇭';
      case 'ur':
        return '🇵🇰';
      default:
        return '🌍';
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'bn':
        return 'বাংলা';
      case 'id':
        return 'Indonesia';
      case 'tl':
        return 'Filipino';
      case 'ur':
        return 'اردو';
      default:
        return code;
    }
  }

  Widget _buildUserInfo(bool isDarkMode, {bool isMobile = false}) {
    final avatarSize = isMobile ? 32.0 : 40.0;
    final l10n = AppLocalizations.of(context);

    // جلب رقم الجوال الحقيقي من Supabase Auth
    String userPhone = '';
    try {
      final user = Supabase.instance.client.auth.currentUser;
      userPhone = user?.phone ?? '';
      if (userPhone.isNotEmpty) {
        // تنسيق الرقم: 966500000001 → +966 500 000 001
        userPhone = '+$userPhone';
      }
    } catch (e) {
      // Display-only; if Supabase auth isn't ready we simply show an empty phone.
      debugPrint('[StoreSelect] Failed to read current user phone: $e');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // معلومات النص
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile)
              Text(
                l10n.loggedInAs,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                userPhone.isNotEmpty ? userPhone : '---',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: isMobile ? 8 : 12),
        // الأفاتار
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(avatarSize * 0.25),
          ),
          child: Center(
            child: Text(
              'MA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 11 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: TextStyle(
        color: isDarkMode ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: l10n.searchForBranch,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.mdl,
          vertical: AlhaiSpacing.md,
        ),
      ),
    );
  }

  Widget _buildStoresList(bool isDarkMode) {
    // حالة التحميل
    if (_isLoadingStores) {
      return const Center(child: CircularProgressIndicator());
    }

    // حالة الخطأ
    if (_storesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDarkMode ? Colors.red.shade300 : Colors.red.shade400,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              AppLocalizations.of(context).errorOccurred,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xl),
              child: Text(
                _storesError!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade300),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            TextButton.icon(
              onPressed: _loadStores,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      );
    }

    if (_filteredStores.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.lg,
        vertical: AlhaiSpacing.md,
      ),
      itemCount: _filteredStores.length + 1,
      itemBuilder: (context, index) {
        if (index == _filteredStores.length) {
          return _buildAddBranchButton(isDarkMode);
        }

        final store = _filteredStores[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
          child: _buildStoreCard(store, isDarkMode),
        );
      },
    );
  }

  Widget _buildStoreCard(BranchData store, bool isDarkMode) {
    final isSelected = store.id == _selectedStoreId;
    final isSyncingThis = isSelected && _isSyncing;
    final isOpen = store.status == BranchStatus.open;
    final l10n = AppLocalizations.of(context);

    // ألوان الأيقونة حسب النوع
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    switch (store.type) {
      case BranchType.store:
        iconBgColor = AppColors.primary.withValues(alpha: 0.1);
        iconColor = AppColors.primary;
        icon = Icons.storefront_rounded;
        break;
      case BranchType.warehouse:
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        icon = Icons.warehouse_rounded;
        break;
      case BranchType.kiosk:
        iconBgColor = Colors.purple.withValues(alpha: 0.1);
        iconColor = Colors.purple;
        icon = Icons.point_of_sale_rounded;
        break;
      case BranchType.restaurant:
        iconBgColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.red;
        icon = Icons.restaurant_rounded;
        break;
      case BranchType.salon:
        iconBgColor = Colors.pink.withValues(alpha: 0.1);
        iconColor = Colors.pink;
        icon = Icons.content_cut_rounded;
        break;
    }

    return InkWell(
      onTap: _isSyncing ? null : () => _selectStore(store),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isDarkMode
              ? (isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05))
              : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Theme.of(context).colorScheme.surfaceContainerLowest),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode
                      ? Colors.white12
                      : Theme.of(context).colorScheme.outlineVariant),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // سهم الاختيار أو مؤشر المزامنة
            if (isSyncingThis)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.chevron_left,
                color: isDarkMode
                    ? Colors.white38
                    : Theme.of(context).colorScheme.outlineVariant,
              ),

            const SizedBox(width: AlhaiSpacing.sm),

            // حالة الفرع
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOpen
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppColors.success
                          : Theme.of(context).disabledColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOpen
                        ? l10n.openNow
                        : (store.closedUntil != null
                              ? l10n.closedOpensAt(store.closedUntil!)
                              : l10n.branchClosed),
                    style: TextStyle(
                      color: isOpen
                          ? AppColors.success
                          : Theme.of(context).disabledColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // معلومات الفرع
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          store.address ?? '',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white54
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDarkMode
                            ? Colors.white38
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AlhaiSpacing.md),

            // الأيقونة
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBranchButton(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: AlhaiSpacing.xs),
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.comingSoon),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.mdl),
          side: BorderSide(
            color: isDarkMode
                ? Colors.white24
                : Theme.of(context).colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              l10n.addBranch,
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDarkMode ? Colors.white24 : AppColors.textTertiary,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            AppLocalizations.of(context).noResultsFoundSearch,
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white12 : Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // روابط
          Wrap(
            spacing: 12,
            children: [
              _buildFooterLink(
                l10n.technicalSupport,
                Icons.headset_mic_outlined,
                isDarkMode,
              ),
              _buildFooterLink(
                l10n.privacyPolicy,
                Icons.shield_outlined,
                isDarkMode,
              ),
            ],
          ),
          // حقوق النشر
          Text(
            '© Al-HAI POS v2.4.0 2026',
            style: TextStyle(
              color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, IconData icon, bool isDarkMode) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs,
          vertical: AlhaiSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
