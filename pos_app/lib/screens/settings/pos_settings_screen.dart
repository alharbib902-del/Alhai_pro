/// شاشة إعدادات نقطة البيع - POS Settings Screen
///
/// شاشة لإدارة إعدادات نقطة البيع
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات نقطة البيع
class PosSettingsScreen extends ConsumerStatefulWidget {
  const PosSettingsScreen({super.key});

  @override
  ConsumerState<PosSettingsScreen> createState() => _PosSettingsScreenState();
}

class _PosSettingsScreenState extends ConsumerState<PosSettingsScreen> {

  // إعدادات العرض
  String _productDisplay = 'grid';
  int _gridColumns = 4;
  bool _showProductImages = true;
  bool _showProductPrices = true;
  bool _showStockLevel = true;

  // إعدادات السلة
  bool _autoFocusBarcode = true;
  bool _allowNegativeStock = false;
  bool _confirmBeforeDelete = true;
  bool _showItemNotes = true;

  // إعدادات الدفع
  bool _enableCashPayment = true;
  bool _enableCardPayment = true;
  bool _enableCreditPayment = true;
  bool _enableBankTransfer = true;
  bool _enableSplitPayment = true;
  bool _requireCustomerForCredit = true;

  // إعدادات الإيصال
  bool _autoPrintReceipt = true;
  bool _emailReceipt = false;
  bool _smsReceipt = false;
  int _receiptCopies = 1;

  // إعدادات أخرى
  bool _enableHoldInvoice = true;
  int _maxHoldInvoices = 10;
  bool _enableQuickSale = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
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
                  title: l10n.posSettings,
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
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: 20),
        _buildDisplaySettings(isDark, l10n),
        _buildCartSettings(isDark, l10n),
        _buildPaymentSettings(isDark, l10n),
        _buildReceiptSettings(isDark, l10n),
        _buildAdvancedSettings(isDark, l10n),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_rounded),
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
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.point_of_sale_rounded,
              color: AppColors.info, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.posSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.posSettingsSubtitle,
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
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSizes.md),
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

  Widget _buildDisplaySettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.displaySettings, Icons.grid_view, AppColors.primary, isDark, [
      ListTile(
        title: Text(l10n.productDisplayMode,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.productDisplayModeDesc),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'grid', icon: Icon(Icons.grid_view, size: 18)),
            ButtonSegment(value: 'list', icon: Icon(Icons.list, size: 18)),
          ],
          selected: {_productDisplay},
          onSelectionChanged: (v) =>
              setState(() => _productDisplay = v.first),
        ),
      ),
      if (_productDisplay == 'grid') ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text(l10n.gridColumns,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          subtitle: Text(l10n.nColumns(_gridColumns)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _gridColumns > 2
                      ? () => setState(() => _gridColumns--)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_gridColumns', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _gridColumns < 6
                      ? () => setState(() => _gridColumns++)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text(l10n.showProductImages,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.showProductImagesDesc),
        value: _showProductImages,
        onChanged: (v) => setState(() => _showProductImages = v),
      ),
      SwitchListTile(
        title: Text(l10n.showPrices,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.showPricesDesc),
        value: _showProductPrices,
        onChanged: (v) => setState(() => _showProductPrices = v),
      ),
      SwitchListTile(
        title: Text(l10n.showStockLevel,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.showStockLevelDesc),
        value: _showStockLevel,
        onChanged: (v) => setState(() => _showStockLevel = v),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildCartSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.cartSettings, Icons.shopping_cart, AppColors.success, isDark, [
      SwitchListTile(
        title: Text(l10n.autoFocusBarcode,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.autoFocusBarcodeDesc),
        value: _autoFocusBarcode,
        onChanged: (v) => setState(() => _autoFocusBarcode = v),
      ),
      SwitchListTile(
        title: Text(l10n.allowNegativeStock,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.allowNegativeStockDesc),
        value: _allowNegativeStock,
        onChanged: (v) => setState(() => _allowNegativeStock = v),
      ),
      SwitchListTile(
        title: Text(l10n.confirmBeforeDelete,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.confirmBeforeDeleteDesc),
        value: _confirmBeforeDelete,
        onChanged: (v) => setState(() => _confirmBeforeDelete = v),
      ),
      SwitchListTile(
        title: Text(l10n.showItemNotes,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.showItemNotesDesc),
        value: _showItemNotes,
        onChanged: (v) => setState(() => _showItemNotes = v),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildPaymentSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.paymentMethods, Icons.payment, AppColors.info, isDark, [
      SwitchListTile(
        title: Text(l10n.cashPaymentOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.money),
        value: _enableCashPayment,
        onChanged: (v) => setState(() => _enableCashPayment = v),
      ),
      SwitchListTile(
        title: Text(l10n.cardPaymentOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.credit_card),
        value: _enableCardPayment,
        onChanged: (v) => setState(() => _enableCardPayment = v),
      ),
      SwitchListTile(
        title: Text(l10n.creditPaymentOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.schedule),
        value: _enableCreditPayment,
        onChanged: (v) => setState(() => _enableCreditPayment = v),
      ),
      SwitchListTile(
        title: Text(l10n.bankTransferOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.account_balance),
        value: _enableBankTransfer,
        onChanged: (v) => setState(() => _enableBankTransfer = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text(l10n.allowSplitPayment,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.allowSplitPaymentDesc),
        value: _enableSplitPayment,
        onChanged: (v) => setState(() => _enableSplitPayment = v),
      ),
      if (_enableCreditPayment)
        SwitchListTile(
          title: Text(l10n.requireCustomerForCredit,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          subtitle: Text(l10n.requireCustomerForCreditDesc),
          value: _requireCustomerForCredit,
          onChanged: (v) => setState(() => _requireCustomerForCredit = v),
        ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildReceiptSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.receiptSettings, Icons.receipt, AppColors.warning, isDark, [
      SwitchListTile(
        title: Text(l10n.autoPrintReceipt,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.autoPrintReceiptDesc),
        value: _autoPrintReceipt,
        onChanged: (v) => setState(() => _autoPrintReceipt = v),
      ),
      if (_autoPrintReceipt) ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text(l10n.receiptCopies,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _receiptCopies > 1
                      ? () => setState(() => _receiptCopies--)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_receiptCopies', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _receiptCopies < 3
                      ? () => setState(() => _receiptCopies++)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text(l10n.emailReceiptOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.emailReceiptDesc),
        secondary: const Icon(Icons.email),
        value: _emailReceipt,
        onChanged: (v) => setState(() => _emailReceipt = v),
      ),
      SwitchListTile(
        title: Text(l10n.smsReceiptOption,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.smsReceiptDesc),
        secondary: const Icon(Icons.sms),
        value: _smsReceipt,
        onChanged: (v) => setState(() => _smsReceipt = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
        leading: const Icon(Icons.print),
        title: Text(l10n.printerSettings,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.printerSettingsDesc),
        trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(AppRoutes.settingsPrinter),
      ),
      ListTile(
        leading: const Icon(Icons.design_services),
        title: Text(l10n.receiptDesign,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.receiptDesignDesc),
        trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(AppRoutes.settingsReceipt),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildAdvancedSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.advancedSettings, Icons.tune, AppColors.grey600, isDark, [
      SwitchListTile(
        title: Text(l10n.allowHoldInvoices,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.allowHoldInvoicesDesc),
        value: _enableHoldInvoice,
        onChanged: (v) => setState(() => _enableHoldInvoice = v),
      ),
      if (_enableHoldInvoice)
        ListTile(
          title: Text(l10n.maxHoldInvoices,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _maxHoldInvoices > 5
                      ? () => setState(() => _maxHoldInvoices -= 5)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_maxHoldInvoices', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _maxHoldInvoices < 50
                      ? () => setState(() => _maxHoldInvoices += 5)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text(l10n.quickSaleMode,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.quickSaleModeDesc),
        value: _enableQuickSale,
        onChanged: (v) => setState(() => _enableQuickSale = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text(l10n.soundEffects,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.soundEffectsDesc),
        secondary: const Icon(Icons.volume_up),
        value: _soundEffects,
        onChanged: (v) => setState(() => _soundEffects = v),
      ),
      SwitchListTile(
        title: Text(l10n.hapticFeedback,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.hapticFeedbackDesc),
        secondary: const Icon(Icons.vibration),
        value: _hapticFeedback,
        onChanged: (v) => setState(() => _hapticFeedback = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
        leading: const Icon(Icons.keyboard),
        title: Text(l10n.keyboardShortcuts,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Text(l10n.customizeShortcuts),
        trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
        onTap: _showKeyboardShortcuts,
      ),
      ListTile(
        leading: const Icon(Icons.restore, color: AppColors.error),
        title: Text(l10n.resetSettings,
            style: const TextStyle(color: AppColors.error)),
        subtitle: Text(l10n.resetSettingsDesc),
        onTap: _showResetConfirmation,
      ),
      const SizedBox(height: 8),
    ]);
  }

  void _saveSettings() {
    HapticFeedback.heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showKeyboardShortcuts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.keyboardShortcuts),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutRow('F1', l10n.shortcutSearchProduct, isDark),
              _buildShortcutRow('F2', l10n.shortcutSearchCustomer, isDark),
              _buildShortcutRow('F3', l10n.shortcutHoldInvoice, isDark),
              _buildShortcutRow('F4', l10n.shortcutFavorites, isDark),
              _buildShortcutRow('F8', l10n.shortcutApplyDiscount, isDark),
              _buildShortcutRow('F12', l10n.shortcutPayment, isDark),
              _buildShortcutRow('ESC', l10n.shortcutCancelBack, isDark),
              _buildShortcutRow('Delete', l10n.shortcutDeleteProduct, isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close)),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String key, String action, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: AppSizes.xs),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(key,
                style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: AppSizes.md),
          Text(action),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.resetAction),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _productDisplay = 'grid';
      _gridColumns = 4;
      _showProductImages = true;
      _showProductPrices = true;
      _showStockLevel = true;
      _autoFocusBarcode = true;
      _allowNegativeStock = false;
      _confirmBeforeDelete = true;
      _showItemNotes = true;
      _enableCashPayment = true;
      _enableCardPayment = true;
      _enableCreditPayment = true;
      _enableBankTransfer = true;
      _enableSplitPayment = true;
      _requireCustomerForCredit = true;
      _autoPrintReceipt = true;
      _emailReceipt = false;
      _smsReceipt = false;
      _receiptCopies = 1;
      _enableHoldInvoice = true;
      _maxHoldInvoices = 10;
      _enableQuickSale = true;
      _soundEffects = true;
      _hapticFeedback = true;
    });
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsReset),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
