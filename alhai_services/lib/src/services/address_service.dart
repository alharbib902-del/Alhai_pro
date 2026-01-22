import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة العناوين
/// تستخدم من: customer_app
class AddressService {
  final AddressesRepository _addressesRepo;

  AddressService(this._addressesRepo);

  /// الحصول على جميع عناوين المستخدم
  Future<List<Address>> getAddresses() async {
    return await _addressesRepo.getAddresses();
  }

  /// الحصول على العنوان الافتراضي
  Future<Address?> getDefaultAddress() async {
    return await _addressesRepo.getDefaultAddress();
  }

  /// الحصول على عنوان بالـ ID
  Future<Address> getAddress(String id) async {
    return await _addressesRepo.getAddress(id);
  }

  /// إضافة عنوان جديد
  Future<Address> createAddress(CreateAddressParams params) async {
    return await _addressesRepo.createAddress(params);
  }

  /// تحديث عنوان
  Future<Address> updateAddress(String id, UpdateAddressParams params) async {
    return await _addressesRepo.updateAddress(id, params);
  }

  /// حذف عنوان
  Future<void> deleteAddress(String id) async {
    await _addressesRepo.deleteAddress(id);
  }

  /// تعيين عنوان كافتراضي
  Future<void> setDefaultAddress(String id) async {
    await _addressesRepo.setDefaultAddress(id);
  }
}
