import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_assistant_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiAssistantService service;
  late MockAppDatabase mockDb;
  late MockSalesDao mockSalesDao;
  late MockProductsDao mockProductsDao;
  late MockAccountsDao mockAccountsDao;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockSalesDao = MockSalesDao();
    mockProductsDao = MockProductsDao();
    mockAccountsDao = MockAccountsDao();
    mockDb = createMockDatabase(
      salesDao: mockSalesDao,
      productsDao: mockProductsDao,
      accountsDao: mockAccountsDao,
    );
    service = AiAssistantService(mockDb);
  });

  group('ChatMessage', () {
    test('should create with required fields', () {
      final msg = ChatMessage(
        id: '1',
        role: ChatRole.user,
        content: 'Hello',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(msg.id, '1');
      expect(msg.role, ChatRole.user);
      expect(msg.content, 'Hello');
      expect(msg.data, isNull);
      expect(msg.suggestedActions, isNull);
    });

    test('copyWith returns new instance with updated fields', () {
      final original = ChatMessage(
        id: '1',
        role: ChatRole.user,
        content: 'Hello',
        timestamp: DateTime(2024, 1, 1),
      );
      final copy = original.copyWith(content: 'Updated');

      expect(copy.content, 'Updated');
      expect(copy.id, '1');
      expect(copy.role, ChatRole.user);
    });

    test('copyWith preserves fields when not specified', () {
      final original = ChatMessage(
        id: '1',
        role: ChatRole.assistant,
        content: 'Hello',
        timestamp: DateTime(2024, 1, 1),
        data: {'key': 'value'},
      );
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.role, original.role);
      expect(copy.content, original.content);
      expect(copy.data, original.data);
    });
  });

  group('AssistantResponse', () {
    test('should create with default confidence', () {
      const response = AssistantResponse(text: 'Hello');
      expect(response.confidence, 0.8);
      expect(response.data, isNull);
      expect(response.suggestedActions, isNull);
    });

    test('should create with custom confidence', () {
      const response = AssistantResponse(text: 'Hello', confidence: 0.95);
      expect(response.confidence, 0.95);
    });
  });

  group('SuggestedAction', () {
    test('should create with label only', () {
      const action = SuggestedAction(label: 'Test');
      expect(action.label, 'Test');
      expect(action.route, isNull);
      expect(action.icon, isNull);
    });
  });

  group('QuickTemplate', () {
    test('getQuickTemplates returns non-empty list', () {
      final templates = service.getQuickTemplates();
      expect(templates, isNotEmpty);
      expect(templates.length, 8);
    });

    test('each template has required fields', () {
      final templates = service.getQuickTemplates();
      for (final t in templates) {
        expect(t.id, isNotEmpty);
        expect(t.titleAr, isNotEmpty);
        expect(t.titleEn, isNotEmpty);
        expect(t.query, isNotEmpty);
      }
    });
  });

  group('processQuery - keyword matching', () {
    test('greeting query returns greeting response', () async {
      final response = await service.processQuery('مرحبا', 'store-1');
      expect(response.confidence, 1.0);
      expect(response.text, contains('مساعدك الذكي'));
    });

    test('reports query returns reports response', () {
      final response = service.processQuery('تقرير', 'store-1');
      // This is sync, but returns Future
      expect(response, isA<Future<AssistantResponse>>());
    });

    test('default query returns default response', () async {
      final response = await service.processQuery(
        'zzz_query_no_keyword',
        'store-1',
      );
      expect(response.confidence, 0.6);
    });

    test('sales query calls sales DAO methods', () async {
      when(
        () => mockSalesDao.getTodayTotal(any(), any()),
      ).thenAnswer((_) async => 5000.0);
      when(
        () => mockSalesDao.getTodayCount(any(), any()),
      ).thenAnswer((_) async => 10);
      when(
        () => mockSalesDao.getSalesByDate(any(), any()),
      ).thenAnswer((_) async => []);

      final response = await service.processQuery('مبيعات اليوم', 'store-1');

      expect(response.confidence, 0.95);
      expect(response.data, isNotNull);
      expect(response.data!['todayTotal'], 5000.0);
      expect(response.data!['todayCount'], 10);
    });

    test('stock query calls products DAO methods', () async {
      when(
        () => mockProductsDao.getLowStockProducts(any()),
      ).thenAnswer((_) async => []);
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(id: 'p1', isActive: true, stockQty: 10),
          createFakeProduct(id: 'p2', isActive: true, stockQty: 0),
        ],
      );

      final response = await service.processQuery('مخزون', 'store-1');

      expect(response.confidence, 0.95);
      expect(response.data, isNotNull);
      expect(response.data!['totalProducts'], 2);
      expect(response.data!['outOfStockCount'], 1);
    });

    test('debt query calls accounts DAO methods', () async {
      when(() => mockAccountsDao.getReceivableAccounts(any())).thenAnswer(
        (_) async => [
          createFakeAccount(name: 'Customer A', balance: 500),
          createFakeAccount(id: 'a2', name: 'Customer B', balance: 300),
        ],
      );

      final response = await service.processQuery('ديون العملاء', 'store-1');

      expect(response.confidence, 0.9);
      expect(response.data, isNotNull);
      expect(response.data!['totalDebt'], 800.0);
      expect(response.data!['debtorsCount'], 2);
    });

    test('products query returns product count', () async {
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(id: 'p1', isActive: true),
          createFakeProduct(id: 'p2', isActive: false),
        ],
      );

      final response = await service.processQuery('عدد المنتجات', 'store-1');

      expect(response.confidence, 0.9);
      expect(response.data!['total'], 2);
      expect(response.data!['active'], 1);
      expect(response.data!['inactive'], 1);
    });

    test('recommendations query generates tips', () async {
      when(
        () => mockProductsDao.getLowStockProducts(any()),
      ).thenAnswer((_) async => [createFakeProduct(stockQty: 2)]);
      when(
        () => mockSalesDao.getTodayTotal(any(), any()),
      ).thenAnswer((_) async => 50.0);
      when(
        () => mockAccountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => [createFakeAccount(balance: 2000)]);

      final response = await service.processQuery('نصيحة', 'store-1');

      expect(response.confidence, 0.8);
      expect(response.text, contains('توصيات'));
    });

    test('error during processing returns error response', () async {
      when(
        () => mockSalesDao.getTodayTotal(any(), any()),
      ).thenThrow(Exception('DB Error'));

      final response = await service.processQuery('مبيعات', 'store-1');

      expect(response.confidence, 0.5);
      expect(response.text, contains('عذراً'));
    });
  });

  group('processQuery - top products', () {
    test('returns no data message when sales are empty', () async {
      when(
        () => mockSalesDao.getSalesByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => []);

      final response = await service.processQuery('أفضل المنتجات', 'store-1');

      expect(response.confidence, 0.7);
      expect(response.text, contains('لا توجد بيانات'));
    });

    test('returns top products when sales exist', () async {
      when(
        () => mockSalesDao.getSalesByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [createFakeSale()]);
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(id: 'p1', name: 'Product A', price: 10),
          createFakeProduct(id: 'p2', name: 'Product B', price: 20),
        ],
      );

      final response = await service.processQuery('أفضل المنتجات', 'store-1');

      expect(response.confidence, 0.85);
      expect(response.data, isNotNull);
      expect(response.data!['totalSalesThisWeek'], 1);
    });
  });
}
