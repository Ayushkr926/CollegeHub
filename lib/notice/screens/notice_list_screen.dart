import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notice_provider.dart';
import '../stitch/stitch_illustration.dart';
import '../stitch/stitch_token.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';
import 'notice_form_screen.dart';
import 'notice_search_screen.dart';

/// Notice List Screen — redesigned with a clean X / Twitter timeline aesthetic
/// while still using the Stitch token system.
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
      MaterialPageRoute(builder: (_) => NoticeDetailScreen(noticeId: id,canManageNotices: true,)),
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
      backgroundColor: StitchColors.canvas,
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
                if (provider.listStatus == LoadStatus.loading &&
                    provider.notices.isEmpty)
                  const SliverToBoxAdapter(
                    child: SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingState(),
                    ),
                  )
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
                else
                  ..._buildContentSlivers(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: widget.canManageNotices ? _buildFab() : null,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(bool isScrolled) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: StitchColors.canvas,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      centerTitle: false,
      titleSpacing: 16,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isScrolled
            ? Text(
          'Notices',
          key: const ValueKey('scrolled'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.3,
            color: StitchColors.noseInk,
          ),
        )
            : const SizedBox.shrink(key: ValueKey('expanded')),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: _openSearch,
            tooltip: 'Search',
            icon: Icon(
              Icons.search_rounded,
              size: 24,
              color: StitchColors.noseInk,
            ),
            style: IconButton.styleFrom(
              backgroundColor: StitchColors.surface,
              shape: const CircleBorder(),
              side: BorderSide(color: StitchColors.hairline, width: 0.8),
            ),
          ),
        ),
        const SizedBox(width: 6),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 8, 20, 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: isScrolled ? 0 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Notices',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      letterSpacing: -0.7,
                      color: StitchColors.noseInk,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    'Updates for the whole team',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: StitchColors.textMuted,
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
          color: StitchColors.hairline,
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
        backgroundColor: StitchColors.furCore,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
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
      // Pull-to-refresh trigger (invisible)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WelcomeBanner(),
        ),
      ),
      SliverToBoxAdapter(
        child: RefreshIndicator(
          color: StitchColors.furCore,
          backgroundColor: StitchColors.surface,
          onRefresh: () async {
            await Future.wait([
              provider.refreshNotices(),
              provider.loadHomeSections(),
            ]);
          },
          child: const SizedBox(height: 0.1),
        ),
      ),

      if (!provider.filters.hasActiveFilters) ...[


        // Section header
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Latest'),
        ),
      ] else ...[
        SliverToBoxAdapter(
          child: _ActiveFiltersBar(provider: provider),
        ),
      ],

      // Empty state
      if (provider.listStatus == LoadStatus.empty)
        SliverToBoxAdapter(
          child: _EmptyState(
            hasFilters: provider.filters.hasActiveFilters,
            onClear: () => provider.clearFilters(),
          ),
        )
      else
      // Main timeline list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
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
                          color: StitchColors.furCore,
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
// Featured Section
// ─────────────────────────────────────────────────────────────

class _FeaturedSection extends StatefulWidget {
  final NoticeProvider provider;
  final void Function(String) onTap;

  const _FeaturedSection({
    required this.provider,
    required this.onTap,
  });

  @override
  State<_FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<_FeaturedSection> {
  late final PageController _pageController;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.featuredStatus == LoadStatus.loading) {
      return const SizedBox(
        height: 168,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: StitchColors.furCore,
            ),
          ),
        ),
      );
    }

    if (widget.provider.featuredNotices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Featured',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
              color: StitchColors.noseInk,
            ),
          ),
        ),
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.provider.featuredNotices.length,
            itemBuilder: (context, index) {
              final notice = widget.provider.featuredNotices[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _FeaturedCard(
                  title: notice.title,
                  summary: notice.summary,
                  onTap: () => widget.onTap(notice.id),
                ),
              );
            },
          ),
        ),
        if (widget.provider.featuredNotices.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.provider.featuredNotices.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  height: 5,
                  width: _current == i ? 18 : 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: _current == i
                        ? StitchColors.furCore
                        : StitchColors.hairline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String summary;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: StitchColors.heroGradient,
            boxShadow: [
              BoxShadow(
                color: StitchColors.furCore.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft decorative glow
              Positioned(
                right: -28,
                top: -28,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Horizontal Rails
// ─────────────────────────────────────────────────────────────

class _HorizontalRail extends StatelessWidget {
  final String title;
  final LoadStatus status;
  final List<dynamic> notices;
  final void Function(String) onTap;

  const _HorizontalRail({
    required this.title,
    required this.status,
    required this.notices,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == LoadStatus.empty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
              color: StitchColors.noseInk,
            ),
          ),
        ),
        SizedBox(
          height: status == LoadStatus.loading ? 110 : 148,
          child: status == LoadStatus.loading
              ? const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: StitchColors.furCore,
              ),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final notice = notices[index];
              return SizedBox(
                width: 236,
                child: NoticeCard(
                  notice: notice,
                  onTap: () => onTap(notice.id),
                  compact: true,
                ),
              );
            },
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
              color: StitchColors.noseInk,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: StitchColors.hairline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active Filters
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
            Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: StitchColors.furCore,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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

// ─────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: StitchColors.furCore,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Loading notices…',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: StitchColors.textMuted,
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

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: StitchColors.textFaint,
            ),
            const SizedBox(height: 16),
            Text(
              'Couldn’t load notices',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: StitchColors.noseInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: StitchColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: StitchColors.furCore,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
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

  const _EmptyState({
    required this.hasFilters,
    required this.onClear,
  });

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
            color: StitchColors.textFaint,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No matching notices' : 'No notices yet',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: StitchColors.noseInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting or clearing your filters'
                : 'When new notices arrive, they’ll show up here',
            style: TextStyle(
              fontSize: 14,
              color: StitchColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: StitchColors.furCore,
                side: BorderSide(
                  color: StitchColors.furCore.withOpacity(0.5),
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
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


class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 165,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffF3F1FF),
              Color(0xffE9ECFF),
              Color(0xffEEF2FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [

            /// Background glow
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.35),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 22,
              ),
              child: Row(
                children: [

                  /// Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Hello, Ayush!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff1B2341),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Stay informed and never\nmiss an important update.",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Color(0xff5E6482),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Right Illustration
                  SizedBox(
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(.35),
                          ),
                        ),

                        Image.asset(
                          "assets/images/Stitch/hey1.png",
                          fit: BoxFit.contain,
                        ),

                        Positioned(
                          top: 12,
                          left: 10,
                          child: _Bubble(
                            icon: Icons.notifications,
                          ),
                        ),

                        Positioned(
                          right: 5,
                          top: 45,
                          child: _Bubble(
                            icon: Icons.chat_bubble_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xff6D72FF),
        size: 20,
      ),
    );
  }
}