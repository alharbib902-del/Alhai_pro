import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeStoreMembersRepo implements StoreMembersRepository {
  @override
  Future<Paginated<StoreMember>> getStoreMembers(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? activeOnly,
  }) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<StoreMember> getMember(String id) async => throw UnimplementedError();
  @override
  Future<StoreMember?> getMemberByUserId(String userId, String storeId) async =>
      null;
  @override
  Future<StoreMember> addMember({
    required String storeId,
    required String userId,
    required UserRole role,
    String? nickname,
    List<String>? permissions,
  }) async => StoreMember(
    id: 'm-1',
    storeId: storeId,
    userId: userId,
    role: role,
    permissions: permissions ?? [],
    isActive: true,
    joinedAt: DateTime.now(),
    nickname: nickname,
  );
  @override
  Future<StoreMember> updateRole(String memberId, UserRole role) async =>
      throw UnimplementedError();
  @override
  Future<StoreMember> updatePermissions(
    String memberId,
    List<String> permissions,
  ) async => throw UnimplementedError();
  @override
  Future<void> deactivateMember(String memberId) async {}
  @override
  Future<StoreMember> reactivateMember(String memberId) async =>
      throw UnimplementedError();
  @override
  Future<void> removeMember(String memberId) async {}
  @override
  Future<bool> hasPermission(
    String userId,
    String storeId,
    String permission,
  ) async => permission == 'create_order';
}

void main() {
  late StoreMemberService storeMemberService;
  setUp(() {
    storeMemberService = StoreMemberService(FakeStoreMembersRepo());
  });

  group('StoreMemberService', () {
    test('should be created', () {
      expect(storeMemberService, isNotNull);
    });

    test('addMember should create member', () async {
      final member = await storeMemberService.addMember(
        storeId: 'store-1',
        userId: 'user-1',
        role: UserRole.employee,
        nickname: 'Ahmed',
        permissions: ['create_order'],
      );
      expect(member.id, isNotEmpty);
      expect(member.role, equals(UserRole.employee));
      expect(member.nickname, equals('Ahmed'));
    });

    test('getStoreMembers should return paginated', () async {
      final result = await storeMemberService.getStoreMembers('store-1');
      expect(result, isA<Paginated<StoreMember>>());
    });

    test('getMemberByUserId should return null for unknown', () async {
      expect(
        await storeMemberService.getMemberByUserId('unknown', 'store-1'),
        isNull,
      );
    });

    test('hasPermission should return true for granted', () async {
      expect(
        await storeMemberService.hasPermission(
          'user-1',
          'store-1',
          'create_order',
        ),
        isTrue,
      );
    });

    test('hasPermission should return false for denied', () async {
      expect(
        await storeMemberService.hasPermission(
          'user-1',
          'store-1',
          'manage_admins',
        ),
        isFalse,
      );
    });

    test('deactivateMember should not throw', () async {
      await storeMemberService.deactivateMember('m1');
    });

    test('removeMember should not throw', () async {
      await storeMemberService.removeMember('m1');
    });

    test('getAllPermissions should return list', () {
      final perms = storeMemberService.getAllPermissions();
      expect(perms, isNotEmpty);
    });
  });
}
