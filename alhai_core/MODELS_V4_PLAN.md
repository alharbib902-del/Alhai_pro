# 🔧 alhai_core v4.0.0 - Missing Models Documentation

**Version**: 4.0.0 (Planned)  
**Current**: v3.4.0  
**Date**: 2026-01-15

---

## 📋 New Models Needed (15)

### 1. Driver Models (5)

#### Driver
```dart
class Driver {
  final String id;
  final String userId; // FK to User
  final String phone;
  final String? vehicleType;
  final String? vehiclePlate;
  final DriverStatus status; // active, inactive, suspended
  final List<String> assignedStoreIds;
  final PaymentModel paymentModel; // salary, commission, hybrid
  final double? monthlySalary;
  final double? commissionRate;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

enum DriverStatus { active, inactive, suspended }
enum PaymentModel { salary, commission, hybrid }
```

#### Delivery
```dart
class Delivery {
  final String id;
  final String orderId; // FK
  final String driverId; // FK
  final DeliveryStatus status;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final double? driverLat;
  final double? driverLng;
  final DeliveryProof? proof;
}

enum DeliveryStatus {
  assigned,
  accepted,
  heading_to_pickup,
  arrived_at_pickup,
  picked_up,
  heading_to_customer,
  arrived_at_customer,
  delivered,
  failed
}
```

#### DeliveryProof
```dart
class DeliveryProof {
  final String id;
  final String deliveryId; // FK
  final String? code; // verification code
  final String? photoUrl;
  final String? signatureUrl;
  final double? gpsLat;
  final double? gpsLng;
  final DateTime createdAt;
}
```

#### Shift
```dart
class Shift {
  final String id;
  final String driverId; // FK
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart; // clock in
  final DateTime? actualEnd; // clock out
  final ShiftStatus status;
  final double? startLat;
  final double? startLng;
}

enum ShiftStatus { scheduled, active, completed, cancelled }
```

#### Earnings
```dart
class Earnings {
  final String id;
  final String driverId; // FK
  final DateTime period; // day/week/month
  final int totalDeliveries;
  final double basePay;
  final double commissions;
  final double bonuses;
  final double total;
  final EarningsType type;
}

enum EarningsType { daily, weekly, monthly }
```

---

### 2. Payment Models (2)

#### SplitPayment
```dart
class SplitPayment {
  final String id;
  final String saleId; // FK
  final double totalAmount;
  final List<PaymentPart> parts;
  final double remainingCredit;
  final DateTime createdAt;
  
  double get totalPaid => parts.fold(0, (sum, p) => sum + p.amount);
  bool get isComplete => totalPaid + remainingCredit >= totalAmount;
}
```

#### PaymentPart
```dart
class PaymentPart {
  final String id;
  final String splitPaymentId; // FK
  final PaymentMethod method; // cash, card, transfer
  final double amount;
  final String? cardType; // mada, visa, mastercard
  final String? last4Digits;
  final String? transactionId;
  final DateTime createdAt;
}
```

---

### 3. B2B Models (4)

#### Distributor
```dart
class Distributor {
  final String id;
  final String companyName;
  final String contactName;
  final String phone;
  final String email;
  final String? taxNumber;
  final DistributorStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
}

enum DistributorStatus { pending, approved, suspended }
```

#### DistributorProduct
```dart
class DistributorProduct {
  final String id;
  final String distributorId; // FK
  final String name;
  final String? sku;
  final double wholesalePrice;
  final int minOrderQuantity;
  final String unit; // كرتون، صندوق
  final String? category;
  final String? brand;
  final String? imageUrl;
  final bool inStock;
}
```

#### BulkOffer
```dart
class BulkOffer {
  final String id;
  final String distributorId; // FK
  final String title;
  final String? description;
  final List<OfferItem> products;
  final DateTime validFrom;
  final DateTime validUntil;
  final double? minOrderValue;
  final int? discountPercentage;
  final List<String>? targetStoreIds; // null = all
  final OfferStatus status;
}

class OfferItem {
  final String productId;
  final int quantity;
  final double specialPrice;
}

enum OfferStatus { draft, active, expired }
```

#### WholesaleOrder
```dart
class WholesaleOrder {
  final String id;
  final String orderNumber;
  final String storeId; // FK
  final String distributorId; // FK
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final WholesaleOrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? deliveredAt;
}

enum WholesaleOrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled
}

enum PaymentStatus { unpaid, partial, paid }
```

---

### 4. Platform Models (3)

#### Subscription
```dart
class Subscription {
  final String id;
  final String storeId; // FK
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final double monthlyFee;
  final bool autoRenew;
}

enum SubscriptionPlan { basic, pro, enterprise }
enum SubscriptionStatus { active, cancelled, expired }
```

#### PlatformFee
```dart
class PlatformFee {
  final String id;
  final String orderId; // FK (wholesale order)
  final FeeType type;
  final double amount;
  final double percentage; // e.g., 2%
  final DateTime createdAt;
  final bool collected;
}

enum FeeType { transaction, subscription, featured, premium }
```

#### AIReorderSuggestion
```dart
class AIReorderSuggestion {
  final String id;
  final String storeId; // FK
  final List<SuggestedItem> items;
  final String distributorId; // best distributor
  final double estimatedTotal;
  final double estimatedSavings;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SuggestionStatus status;
}

class SuggestedItem {
  final String productId;
  final int currentStock;
  final double dailySales;
  final int daysRemaining;
  final int suggestedQuantity;
  final double price;
}

enum SuggestionStatus { pending, accepted, rejected, expired }
```

---

## 📦 Migration Plan

### Phase 1: Driver Models (Week 1)
```bash
# Add 5 driver-related models
- Driver
- Delivery
- DeliveryProof
- Shift
- Earnings
```

### Phase 2: Payment Models (Week 1)
```bash
# Add split payment models
- SplitPayment
- PaymentPart
```

### Phase 3: B2B Models (Week 2)
```bash
# Add B2B models
- Distributor
- DistributorProduct
- BulkOffer
- WholesaleOrder
```

### Phase 4: Platform Models (Week 2)
```bash
# Add platform-level models
- Subscription
- PlatformFee
- AIReorderSuggestion
```

---

## 🚀 Implementation

### Update pubspec.yaml:
```yaml
name: alhai_core
version: 4.0.0

description: >
  Shared models and repositories for Alhai platform.
  Now includes driver, B2B, split payment, and platform models.
```

### Export all models:
```dart
// lib/alhai_core.dart
export 'src/models/driver.dart';
export 'src/models/delivery.dart';
export 'src/models/delivery_proof.dart';
export 'src/models/shift.dart';
export 'src/models/earnings.dart';
export 'src/models/split_payment.dart';
export 'src/models/payment_part.dart';
export 'src/models/distributor.dart';
export 'src/models/distributor_product.dart';
export 'src/models/bulk_offer.dart';
export 'src/models/wholesale_order.dart';
export 'src/models/subscription.dart';
export 'src/models/platform_fee.dart';
export 'src/models/ai_reorder_suggestion.dart';
```

---

**📅 Target Release**: v4.0.0 (Week 3)  
**✅ Status**: Specification Complete
