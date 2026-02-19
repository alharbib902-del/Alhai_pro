import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة قالب الإيصال
class ReceiptTemplateScreen extends ConsumerStatefulWidget {
  const ReceiptTemplateScreen({super.key});

  @override
  ConsumerState<ReceiptTemplateScreen> createState() =>
      _ReceiptTemplateScreenState();
}

class _ReceiptTemplateScreenState extends ConsumerState<ReceiptTemplateScreen> {
  static const _prefix = 'receipt_template_';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _headerController.text =
          prefs.getString('${_prefix}header') ?? _headerController.text;
      _footerController.text =
          prefs.getString('${_prefix}footer') ?? _footerController.text;
      _showLogo = prefs.getBool('${_prefix}show_logo') ?? _showLogo;
      _showStoreName =
          prefs.getBool('${_prefix}show_store_name') ?? _showStoreName;
      _showAddress = prefs.getBool('${_prefix}show_address') ?? _showAddress;
      _showPhone = prefs.getBool('${_prefix}show_phone') ?? _showPhone;
      _showVatNumber =
          prefs.getBool('${_prefix}show_vat_number') ?? _showVatNumber;
      _showDate = prefs.getBool('${_prefix}show_date') ?? _showDate;
      _showCashier = prefs.getBool('${_prefix}show_cashier') ?? _showCashier;
      _showBarcode = prefs.getBool('${_prefix}show_barcode') ?? _showBarcode;
      _showQrCode = prefs.getBool('${_prefix}show_qr_code') ?? _showQrCode;
      _paperSize = prefs.getString('${_prefix}paper_size') ?? _paperSize;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_prefix}header', _headerController.text);
      await prefs.setString('${_prefix}footer', _footerController.text);
      await prefs.setBool('${_prefix}show_logo', _showLogo);
      await prefs.setBool('${_prefix}show_store_name', _showStoreName);
      await prefs.setBool('${_prefix}show_address', _showAddress);
      await prefs.setBool('${_prefix}show_phone', _showPhone);
      await prefs.setBool('${_prefix}show_vat_number', _showVatNumber);
      await prefs.setBool('${_prefix}show_date', _showDate);
      await prefs.setBool('${_prefix}show_cashier', _showCashier);
      await prefs.setBool('${_prefix}show_barcode', _showBarcode);
      await prefs.setBool('${_prefix}show_qr_code', _showQrCode);
      await prefs.setString('${_prefix}paper_size', _paperSize);

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
