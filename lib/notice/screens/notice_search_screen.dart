import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice_form_data.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';

/// Search screen — redesigned to match the provided UI,
/// rendered in a pure black & white theme.
class NoticeSearchScreen extends StatefulWidget {
  const NoticeSearchScreen({super.key});

  @override
  State<NoticeSearchScreen> createState() => _NoticeSearchScreenState();
}

class _NoticeSearchScreenState extends State<NoticeSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<NoticeProvider>().filters.search;
    if (existing != null && existing.isNotEmpty) {
      _searchController.text = existing;
      _showResults = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<NoticeProvider>().fetchSuggestionsDebounced(value);
    if (_showResults) setState(() => _showResults = false);
  }

  void _runSearch(String query) {
    _focusNode.unfocus();
    context.read<NoticeProvider>().clearSuggestions();
    context.read<NoticeProvider>().updateSearchQuery(query);
    setState(() => _showResults = true);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NoticeProvider>().clearSuggestions();
    context.read<NoticeProvider>().updateSearchQuery('');
    setState(() => _showResults = false);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Search Notices',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),

            // ── Search Field ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search notices...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: _clearSearch,
                    )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) {
                    setState(() {}); // refresh suffix icon
                    _onSearchChanged(v);
                  },
                  onSubmitted: _runSearch,
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: Consumer<NoticeProvider>(
                builder: (context, provider, _) {
                  if (!_showResults) {
                    return _SuggestionsView(
                      isLoading: provider.isFetchingSuggestions,
                      suggestions: provider.searchSuggestions,
                      onSelect: (s) {
                        _searchController.text = s;
                        _runSearch(s);
                      },
                      onClear: () {
                        context.read<NoticeProvider>().clearSuggestions();
                      },
                    );
                  }

                  // Results view
                  if (provider.listStatus == LoadStatus.loading &&
                      provider.notices.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (provider.listStatus == LoadStatus.error &&
                      provider.notices.isEmpty) {
                    return _ErrorView(
                      message: provider.listError ?? 'Search failed.',
                      onRetry: () => provider.loadNotices(force: true),
                    );
                  }

                  if (provider.listStatus == LoadStatus.empty) {
                    return _EmptyView(
                      hasFilters: provider.filters.hasActiveFilters,
                      onClear: () => provider.clearFilters(),
                    );
                  }

                  return _ResultsView(
                    provider: provider,
                    onTap: (id) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoticeDetailScreen(noticeId: id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUGGESTIONS VIEW (categorized chips like the image)
// ─────────────────────────────────────────────────────────────

class _SuggestionsView extends StatelessWidget {
  final bool isLoading;
  final List<String> suggestions;
  final void Function(String) onSelect;
  final VoidCallback onClear;

  const _SuggestionsView({
    required this.isLoading,
    required this.suggestions,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          ),
        ),
      );
    }

    // For demo / when API returns flat list we still group them visually.
    // In real use you can split titles / categories / tags / publishers
    // from the provider if your backend returns them separately.
    final titles = suggestions.where((s) => s.length > 12).take(4).toList();
    final categories = suggestions.where((s) => s.length <= 12).take(4).toList();
    final tags = suggestions.take(6).toList();
    final publishers = suggestions.skip(2).take(3).toList();

    if (suggestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Start typing to see suggestions',
            style: TextStyle(color: Colors.white38, fontSize: 14.5),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Suggestions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onClear,
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Titles
        if (titles.isNotEmpty) ...[
          _SuggestionGroup(
            icon: Icons.description_outlined,
            label: 'Titles',
            color: Colors.white70,
            chips: titles,
            onSelect: onSelect,
          ),
          const SizedBox(height: 16),
        ],

        // Categories
        if (categories.isNotEmpty) ...[
          _SuggestionGroup(
            icon: Icons.grid_view_rounded,
            label: 'Categories',
            color: Colors.white70,
            chips: categories,
            onSelect: onSelect,
          ),
          const SizedBox(height: 16),
        ],

        // Tags
        if (tags.isNotEmpty) ...[
          _SuggestionGroup(
            icon: Icons.sell_outlined,
            label: 'Tags',
            color: Colors.white70,
            chips: tags,
            onSelect: onSelect,
          ),
          const SizedBox(height: 16),
        ],

        // Publishers
        if (publishers.isNotEmpty) ...[
          _SuggestionGroup(
            icon: Icons.person_outline_rounded,
            label: 'Publishers',
            color: Colors.white70,
            chips: publishers,
            onSelect: onSelect,
          ),
        ],
      ],
    );
  }
}

class _SuggestionGroup extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<String> chips;
  final void Function(String) onSelect;

  const _SuggestionGroup({
    required this.icon,
    required this.label,
    required this.color,
    required this.chips,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((c) {
            return GestureDetector(
              onTap: () => onSelect(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  c,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RESULTS VIEW
// ─────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final NoticeProvider provider;
  final void Function(String) onTap;

  const _ResultsView({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Count + Sort
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 16, 10),
          child: Row(
            children: [
              Text(
                'Notices (${provider.notices.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Optional: open sort sheet
                },
                child: Row(
                  children: [
                    Text(
                      'Sort by: Newest',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white60, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: provider.notices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notice = provider.notices[index];
              return _SearchResultCard(
                notice: notice,
                onTap: () => onTap(notice.id),
                onBookmark: () => provider.toggleBookmark(notice),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SEARCH RESULT CARD (matches image style, B&W)
// ─────────────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _SearchResultCard({
    required this.notice,
    required this.onTap,
    required this.onBookmark,
  });

  IconData _iconForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('event') || c.contains('workshop')) return Icons.event_rounded;
    if (c.contains('academic') || c.contains('exam')) return Icons.description_rounded;
    if (c.contains('general')) return Icons.campaign_rounded;
    return Icons.article_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final category = notice.primaryCategory.isNotEmpty
        ? notice.primaryCategory
        : 'General';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForCategory(category),
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + pin
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (notice.isPinned)
                          const Icon(Icons.push_pin_rounded,
                              size: 15, color: Colors.white54),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onBookmark,
                          child: Icon(
                            notice.isBookmarkedByMe
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: notice.isBookmarkedByMe
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      notice.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Summary
                    Text(
                      notice.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Meta row
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 13, color: Colors.white38),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            notice.publisherName ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notice.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(notice.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

// ─────────────────────────────────────────────────────────────
// EMPTY / ERROR
// ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyView({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting or clearing your filters'
                  : 'Try a different search term',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Search failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}