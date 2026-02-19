import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';
import '../../widgets/layout/app_header.dart';

// مفاتيح إعدادات قالب الإيصال
const String _kReceiptHeader = 'receipt_header';
const String _kReceiptFooter = 'receipt_footer';
const String _kReceiptShowLogo = 'receipt_show_logo';
const String _kReceiptShowStoreName = 'receipt_show_store_name';
const String _kReceiptShowAddress = 'receipt_show_address';
const String _kReceiptShowPhone = 'receipt_show_phone';
const String _kReceiptShowVatNumber = 'receipt_show_vat_number';
const String _kReceiptShowDate = 'receipt_show_date';
const String _kReceiptShowCashier = 'receipt_show_cashier';
const String _kReceiptShowBarcode = 'receipt_show_barcode';
const String _kReceiptShowQrCode = 'receipt_show_qr_code';
const String _kReceiptPaperSize = 'receipt_paper_size';

/// شاشة قالب الإيصال
class ReceiptTemplateScreen extends ConsumerStatefulWidget {
  const ReceiptTemplateScreen({super.key});

  @override
  ConsumerState<ReceiptTemplateScreen> createState() =>
      _ReceiptTemplateScreenState();
}

class _ReceiptTemplateScreenState extends ConsumerState<ReceiptTemplateScreen> {
  final _headerController = TextEditingController(text: 'متجر الإيمان');
  final _footerController =
      TextEditingController(text: 'شكراً لزيارتكم - نتمنى لكم تجربة ممتعة');

  bool _showLogo = true;
  bool _showStoreName = true;
  bool _showAddress = true;
  bool _showPhone = true;
  bool _showVatNumber = true;
  bool _showDate = true;
  bool _showCashier = true;
  bool _showBarcode = true;
  bool _showQrCode = false;
  String _paperSize = '80mm';
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات بدلاً من SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'receipt_');

      if (mounted) {
        setState(() {
          if (settings[_kReceiptHeader] != null) {
            _headerController.text = settings[_kReceiptHeader]!;
          }
          if (settings[_kReceiptFooter] != null) {
            _footerController.text = settings[_kReceiptFooter]!;
          }
          _showLogo = settings[_kReceiptShowLogo] != 'false';
          _showStoreName = settings[_kReceiptShowStoreName] != 'false';
          _showAddress = settings[_kReceiptShowAddress] != 'false';
          _showPhone = settings[_kReceiptShowPhone] != 'false';
          _showVatNumber = settings[_kReceiptShowVatNumber] != 'false';
          _showDate = settings[_kReceiptShowDate] != 'false';
          _showCashier = settings[_kReceiptShowCashier] != 'false';
          _showBarcode = settings[_kReceiptShowBarcode] != 'false';
          _showQrCode = settings[_kReceiptShowQrCode] == 'true';
          _paperSize = settings[_kReceiptPaperSize] ?? '80mm';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ الإعدادات في قاعدة البيانات مع المزامنة
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kReceiptHeader: _headerController.text,
          _kReceiptFooter: _footerController.text,
          _kReceiptShowLogo: _showLogo.toString(),
          _kReceiptShowStoreName: _showStoreName.toString(),
          _kReceiptShowAddress: _showAddress.toString(),
          _kReceiptShowPhone: _showPhone.toString(),
          _kReceiptShowVatNumber: _showVatNumber.toString(),
          _kReceiptShowDate: _showDate.toString(),
          _kReceiptShowCashier: _showCashier.toString(),
          _kReceiptShowBarcode: _showBarcode.toString(),
          _kReceiptShowQrCode: _showQrCode.toString(),
          _kReceiptPaperSize: _paperSize,
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.receiptTemplateSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء الحفظ'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
        children: [
          AppHeader(
            title: l10n.receiptTemplateTitle,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return Column(
              children: [
                AppHeader(
                  title: l10n.receiptTemplateTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isDark, l10n),
                  ),
                ),
              ],
            );
  }
  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: 20),

        // Header / Footer
        _buildSettingsGroup(l10n.headerAndFooter, Icons.text_fields_rounded,
            const Color(0xFFEC4899), isDark, [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _headerController,
              decoration: InputDecoration(
                labelText: l10n.receiptTitleField,
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _footerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.footerText,
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),

        // Fields to show
        _buildSettingsGroup(l10n.displayedFields, Icons.list_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text(l10n.storeLogo,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.image),
            value: _showLogo,
            onChanged: (v) => setState(() => _showLogo = v),
          ),
          SwitchListTile(
            title: Text(l10n.storeName,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.store),
            value: _showStoreName,
            onChanged: (v) => setState(() => _showStoreName = v),
          ),
          SwitchListTile(
            title: Text(l10n.addressField,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.location_on),
            value: _showAddress,
            onChanged: (v) => setState(() => _showAddress = v),
          ),
          SwitchListTile(
            title: Text(l10n.phoneNumberField,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.phone),
            value: _showPhone,
            onChanged: (v) => setState(() => _showPhone = v),
          ),
          SwitchListTile(
            title: Text(l10n.vatNumberField,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.numbers),
            value: _showVatNumber,
            onChanged: (v) => setState(() => _showVatNumber = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l10n.dateAndTime,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.access_time),
            value: _showDate,
            onChanged: (v) => setState(() => _showDate = v),
          ),
          SwitchListTile(
            title: Text(l10n.cashierName,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.person),
            value: _showCashier,
            onChanged: (v) => setState(() => _showCashier = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l10n.invoiceBarcode,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.qr_code),
            value: _showBarcode,
            onChanged: (v) => setState(() => _showBarcode = v),
          ),
          SwitchListTile(
            title: Text(l10n.qrCodeField,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.qrCodeEInvoice),
            secondary: const Icon(Icons.qr_code_2),
            value: _showQrCode,
            onChanged: (v) => setState(() => _showQrCode = v),
          ),
          const SizedBox(height: 8),
        ]),

        // Paper size
        _buildSettingsGroup(l10n.paperSize, Icons.straighten_rounded,
            AppColors.success, isDark, [
          RadioListTile<String>(
            title: Text('80mm',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.standardSize),
            value: '80mm',
            // ignore: deprecated_member_use
            groupValue: _paperSize,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _paperSize = v!),
          ),
          RadioListTile<String>(
            title: Text('58mm',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.smallSize),
            value: '58mm',
            // ignore: deprecated_member_use
            groupValue: _paperSize,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _paperSize = v!),
          ),
          RadioListTile<String>(
            title: Text('A4',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.normalPrint),
            value: 'a4',
            // ignore: deprecated_member_use
            groupValue: _paperSize,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _paperSize = v!),
          ),
          const SizedBox(height: 8),
        ]),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: Color(0xFFEC4899), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.receiptTemplateTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.receiptTemplateSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
