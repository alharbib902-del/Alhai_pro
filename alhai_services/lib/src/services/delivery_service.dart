import 'package:alhai_core/alhai_core.dart';

/// خدمة التوصيل
/// متوافقة مع DeliveryRepository من alhai_core
class DeliveryService {
  final DeliveryRepository _deliveryRepo;

  DeliveryService(this._deliveryRepo);

  /// الحصول على طلبات التوصيل للسائق الحالي
  Future<List<Delivery>> getMyDeliveries() async {
    return await _deliveryRepo.getMyDeliveries();
  }

  /// الحصول على طلب توصيل بالـ ID
  Future<Delivery> getDelivery(String id) async {
    return await _deliveryRepo.getDelivery(id);
  }

  /// الحصول على التوصيل الخاص بطلب معين
  Future<Delivery?> getDeliveryByOrderId(String orderId) async {
    return await _deliveryRepo.getDeliveryByOrderId(orderId);
  }

  /// تحديث حالة التوصيل
  Future<Delivery> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status,
  ) async {
    return await _deliveryRepo.updateStatus(deliveryId, status);
  }

  /// تحديث موقع السائق
  Future<void> updateLocation({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    await _deliveryRepo.updateLocation(
      deliveryId: deliveryId,
      lat: latitude,
      lng: longitude,
    );
  }

  /// قبول طلب التوصيل
  Future<Delivery> acceptDelivery(String deliveryId) async {
    return await _deliveryRepo.acceptDelivery(deliveryId);
  }

  /// رفض طلب التوصيل
  Future<void> rejectDelivery(String deliveryId, {String? reason}) async {
    await _deliveryRepo.rejectDelivery(deliveryId, reason: reason);
  }

  /// تأكيد استلام الطلب من المتجر
  Future<Delivery> markPickedUp(String deliveryId) async {
    return await _deliveryRepo.markPickedUp(deliveryId);
  }

  /// تأكيد توصيل الطلب للعميل
  Future<Delivery> markDelivered(String deliveryId, {String? notes}) async {
    return await _deliveryRepo.markDelivered(deliveryId, notes: notes);
  }

  /// الإبلاغ عن مشكلة
  Future<void> reportIssue(String deliveryId, String issue) async {
    await _deliveryRepo.reportIssue(deliveryId, issue);
  }
}
