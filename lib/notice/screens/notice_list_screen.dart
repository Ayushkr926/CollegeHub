import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notice_provider.dart';
import '../stitch/stitch_token.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';
import 'notice_form_screen.dart';
import 'notice_search_screen.dart';

class NoticeListScreen extends StatefulWidget {
  final bool canManageNotices;

  const NoticeListScreen({super.key, this.canManageNotices = false});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimController;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NoticeProvider>();
      if (provider.listStatus == LoadStatus.idle) {
        provider.loadNotices(force: false);
      }
      if (provider.trendingStatus == LoadStatus.idle) {
        provider.loadHomeSections();
      }
      _fabAnimController.forward();
    });
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 320) {
      context.read<NoticeProvider>().loadMoreNotices();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoticeDetailScreen(
          noticeId: id,
          canManageNotices: widget.canManageNotices,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NoticeSearchScreen()),
    );
  }

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NoticeFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isScrolled = _scrollOffset > 12;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Consumer<NoticeProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: StitchColors.furCore,
            backgroundColor: StitchColors.surface,
            onRefresh: () async {
              await Future.wait([
                provider.refreshNotices(),
                provider.loadHomeSections(),
              ]);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(isScrolled),

                // Loading
                if (provider.listStatus == LoadStatus.loading &&
                    provider.notices.isEmpty)
                  const //
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  )

                // Error
                else if (provider.listStatus == LoadStatus.error &&
                    provider.notices.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: provider.listError ??
                          'Something went wrong. Please try again.',
                      onRetry: () => provider.loadNotices(force: true),
                    ),
                  )

                // Content
                else
                  ..._buildContentSlivers(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
      widget.canManageNotices ? _buildFab() : null,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // App Bar (matches screenshot)
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppBar(bool isScrolled) {
    return //
      //
      SliverAppBar(
        pinned: true,
        floating: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF050505),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isScrolled
              ? const Text(
            'Notices',
            key: ValueKey('scrolled'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
          )
              : const SizedBox.shrink(key: ValueKey('expanded')),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _openSearch,
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded, size: 24, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: const CircleBorder(),
                side: const BorderSide(color: Color(0xFF2C2F3A), width: 0.8),
              ),
            ),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          background: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 8, 20, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: isScrolled ? 0 : 1,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Notices',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: -0.7,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Updates for the whole team',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: isScrolled ? 0.8 : 0,
            color: const Color(0xFF2C2F3A),
          ),
        ),
      );
  }

  Widget _buildFab() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimController,
        curve: Curves.easeOutBack,
      ),
      child: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Content
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildContentSlivers(NoticeProvider provider) {
    return [
      // Welcome banner
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WelcomeBanner(),
        ),
      ),

      // Section header or active filters
      if (!provider.filters.hasActiveFilters)
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Latest'),
        )
      else
      //
        SliverToBoxAdapter(
          child: _ActiveFiltersBar(provider: provider),
        ),

      // Empty state
      if (provider.listStatus == LoadStatus.empty)
      //
        SliverToBoxAdapter(
          child: _EmptyState(
            hasFilters: provider.filters.hasActiveFilters,
            onClear: () => provider.clearFilters(),
          ),
        )
      else
      // Timeline
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
          //
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index == provider.notices.length) {
                  return provider.isListLoadingMore
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(height: 24);
                }

                final notice = provider.notices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoticeCard(
                    notice: notice,
                    onTap: () => _openDetail(notice.id),
                    onLikeTap: () => provider.toggleLike(notice),
                    onBookmarkTap: () => provider.toggleBookmark(notice),
                  ),
                );
              },
              childCount: provider.notices.length + 1,
            ),
          ),
        ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Welcome Banner (matches the screenshot exactly)
// ─────────────────────────────────────────────────────────────
class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111218),
            Color(0xFF171923),
            Color(0xFF231D3F),
          ],
        ),
        border: Border.all(color: const Color(0xFF2C2F3A), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow
          Positioned(
            right: -40,
            top: -35,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                // Left text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Ayush! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Stay informed and never\nmiss an important update.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right illustration
                SizedBox(
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Image.asset(
                        'assets/images/Stitch/hey1.png',
                        fit: BoxFit.contain,
                        height: 120,
                      ),
                      const Positioned(
                        top: 8,
                        left: 4,
                        child: _Bubble(icon: Icons.notifications_rounded),
                      ),
                      const Positioned(
                        right: 0,
                        top: 42,
                        child: _Bubble(icon: Icons.chat_bubble_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  const _Bubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF2A234A),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: const Color(0xFFD6BCFA)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF2C2F3A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active Filters / Empty / Loading / Error states (unchanged logic)
// ─────────────────────────────────────────────────────────────
class _ActiveFiltersBar extends StatelessWidget {
  final NoticeProvider provider;
  const _ActiveFiltersBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: StitchColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: StitchColors.furCore.withOpacity(0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_rounded, size: 20, color: StitchColors.furCore),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters active',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: StitchColors.noseInk,
                    ),
                  ),
                  Text(
                    'Showing a filtered set of notices',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: StitchColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => provider.clearFilters(),
              style: TextButton.styleFrom(
                foregroundColor: StitchColors.danger,
                backgroundColor: StitchColors.dangerSoft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Color(0xFF8B5CF6),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Loading notices…',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xFF6B7280)),
            const SizedBox(height: 16),
            const Text(
              'Couldn’t load notices',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 48, 36, 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.filter_alt_off_rounded : Icons.inbox_rounded,
            size: 52,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No matching notices' : 'No notices yet',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting or clearing your filters'
                : 'When new notices arrive, they’ll show up here',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: BorderSide(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear filters',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}