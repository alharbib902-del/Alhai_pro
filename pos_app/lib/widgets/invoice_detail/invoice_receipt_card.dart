import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../screens/invoices/invoice_detail_screen.dart';

class InvoiceReceiptCard extends StatelessWidget {
  final InvoiceDetailData invoice;
  final bool isDark;
  final Function(String) onCopyId;

  const InvoiceReceiptCard({super.key, required this.invoice, required this.isDark, required this.onCopyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Status Banner
          _buildStatusBanner(l10n),
          // Receipt Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Store Header with logo
                _buildStoreHeader(l10n),
                const SizedBox(height: 24),
                // Gradient divider
                Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border, Colors.transparent]))),
                const SizedBox(height: 20),
                // Simplified Tax Invoice title
                Text(l10n.simplifiedTaxInvoice, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFD1D5DB) : AppColors.textPrimary)),
                const SizedBox(height: 20),
                // Invoice info grid (number + date)
                _buildInfoGrid(l10n),
                const SizedBox(height: 16),
                // Cashier
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.cashierLabel, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(invoice.cashier, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Dashed divider
                _dashedDivider(),
                const SizedBox(height: 20),
                // Items table
                _buildItemsTable(l10n),
                const SizedBox(height: 20),
                // Dashed divider
                _dashedDivider(),
                const SizedBox(height: 20),
                // Totals
                _buildTotals(l10n),
                const SizedBox(height: 20),
                // Grand total box
                _buildGrandTotal(l10n),
                const SizedBox(height: 20),
                // Dashed divider
                _dashedDivider(),
                const SizedBox(height: 20),
                // Payment details
                _buildPaymentDetails(l10n),
                const SizedBox(height: 24),
                // QR Code section
                _buildQRSection(l10n),
                const SizedBox(height: 16),
                // VAT note
                Text(l10n.includesVat15, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                const SizedBox(height: 16),
                // Thank you
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border))),
                  child: Column(
                    children: [
                      Text(l10n.thankYouVisit, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(l10n.wishNiceDay, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(AppLocalizations l10n) {
    Color bgColor;
    Color textColor;
    Color dotColor;
    IconData icon;
    String title;
    String subtitle;
    String badge;

    if (invoice.status == 'voided') {
      bgColor = isDark ? Colors.grey.withValues(alpha: 0.1) : const Color(0xFFF9FAFB);
      textColor = AppColors.grey500;
      dotColor = AppColors.grey500;
      icon = Icons.block_rounded;
      title = l10n.voidedStatus;
      subtitle = l10n.invoiceVoided;
      badge = l10n.voidedStatus;
    } else if (invoice.status == 'pending') {
      bgColor = isDark ? AppColors.warning.withValues(alpha: 0.1) : const Color(0xFFFFFBEB);
      textColor = AppColors.warning;
      dotColor = AppColors.warning;
      icon = Icons.access_time_rounded;
      title = l10n.pendingStatus;
      subtitle = l10n.pendingStatus;
      badge = l10n.pendingStatus;
    } else {
      bgColor = isDark ? AppColors.success.withValues(alpha: 0.1) : const Color(0xFFF0FDF4);
      textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
      dotColor = AppColors.success;
      icon = Icons.check_rounded;
      title = l10n.paidSuccessfully;
      subtitle = l10n.amountReceivedFull;
      badge = l10n.completedStatus;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: dotColor.withValues(alpha: 0.2))),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor.withValues(alpha: isDark ? 0.2 : 0.15)),
            child: Icon(icon, size: 20, color: textColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: dotColor.withValues(alpha: isDark ? 0.2 : 0.15),
              border: Border.all(color: dotColor.withValues(alpha: 0.3)),
            ),
            child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // Store logo
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Center(child: Text('M', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
        const SizedBox(height: 16),
        Text(l10n.storeName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(l10n.storeAddress, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        const SizedBox(height: 4),
        Text('VAT: ${invoice.vatNumber}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontFamily: 'Source Code Pro')),
      ],
    );
  }

  Widget _buildInfoGrid(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Invoice number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.invoiceNumber, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(invoice.number, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: 'Source Code Pro', letterSpacing: 1.2)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onCopyId(invoice.number),
                    borderRadius: BorderRadius.circular(4),
                    child: Icon(Icons.copy_rounded, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          // Date & time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.dateAndTime, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const SizedBox(height: 4),
              Text('${invoice.date} - ${invoice.time}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(AppLocalizations l10n) {
    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(l10n.itemCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted))),
              Expanded(child: Center(child: Text(l10n.quantityColDetail, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)))),
              Expanded(child: Center(child: Text(l10n.priceColDetail, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)))),
              Expanded(child: Align(alignment: AlignmentDirectional.centerEnd, child: Text(l10n.totalCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)))),
            ],
          ),
        ),
        Container(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        // Item rows
        ...invoice.items.map((item) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.5)))),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(l10n.skuLabel(item.sku), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontFamily: 'Source Code Pro')),
                  ],
                ),
              ),
              Expanded(child: Center(child: Text('x${item.quantity}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)))),
              Expanded(child: Center(child: Text(item.price.toStringAsFixed(2), style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)))),
              Expanded(child: Align(alignment: AlignmentDirectional.centerEnd, child: Text(item.total.toStringAsFixed(2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: 'Source Code Pro')))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTotals(AppLocalizations l10n) {
    return Column(
      children: [
        // Subtotal
        _totalRow(l10n.subtotalLabel, '${invoice.subtotal.toStringAsFixed(2)} ${l10n.sarCurrency}', false, false),
        const SizedBox(height: 10),
        // Discount
        if (invoice.discount > 0) ...[
          _totalRow(l10n.discountVip, '-${invoice.discount.toStringAsFixed(2)} ${l10n.sarCurrency}', false, true),
          const SizedBox(height: 10),
        ],
        // VAT
        _totalRow(l10n.vatLabel, '${invoice.vat.toStringAsFixed(2)} ${l10n.sarCurrency}', false, false),
      ],
    );
  }

  Widget _totalRow(String label, String value, bool isBold, bool isDiscount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDiscount ? AppColors.success : (isDark ? AppColors.textMutedDark : AppColors.textMuted))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontFamily: 'Source Code Pro', color: isDiscount ? AppColors.success : (isDark ? Colors.white : AppColors.textPrimary))),
      ],
    );
  }

  Widget _buildGrandTotal(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.grandTotal, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text('${invoice.total.toStringAsFixed(2)} ${l10n.sarCurrency}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Source Code Pro')),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(AppLocalizations l10n) {
    IconData payIcon;
    Color payColor;
    String payLabel;

    switch (invoice.paymentMethod) {
      case 'card':
        payIcon = Icons.credit_card;
        payColor = AppColors.info;
        payLabel = l10n.visaEnding(invoice.paymentDetails);
        break;
      case 'cash':
        payIcon = Icons.payments_outlined;
        payColor = AppColors.success;
        payLabel = l10n.cashPayment;
        break;
      default:
        payIcon = Icons.account_balance_wallet;
        payColor = const Color(0xFF8B5CF6);
        payLabel = l10n.walletPayment;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.paymentMethodLabel, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(payIcon, size: 18, color: payColor),
                  const SizedBox(width: 8),
                  Text(payLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.amountPaidLabel, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const SizedBox(height: 6),
              Text('${invoice.amountPaid.toStringAsFixed(2)} ${l10n.sarCurrency}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: 'Source Code Pro')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          // QR placeholder
          Container(
            width: 140, height: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
            ),
            child: const Center(child: Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),
          Text(l10n.zatcaElectronic, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(l10n.scanToVerify, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) => SizedBox(width: dashWidth, height: 1.5, child: DecoratedBox(decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)))),
        );
      },
    );
  }
}
