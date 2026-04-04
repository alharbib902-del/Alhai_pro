/// Receipt data model for ESC/POS printing
///
/// Contains all the structured data needed to build a thermal receipt.
library;

/// A single item on the receipt
class ReceiptItem {
  final String name;
  final double quantity;
  final double unitPrice;
  final double total;
  final String? barcode;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.barcode,
  });
}

/// Store information header
class ReceiptStoreInfo {
  final String name;
  final String address;
  final String phone;
  final String vatNumber;
  final String? crNumber;

  const ReceiptStoreInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.vatNumber,
    this.crNumber,
  });

  static const defaultStore = ReceiptStoreInfo(
    name: '',
    address: '',
    phone: '',
    vatNumber: '',
  );
}

/// Complete receipt data
class ReceiptData {
  final String receiptNumber;
  final DateTime dateTime;
  final String cashierName;
  final String? customerName;
  final String? customerId;

  final List<ReceiptItem> items;

  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  final String paymentMethod;
  final double? amountReceived;
  final double? changeAmount;

  final ReceiptStoreInfo store;

  /// Base64-encoded ZATCA QR data
  final String? zatcaQrData;

  /// Optional note printed at the bottom
  final String? note;

  const ReceiptData({
    required this.receiptNumber,
    required this.dateTime,
    this.cashierName = '',
    this.customerName,
    this.customerId,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.store = ReceiptStoreInfo.defaultStore,
    this.zatcaQrData,
    this.note,
  });
}
