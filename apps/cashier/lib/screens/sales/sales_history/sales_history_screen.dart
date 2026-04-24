/// Sales History container screen (post-3.3 decomposition).
///
/// هذا الـ container النحيف يعرض البنية فقط:
///   AppHeader → filters → summary → list
/// المنطق في [SalesHistoryNotifier]، العرض مفصّل إلى widgets.
/// سجل التغييرات:
///   قبل: ملف واحد 1148 سطر + 40 setState.
///   بعد: container ≈ 140 سطر + ≤ 3 setState (scroll-to-top فقط).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;

import 'providers/sales_history_providers.dart';
import 'widgets/filters_bar.dart';
import 'widgets/sales_list.dart';
import 'widgets/sales_summary_header.dart';

/// شاشة سجل المبيعات.
class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 300;
    // setState الوحيد المتبقي في الـ container — خاص بالـ FAB فقط.
    if (show != _showScrollToTop) {
      setState(() => _showScrollToTop = show);
    }
  }

  String _dateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final asyncState = ref.watch(salesHistoryNotifierProvider);

    return Scaffold(
      floatingActionButton: _showScrollToTop
          ? Semantics(
              label: l10n.back,
              button: true,
              child: FloatingActionButton.small(
                tooltip: l10n.back,
                onPressed: () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                child: const Icon(Icons.arrow_upward),
              ),
            )
          : null,
      body: Column(
        children: [
          AppHeader(
            title: l10n.salesHistory,
            subtitle: _dateSubtitle(l10n),
            showSearch: false,
            searchHint: l10n.searchPlaceholder,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: ref.watch(unreadNotificationsCountProvider),
            userName: user?.name ?? l10n.cashCustomer,
            userRole: l10n.branchManager,
            onUserTap: () {},
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.md),
                child: ShimmerList(itemCount: 6, itemHeight: 72),
              ),
              error: (err, _) => AppErrorState.general(
                context,
                message: '$err',
                onRetry: () => ref
                    .read(salesHistoryNotifierProvider.notifier)
                    .reload(),
              ),
              data: (state) {
                final filtered = state.filtered;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                      ),
                      child: const SalesHistoryFiltersBar(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMediumScreen ? 24 : 16,
                      ),
                      child: SalesSummaryHeader(orders: filtered),
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    Expanded(
                      child: SalesListView(
                        orders: filtered,
                        hasMore: state.hasMore,
                        isLoadingMore: state.isLoadingMore,
                        isMediumScreen: isMediumScreen,
                        scrollController: _scrollController,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
