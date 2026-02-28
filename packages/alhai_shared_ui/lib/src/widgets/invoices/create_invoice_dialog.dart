/// Create Invoice Dialog
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class CreateInvoiceDialog extends StatelessWidget {
  const CreateInvoiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isWide = !context.isMobile;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: isWide ? 100 : 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.newInvoice, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer
                    Text(l10n.selectCustomer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'general',
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurfaceVariant),
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                          dropdownColor: colorScheme.surface,
                          items: [
                            DropdownMenuItem(value: 'general', child: Row(children: [Icon(Icons.person_outline, size: 18, color: colorScheme.onSurfaceVariant), const SizedBox(width: 8), Text(l10n.cashCustomerGeneral)])),
                          ],
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.productsSection, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                        TextButton(onPressed: () {}, child: Text(l10n.addProductToInvoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerLowest),
                        headingTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                        dataTextStyle: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                        columnSpacing: 16,
                        columns: [
                          DataColumn(label: Text(l10n.productCol)),
                          DataColumn(label: Text(l10n.quantityCol)),
                          DataColumn(label: Text(l10n.priceCol)),
                          const DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('\u0637\u0645\u0627\u0637\u0645 (1KG)', style: TextStyle(color: colorScheme.onSurface))),
                            DataCell(Text('2', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
                            DataCell(Text('5.00', style: TextStyle(color: colorScheme.onSurface))),
                            DataCell(IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error))),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment & Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.paymentMethod, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outlineVariant)),
                                child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: 'cash', isExpanded: true, style: TextStyle(fontSize: 14, color: colorScheme.onSurface), dropdownColor: colorScheme.surface, items: const [DropdownMenuItem(value: 'cash', child: Text('\u0646\u0642\u062F\u0627\u064B')), DropdownMenuItem(value: 'card', child: Text('\u0628\u0637\u0627\u0642\u0629'))], onChanged: (v) {})),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.dueDate, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outlineVariant)),
                                child: Row(children: [
                                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text('2026-02-15', style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text(l10n.invoiceTotal, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    Text('10.00 \u0631.\u0633', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  ]),
                  Row(children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: colorScheme.onSurface, side: BorderSide(color: colorScheme.outlineVariant), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      child: Text(l10n.saveInvoice),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
