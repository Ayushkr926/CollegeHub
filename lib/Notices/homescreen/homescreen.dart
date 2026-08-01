import 'package:college/Notices/homescreen/provider/home_provider.dart';
import 'package:college/Notices/homescreen/widgets/notice_card.dart';
import 'package:college/Notices/homescreen/widgets/notice_filter_chips.dart';
import 'package:college/Notices/homescreen/widgets/pinned_section.dart';
import 'package:college/Notices/homescreen/widgets/stitch_refresh_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../create_notice/screen/create_edit_notice.dart';
import '../notice_detail/provider/notice_detail.dart';
import 'notice_models.dart';

class AppColors {
  // ===== Primary Palette (Modern Indigo-Blue) =====
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySoft = Color(0xFFDBEAFE);

  // ===== Header Gradient Colors =====
  static const Color headerGradientStart = Color(0xFF1E3A8A);
  static const Color headerGradientEnd = Color(0xFF2563EB);

  // ===== Backgrounds =====
  static const Color background = Color(0xFFF8FAFC); // App background slate
  static const Color surface = Color(0xFFFFFFFF); // Card / container surface
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Section background
  static const Color cardHover = Color(0xFFF8FAFC);

  // ===== Borders =====
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // ===== Text Hierarchy =====
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // ===== Icons =====
  static const Color icon = Color(0xFF3B82F6);
  static const Color iconInactive = Color(0xFF94A3B8);

  // ===== Buttons =====
  static const Color button = primary;
  static const Color buttonHover = Color(0xFF1D4ED8);
  static const Color buttonDisabled = Color(0xFF93C5FD);

  // ===== Chips =====
  static const Color chip = Color(0xFFF1F5F9);
  static const Color chipSelected = primary;
  static const Color chipBorder = Color(0xFFCBD5E1);

  // ===== Inputs =====
  static const Color inputFill = Colors.white;
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputFocused = primary;

  // ===== Navigation =====
  static const Color navBackground = Colors.white;
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF64748B);

  // ===== Status =====
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = primary;

  // ===== Shadows =====
  static const Color shadow = Color(0x0F0F172A);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.primaryLight,
      onSecondary: AppColors.textPrimary,

      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,

      secondaryContainer: AppColors.surfaceVariant,
      onSecondaryContainer: AppColors.textPrimary,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,

      outline: AppColors.border,
      outlineVariant: AppColors.divider,

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        side: const BorderSide(color: AppColors.border),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 8,
        shadowColor: AppColors.shadow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class HomeScreen_notice extends StatefulWidget {
  const HomeScreen_notice({super.key});

  @override
  State<HomeScreen_notice> createState() => _HomeScreen_noticeState();
}

class _HomeScreen_noticeState extends State<HomeScreen_notice> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeFeedProvider>().initialize();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<HomeFeedProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'College Notices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Search Action Button
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            tooltip: 'Search notices',
            onPressed: () {},
          ),

          // Notification Button with Animated Pulsing Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                tooltip: 'Notifications',
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Consumer<HomeFeedProvider>(
        builder: (context, provider, _) {
          return StitchPullToRefresh(
            onRefresh: provider.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [

                // Offline Banner
                if (provider.isOffline)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.warning.withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.warning),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'You’re offline – showing cached notices',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Dismiss', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Filter chips section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: FilterChipsRow(
                      activeFilter: provider.activeFilter,
                      onFilterSelected: provider.setFilter,
                      onClear: provider.clearFilter,
                    ),
                  ),
                ),

                // Initial Skeleton State
                if (provider.isLoading && provider.feedNotices.isEmpty)
                  SliverFillRemaining(child: _buildSkeleton())
                else if (provider.error != null && provider.feedNotices.isEmpty)
                  SliverFillRemaining(child: _buildError(provider))
                else if (provider.isEmpty)
                  SliverFillRemaining(child: _buildEmpty(provider))
                else ...[
                  // Pinned section
                  if (provider.pinnedNotices.isNotEmpty)
                    SliverToBoxAdapter(
                      child: PinnedSection(
                        notices: provider.pinnedNotices,
                        onTap: (n) => _openDetail(n.id,n),
                        onBookmark: (n) => provider.toggleBookmark(n.id),
                        onPublisherTap: (n) {},
                      ),
                    ),

                  // Notice Cards List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notice = provider.feedNotices[index];
                        return NoticeCard(
                          notice: notice,
                          onTap: () {
                            provider.markAsRead(notice.id);
                            _openDetail(notice.id,notice);
                          },
                          onBookmark: () => provider.toggleBookmark(notice.id),
                          onPublisherTap: () {},
                        );
                      },
                      childCount: provider.feedNotices.length,
                    ),
                  ),

                  // Bottom Loading Indicator
                  if (provider.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if(i==1){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEditNoticeScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'add',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ── Skeleton ─────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 110,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 180,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────────────
  Widget _buildEmpty(HomeFeedProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.activeFilter == FeedFilter.all
                  ? 'No notices yet'
                  : 'No notices match your filters',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.activeFilter == FeedFilter.all
                  ? 'Follow departments to get started'
                  : 'Try clearing the filters',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (provider.activeFilter != FeedFilter.all) ...[
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: provider.clearFilter,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────
  Widget _buildError(HomeFeedProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: provider.initialize,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(String id , Notice notice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoticeDetailScreen(
          noticeId: id,
          cachedNotice: notice, // for instant display + hero later
        ),
      ),
    );
  }
}