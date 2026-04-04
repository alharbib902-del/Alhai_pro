/// شاشة إعدادات نقطة البيع - POS Settings Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

const String _kProductDisplay = 'pos_product_display';
const String _kGridColumns = 'pos_grid_columns';
const String _kShowProductImages = 'pos_show_product_images';
const String _kShowProductPrices = 'pos_show_product_prices';
const String _kShowStockLevel = 'pos_show_stock_level';
const String _kAutoFocusBarcode = 'pos_auto_focus_barcode';
const String _kAllowNegativeStock = 'pos_allow_negative_stock';
const String _kConfirmBeforeDelete = 'pos_confirm_before_delete';
const String _kShowItemNotes = 'pos_show_item_notes';
const String _kEnableCashPayment = 'pos_enable_cash_payment';
const String _kEnableCardPayment = 'pos_enable_card_payment';
const String _kEnableCreditPayment = 'pos_enable_credit_payment';
const String _kEnableBankTransfer = 'pos_enable_bank_transfer';
const String _kEnableSplitPayment = 'pos_enable_split_payment';
const String _kRequireCustomerForCredit = 'pos_require_customer_for_credit';
const String _kAutoPrintReceipt = 'pos_auto_print';
const String _kEmailReceipt = 'pos_email_receipt';
const String _kSmsReceipt = 'pos_sms_receipt';
const String _kReceiptCopies = 'pos_receipt_copies';
const String _kEnableHoldInvoice = 'pos_enable_hold_invoice';
const String _kMaxHoldInvoices = 'pos_max_hold_invoices';
const String _kEnableQuickSale = 'pos_quick_mode';
const String _kSoundEffects = 'pos_sound_effects';
const String _kHapticFeedback = 'pos_haptic_feedback';

class PosSettingsScreen extends ConsumerStatefulWidget {
  const PosSettingsScreen({super.key});

  @override
  ConsumerState<PosSettingsScreen> createState() => _PosSettingsScreenState();
}

class _PosSettingsScreenState extends ConsumerState<PosSettingsScreen> {
  String _productDisplay = 'grid';
  int _gridColumns = 4;
  bool _showProductImages = true;
  bool _showProductPrices = true;
  bool _showStockLevel = true;
  bool _autoFocusBarcode = true;
  bool _allowNegativeStock = false;
  bool _confirmBeforeDelete = true;
  bool _showItemNotes = true;
  bool _enableCashPayment = true;
  bool _enableCardPayment = true;
  bool _enableCreditPayment = true;
  bool _enableBankTransfer = true;
  bool _enableSplitPayment = true;
  bool _requireCustomerForCredit = true;
  bool _autoPrintReceipt = true;
  bool _emailReceipt = false;
  bool _smsReceipt = false;
  int _receiptCopies = 1;
  bool _enableHoldInvoice = true;
  int _maxHoldInvoices = 10;
  bool _enableQuickSale = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'pos_');
      if (mounted) {
        setState(() {
          _productDisplay = settings[_kProductDisplay] ?? 'grid';
          _gridColumns = int.tryParse(settings[_kGridColumns] ?? '') ?? 4;
          _showProductImages = settings[_kShowProductImages] != 'false';
          _showProductPrices = settings[_kShowProductPrices] != 'false';
          _showStockLevel = settings[_kShowStockLevel] != 'false';
          _autoFocusBarcode = settings[_kAutoFocusBarcode] != 'false';
          _allowNegativeStock = settings[_kAllowNegativeStock] == 'true';
          _confirmBeforeDelete = settings[_kConfirmBeforeDelete] != 'false';
          _showItemNotes = settings[_kShowItemNotes] != 'false';
          _enableCashPayment = settings[_kEnableCashPayment] != 'false';
          _enableCardPayment = settings[_kEnableCardPayment] != 'false';
          _enableCreditPayment = settings[_kEnableCreditPayment] != 'false';
          _enableBankTransfer = settings[_kEnableBankTransfer] != 'false';
          _enableSplitPayment = settings[_kEnableSplitPayment] != 'false';
          _requireCustomerForCredit =
              settings[_kRequireCustomerForCredit] != 'false';
          _autoPrintReceipt = settings[_kAutoPrintReceipt] != 'false';
          _emailReceipt = settings[_kEmailReceipt] == 'true';
          _smsReceipt = settings[_kSmsReceipt] == 'true';
          _receiptCopies = int.tryParse(settings[_kReceiptCopies] ?? '') ?? 1;
          _enableHoldInvoice = settings[_kEnableHoldInvoice] != 'false';
          _maxHoldInvoices =
              int.tryParse(settings[_kMaxHoldInvoices] ?? '') ?? 10;
          _enableQuickSale = settings[_kEnableQuickSale] != 'false';
          _soundEffects = settings[_kSoundEffects] != 'false';
          _hapticFeedback = settings[_kHapticFeedback] != 'false';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Column(children: [
        AppHeader(
            title: l10n.posSettings,
            onMenuTap:
                isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager),
        const Expanded(child: Center(child: CircularProgressIndicator())),
      ]);
    }

    return Column(children: [
      AppHeader(
          title: l10n.posSettings,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager),
      Expanded(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
        child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
      )),
    ]);
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark,
      AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildPageHeader(isDark, l10n),
      const SizedBox(height: AlhaiSpacing.mdl),
      _buildDisplaySettings(isDark, l10n),
      _buildCartSettings(isDark, l10n),
      _buildPaymentSettings(isDark, l10n),
      _buildReceiptSettings(isDark, l10n),
      _buildAdvancedSettings(isDark, l10n),
      const SizedBox(height: AlhaiSpacing.md),
      SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          )),
    ]);
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(children: [
      IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.arrow_forward_rounded
              : Icons.arrow_back_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        tooltip: l10n.back,
      ),
      const SizedBox(width: AlhaiSpacing.xs),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.point_of_sale_rounded,
              color: AppColors.info, size: 24)),
      const SizedBox(width: AlhaiSpacing.sm),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.posSettings,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        Text(l10n.posSettingsSubtitle,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ]);
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
                AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
                  child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: AppSizes.md),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
            ])),
        ...children,
      ]),
    );
  }

  Widget _buildDisplaySettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.displaySettings, Icons.grid_view, AppColors.primary, isDark, [
      ListTile(
          title: Text(l10n.productDisplayMode,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.productDisplayModeDesc),
          trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'grid', icon: Icon(Icons.grid_view, size: 18)),
                ButtonSegment(value: 'list', icon: Icon(Icons.list, size: 18)),
              ],
              selected: {
                _productDisplay
              },
              onSelectionChanged: (v) =>
                  setState(() => _productDisplay = v.first))),
      if (_productDisplay == 'grid') ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
            title: Text(l10n.gridColumns,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.nColumns(_gridColumns)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
            ])),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
          title: Text(l10n.showProductImages,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.showProductImagesDesc),
          value: _showProductImages,
          onChanged: (v) => setState(() => _showProductImages = v)),
      SwitchListTile(
          title: Text(l10n.showPrices,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.showPricesDesc),
          value: _showProductPrices,
          onChanged: (v) => setState(() => _showProductPrices = v)),
      SwitchListTile(
          title: Text(l10n.showStockLevel,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.showStockLevelDesc),
          value: _showStockLevel,
          onChanged: (v) => setState(() => _showStockLevel = v)),
      const SizedBox(height: AlhaiSpacing.xs),
    ]);
  }

  Widget _buildCartSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.cartSettings, Icons.shopping_cart, AppColors.success, isDark, [
      SwitchListTile(
          title: Text(l10n.autoFocusBarcode,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.autoFocusBarcodeDesc),
          value: _autoFocusBarcode,
          onChanged: (v) => setState(() => _autoFocusBarcode = v)),
      SwitchListTile(
          title: Text(l10n.allowNegativeStock,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.allowNegativeStockDesc),
          value: _allowNegativeStock,
          onChanged: (v) => setState(() => _allowNegativeStock = v)),
      SwitchListTile(
          title: Text(l10n.confirmBeforeDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.confirmBeforeDeleteDesc),
          value: _confirmBeforeDelete,
          onChanged: (v) => setState(() => _confirmBeforeDelete = v)),
      SwitchListTile(
          title: Text(l10n.showItemNotes,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.showItemNotesDesc),
          value: _showItemNotes,
          onChanged: (v) => setState(() => _showItemNotes = v)),
      const SizedBox(height: AlhaiSpacing.xs),
    ]);
  }

  Widget _buildPaymentSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.paymentMethods, Icons.payment, AppColors.info, isDark, [
      SwitchListTile(
          title: Text(l10n.cashPaymentOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          secondary: const Icon(Icons.money),
          value: _enableCashPayment,
          onChanged: (v) => setState(() => _enableCashPayment = v)),
      SwitchListTile(
          title: Text(l10n.cardPaymentOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          secondary: const Icon(Icons.credit_card),
          value: _enableCardPayment,
          onChanged: (v) => setState(() => _enableCardPayment = v)),
      SwitchListTile(
          title: Text(l10n.creditPaymentOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          secondary: const Icon(Icons.schedule),
          value: _enableCreditPayment,
          onChanged: (v) => setState(() => _enableCreditPayment = v)),
      SwitchListTile(
          title: Text(l10n.bankTransferOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          secondary: const Icon(Icons.account_balance),
          value: _enableBankTransfer,
          onChanged: (v) => setState(() => _enableBankTransfer = v)),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
          title: Text(l10n.allowSplitPayment,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.allowSplitPaymentDesc),
          value: _enableSplitPayment,
          onChanged: (v) => setState(() => _enableSplitPayment = v)),
      if (_enableCreditPayment)
        SwitchListTile(
            title: Text(l10n.requireCustomerForCredit,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.requireCustomerForCreditDesc),
            value: _requireCustomerForCredit,
            onChanged: (v) => setState(() => _requireCustomerForCredit = v)),
      const SizedBox(height: AlhaiSpacing.xs),
    ]);
  }

  Widget _buildReceiptSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.receiptSettings, Icons.receipt, AppColors.warning, isDark, [
      SwitchListTile(
          title: Text(l10n.autoPrintReceipt,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.autoPrintReceiptDesc),
          value: _autoPrintReceipt,
          onChanged: (v) => setState(() => _autoPrintReceipt = v)),
      if (_autoPrintReceipt) ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
            title: Text(l10n.receiptCopies,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
            ])),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
          title: Text(l10n.emailReceiptOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.emailReceiptDesc),
          secondary: const Icon(Icons.email),
          value: _emailReceipt,
          onChanged: (v) => setState(() => _emailReceipt = v)),
      SwitchListTile(
          title: Text(l10n.smsReceiptOption,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.smsReceiptDesc),
          secondary: const Icon(Icons.sms),
          value: _smsReceipt,
          onChanged: (v) => setState(() => _smsReceipt = v)),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
          leading: const Icon(Icons.print),
          title: Text(l10n.printerSettings,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.printerSettingsDesc),
          trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.push(AppRoutes.settingsPrinter)),
      ListTile(
          leading: const Icon(Icons.design_services),
          title: Text(l10n.receiptDesign,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.receiptDesignDesc),
          trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.push(AppRoutes.settingsReceipt)),
      const SizedBox(height: AlhaiSpacing.xs),
    ]);
  }

  Widget _buildAdvancedSettings(bool isDark, AppLocalizations l10n) {
    return _buildSettingsGroup(
        l10n.advancedSettings, Icons.tune, AppColors.grey600, isDark, [
      SwitchListTile(
          title: Text(l10n.allowHoldInvoices,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.allowHoldInvoicesDesc),
          value: _enableHoldInvoice,
          onChanged: (v) => setState(() => _enableHoldInvoice = v)),
      if (_enableHoldInvoice)
        ListTile(
            title: Text(l10n.maxHoldInvoices,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
            ])),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
          title: Text(l10n.quickSaleMode,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.quickSaleModeDesc),
          value: _enableQuickSale,
          onChanged: (v) => setState(() => _enableQuickSale = v)),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
          title: Text(l10n.soundEffects,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.soundEffectsDesc),
          secondary: const Icon(Icons.volume_up),
          value: _soundEffects,
          onChanged: (v) => setState(() => _soundEffects = v)),
      SwitchListTile(
          title: Text(l10n.hapticFeedback,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.hapticFeedbackDesc),
          secondary: const Icon(Icons.vibration),
          value: _hapticFeedback,
          onChanged: (v) => setState(() => _hapticFeedback = v)),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
          leading: const Icon(Icons.keyboard),
          title: Text(l10n.keyboardShortcuts,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(l10n.customizeShortcuts),
          trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
          onTap: _showKeyboardShortcuts),
      ListTile(
          leading: const Icon(Icons.restore, color: AppColors.error),
          title: Text(l10n.resetSettings,
              style: const TextStyle(color: AppColors.error)),
          subtitle: Text(l10n.resetSettingsDesc),
          onTap: _showResetConfirmation),
      const SizedBox(height: AlhaiSpacing.xs),
    ]);
  }

  Future<void> _saveSettings() async {
    HapticFeedback.heavyImpact();
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final db = getIt<AppDatabase>();
    try {
      await saveSettingsBatch(
          db: db,
          storeId: storeId,
          settings: {
            _kProductDisplay: _productDisplay,
            _kGridColumns: _gridColumns.toString(),
            _kShowProductImages: _showProductImages.toString(),
            _kShowProductPrices: _showProductPrices.toString(),
            _kShowStockLevel: _showStockLevel.toString(),
            _kAutoFocusBarcode: _autoFocusBarcode.toString(),
            _kAllowNegativeStock: _allowNegativeStock.toString(),
            _kConfirmBeforeDelete: _confirmBeforeDelete.toString(),
            _kShowItemNotes: _showItemNotes.toString(),
            _kEnableCashPayment: _enableCashPayment.toString(),
            _kEnableCardPayment: _enableCardPayment.toString(),
            _kEnableCreditPayment: _enableCreditPayment.toString(),
            _kEnableBankTransfer: _enableBankTransfer.toString(),
            _kEnableSplitPayment: _enableSplitPayment.toString(),
            _kRequireCustomerForCredit: _requireCustomerForCredit.toString(),
            _kAutoPrintReceipt: _autoPrintReceipt.toString(),
            _kEmailReceipt: _emailReceipt.toString(),
            _kSmsReceipt: _smsReceipt.toString(),
            _kReceiptCopies: _receiptCopies.toString(),
            _kEnableHoldInvoice: _enableHoldInvoice.toString(),
            _kMaxHoldInvoices: _maxHoldInvoices.toString(),
            _kEnableQuickSale: _enableQuickSale.toString(),
            _kSoundEffects: _soundEffects.toString(),
            _kHapticFeedback: _hapticFeedback.toString(),
          },
          ref: ref);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.settingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        final l10nErr = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${l10nErr.errorSaving}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _showKeyboardShortcuts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(l10n.keyboardShortcuts),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                _buildShortcutRow('F1', l10n.shortcutSearchProduct, isDark),
                _buildShortcutRow('F2', l10n.shortcutSearchCustomer, isDark),
                _buildShortcutRow('F3', l10n.shortcutHoldInvoice, isDark),
                _buildShortcutRow('F4', l10n.shortcutFavorites, isDark),
                _buildShortcutRow('F8', l10n.shortcutApplyDiscount, isDark),
                _buildShortcutRow('F12', l10n.shortcutPayment, isDark),
                _buildShortcutRow('ESC', l10n.shortcutCancelBack, isDark),
                _buildShortcutRow('Delete', l10n.shortcutDeleteProduct, isDark),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close))
              ],
            ));
  }

  Widget _buildShortcutRow(String key, String action, bool isDark) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
              child: Text(key,
                  style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
          const SizedBox(width: AppSizes.md),
          Text(action),
        ]));
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(context);
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
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error),
                    child: Text(l10n.resetAction)),
              ],
            ));
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
    _saveSettings();
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.settingsReset),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating));
  }
}
