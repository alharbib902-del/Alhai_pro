/// Test data constants for driver app integration tests.
///
/// Provides sample driver, delivery, order, and customer data
/// used across all driver app integration tests.
///
/// All Arabic text uses real Saudi naming conventions and addresses
/// consistent with the production app's locale.
library;

// ============================================================================
// DRIVER
// ============================================================================

/// Test driver ID.
const kTestDriverId = 'driver-001';

/// Test driver name (Arabic).
const kTestDriverName = 'عبدالله السائق';

/// Test driver phone (Saudi format).
const kTestDriverPhone = '0501234567';

// ============================================================================
// DELIVERY
// ============================================================================

/// Test delivery ID.
const kTestDeliveryId = 'delivery-001';

/// Test order ID.
const kTestOrderId = 'order-001';

/// Test customer name (Arabic).
const kTestCustomerName = 'محمد العميل';

/// Test customer delivery address (Arabic).
const kTestCustomerAddress = 'حي النزهة، شارع الأمير سلطان، الرياض';

/// OTP code for pickup verification.
const kTestPickupOtp = '1234';

// ============================================================================
// DELIVERY STATUS FLOW
// ============================================================================

/// The happy-path status progression for a delivery from assignment through
/// completion. Mirrors [DeliveryStatus] constants from driver_constants.dart
/// without importing the main lib.
const kDeliveryStatusAssigned = 'assigned';
const kDeliveryStatusAccepted = 'accepted';
const kDeliveryStatusHeadingToPickup = 'heading_to_pickup';
const kDeliveryStatusArrivedAtPickup = 'arrived_at_pickup';
const kDeliveryStatusPickedUp = 'picked_up';
const kDeliveryStatusHeadingToCustomer = 'heading_to_customer';
const kDeliveryStatusArrivedAtCustomer = 'arrived_at_customer';
const kDeliveryStatusDelivered = 'delivered';
const kDeliveryStatusFailed = 'failed';
const kDeliveryStatusCancelled = 'cancelled';

/// Complete happy-path delivery status flow from assigned to delivered.
const kDeliveryStatusFlow = [
  kDeliveryStatusAssigned,
  kDeliveryStatusAccepted,
  kDeliveryStatusHeadingToPickup,
  kDeliveryStatusArrivedAtPickup,
  kDeliveryStatusPickedUp,
  kDeliveryStatusHeadingToCustomer,
  kDeliveryStatusArrivedAtCustomer,
  kDeliveryStatusDelivered,
];

// ============================================================================
// SHIFT
// ============================================================================

/// Shift status constants mirroring ShiftStatus from driver_constants.dart.
const kShiftStatusActive = 'active';
const kShiftStatusEnded = 'ended';

// ============================================================================
// STORE / PICKUP
// ============================================================================

/// Test store name for pickup location.
const kTestStoreName = 'بقالة الحي - فرع الرئيسي';

/// Test store address for pickup.
const kTestStoreAddress = 'حي الربوة، طريق الملك عبدالعزيز، الرياض';
