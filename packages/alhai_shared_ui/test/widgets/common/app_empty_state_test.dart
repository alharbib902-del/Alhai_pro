import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_empty_state.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'No Data',
        ),
      ));
      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
        ),
      ));
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should display description when provided', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
          description: 'Nothing here yet',
        ),
      ));
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('should not display description when null', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
        ),
      ));
      // Only title and icon should be present
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('should display action button when actionText provided',
        (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
          actionText: 'Add Item',
          onAction: () {},
        ),
      ));
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('should call onAction when action button tapped',
        (tester) async {
      var actionCalled = false;
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
          actionText: 'Add Item',
          onAction: () => actionCalled = true,
        ),
      ));
      await tester.tap(find.text('Add Item'));
      expect(actionCalled, isTrue);
    });

    testWidgets('should not display action button when actionText is null',
        (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
        ),
      ));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('AppEmptyState factories', () {
    testWidgets('noSearchResults should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noSearchResults(query: 'test'),
      ));
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('noProducts should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noProducts(),
      ));
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('noCustomers should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noCustomers(),
      ));
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('emptyCart should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.emptyCart(),
      ));
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('noInvoices should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noInvoices(),
      ));
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('noData should render with defaults', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noData(),
      ));
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('noData should render with custom title', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noData(title: 'Custom Title'),
      ));
      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('noOrders should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noOrders(),
      ));
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('noNotifications should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noNotifications(),
      ));
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('noConnection should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noConnection(),
      ));
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('noReports should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noReports(),
      ));
      expect(find.byIcon(Icons.assessment_outlined), findsOneWidget);
    });

    testWidgets('noLowStock should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noLowStock(),
      ));
      expect(find.byIcon(Icons.inventory_outlined), findsOneWidget);
    });

    testWidgets('noDebts should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noDebts(),
      ));
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('noReturns should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noReturns(),
      ));
      expect(find.byIcon(Icons.assignment_return_outlined), findsOneWidget);
    });

    testWidgets('noOffers should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppEmptyState.noOffers(),
      ));
      expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
    });
  });

  group('AppErrorState', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppErrorState(message: 'Something went wrong'),
      ));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should display details when provided', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppErrorState(
          message: 'Error',
          details: 'Some details',
        ),
      ));
      expect(find.text('Some details'), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry provided',
        (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppErrorState(
          message: 'Error',
          onRetry: () {},
        ),
      ));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('network factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppErrorState.network(),
      ));
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('server factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppErrorState.server(),
      ));
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('general factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        AppErrorState.general(),
      ));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('AppLoadingState', () {
    testWidgets('should display progress indicator', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppLoadingState(),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppLoadingState(message: 'Loading...'),
      ));
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should not display message when null', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const AppLoadingState(),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
