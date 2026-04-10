import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------
class FakeAddressesRepository implements AddressesRepository {
  final List<Address> _addresses = [];
  String? _defaultAddressId;

  void seed(List<Address> addresses) => _addresses.addAll(addresses);

  @override
  Future<List<Address>> getAddresses() async => _addresses;

  @override
  Future<Address?> getDefaultAddress() async {
    if (_defaultAddressId == null) return null;
    final matches = _addresses.where((a) => a.id == _defaultAddressId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<Address> getAddress(String id) async {
    return _addresses.firstWhere((a) => a.id == id);
  }

  @override
  Future<Address> createAddress(CreateAddressParams params) async {
    final address = Address(
      id: 'addr-${_addresses.length + 1}',
      label: params.label,
      fullAddress: params.fullAddress,
      city: params.city,
      district: params.district,
      street: params.street,
      lat: params.lat,
      lng: params.lng,
      isDefault: _addresses.isEmpty,
    );
    _addresses.add(address);
    if (_addresses.length == 1) _defaultAddressId = address.id;
    return address;
  }

  @override
  Future<Address> updateAddress(String id, UpdateAddressParams params) async {
    final idx = _addresses.indexWhere((a) => a.id == id);
    _addresses[idx] = _addresses[idx].copyWith(
      label: params.label ?? _addresses[idx].label,
      fullAddress: params.fullAddress ?? _addresses[idx].fullAddress,
    );
    return _addresses[idx];
  }

  @override
  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    if (_defaultAddressId == id) _defaultAddressId = null;
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    _defaultAddressId = id;
  }
}

void main() {
  late AddressService addressService;
  late FakeAddressesRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAddressesRepository();
    addressService = AddressService(fakeRepo);
  });

  group('AddressService', () {
    test('should be created', () {
      expect(addressService, isNotNull);
    });

    group('getAddresses', () {
      test('should return empty list initially', () async {
        final addresses = await addressService.getAddresses();
        expect(addresses, isEmpty);
      });

      test('should return all addresses', () async {
        fakeRepo.seed([
          const Address(
            id: 'addr-1',
            label: 'Home',
            fullAddress: '123 Street, Riyadh',
            city: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isDefault: true,
          ),
          const Address(
            id: 'addr-2',
            label: 'Work',
            fullAddress: '456 Avenue, Riyadh',
            city: 'Riyadh',
            lat: 24.8,
            lng: 46.8,
          ),
        ]);

        final addresses = await addressService.getAddresses();
        expect(addresses, hasLength(2));
      });
    });

    group('getDefaultAddress', () {
      test('should return null when no addresses', () async {
        final address = await addressService.getDefaultAddress();
        expect(address, isNull);
      });
    });

    group('createAddress', () {
      test('should create new address', () async {
        final address = await addressService.createAddress(
          const CreateAddressParams(
            label: 'Home',
            fullAddress: '123 Main St, Riyadh',
            city: 'Riyadh',
            district: 'Al Olaya',
            street: '123 Main St',
            lat: 24.7,
            lng: 46.7,
          ),
        );

        expect(address.id, isNotEmpty);
        expect(address.label, equals('Home'));
        expect(address.city, equals('Riyadh'));
      });

      test('first address should be default', () async {
        await addressService.createAddress(
          const CreateAddressParams(
            label: 'Home',
            fullAddress: '123 Main St, Riyadh',
            city: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
          ),
        );

        final addresses = await addressService.getAddresses();
        expect(addresses.first.isDefault, isTrue);
      });
    });

    group('updateAddress', () {
      test('should update address fields', () async {
        fakeRepo.seed([
          const Address(
            id: 'addr-1',
            label: 'Home',
            fullAddress: 'Old Street, Riyadh',
            city: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isDefault: true,
          ),
        ]);

        final updated = await addressService.updateAddress(
          'addr-1',
          const UpdateAddressParams(
            label: 'New Home',
            fullAddress: 'New Street, Riyadh',
          ),
        );

        expect(updated.label, equals('New Home'));
        expect(updated.fullAddress, equals('New Street, Riyadh'));
      });
    });

    group('deleteAddress', () {
      test('should remove address', () async {
        fakeRepo.seed([
          const Address(
            id: 'addr-1',
            label: 'Home',
            fullAddress: 'Street, Riyadh',
            city: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isDefault: true,
          ),
        ]);

        await addressService.deleteAddress('addr-1');

        final addresses = await addressService.getAddresses();
        expect(addresses, isEmpty);
      });
    });

    group('setDefaultAddress', () {
      test('should set address as default', () async {
        fakeRepo.seed([
          const Address(
            id: 'addr-1',
            label: 'Home',
            fullAddress: 'Street 1, Riyadh',
            city: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isDefault: true,
          ),
          const Address(
            id: 'addr-2',
            label: 'Work',
            fullAddress: 'Street 2, Riyadh',
            city: 'Riyadh',
            lat: 24.8,
            lng: 46.8,
          ),
        ]);

        await addressService.setDefaultAddress('addr-2');

        // The fake just sets the default ID
        // No error expected
      });
    });
  });
}
