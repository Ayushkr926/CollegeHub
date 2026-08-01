import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notice_form_data.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import '../widgets/state_views.dart';
import 'notice_form_screen.dart';

/// Notice Detail Screen — exact layout inspired by the provided design,
/// rendered in a pure black & white theme.
class NoticeDetailScreen extends StatefulWidget {
  final String noticeId;
  final bool canManageNotices;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
    this.canManageNotices = false,
  });

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  bool _aboutExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().loadNoticeDetail(widget.noticeId);
    });
  }

  Future<void> _launchCta(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }

  Future<void> _confirmDelete(NoticeModel notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this notice?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove the notice from the list.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<NoticeProvider>();
    final success = await provider.deleteNotice(notice.id);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.detailError ?? 'Could not delete notice.')),
      );
    }
  }

  void _showPinDurationSheet(NoticeModel notice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final options = [24, 48, 72, 168];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pin for how long?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ...options.map(
                    (h) => ListTile(
                  leading: const Icon(Icons.push_pin_outlined, color: Colors.white70),
                  title: Text(
                    h < 24 ? '$h hours' : '${h ~/ 24} day${h ~/ 24 > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<NoticeProvider>().pinNotice(notice.id, pinDurationHours: h);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: Colors.white70),
                title: const Text('Indefinitely', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<NoticeProvider>().pinNotice(notice.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openFullScreenImages(List<NoticeMediaItem> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Consumer<NoticeProvider>(
        builder: (context, provider, _) {
          if (provider.detailStatus == LoadStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (provider.detailStatus == LoadStatus.error ||
              provider.currentDetail == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.detailError ?? 'Could not load this notice.',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => provider.loadNoticeDetail(widget.noticeId),
                    child: const Text('Retry', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          }

          final notice = provider.currentDetail!;
          final busy = provider.isMutating(notice.id);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── HERO HEADER ───────────────────────────────────────
              _HeroHeader(
                notice: notice,
                canManage: widget.canManageNotices,
                onBack: () => Navigator.of(context).maybePop(),
                onBookmark: () => provider.toggleBookmark(notice),
                onMenuSelected: (v) => _handleMenuAction(
                  context,
                  v,
                  notice,
                  provider,
                      () => _showPinDurationSheet(notice),
                ),
                menuItems: _buildMenuItems(notice),
              ),

              // ─── BODY ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      _TopBadges(notice: notice),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        notice.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle / short summary
                      if (notice.summary.isNotEmpty)
                        Text(
                          notice.summary,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Publisher card
                      _PublisherCard(notice: notice),

                      const SizedBox(height: 16),

                      // Status chips row
                      _StatusChipsRow(notice: notice),

                      const SizedBox(height: 18),

                      // Quote block
                      if (notice.summary.isNotEmpty)
                        _QuoteBlock(text: notice.summary),

                      const SizedBox(height: 20),

                      // CTA + Share
                      if (notice.hasCta)
                        _CtaRow(
                          ctaText: notice.customCtaText ?? 'Register Now',
                          onCta: () => _launchCta(notice.customCtaUrl!),
                          onShare: () {
                            // TODO: implement share
                          },
                        ),

                      const SizedBox(height: 28),

                      // About section
                      _AboutSection(
                        body: notice.body,
                        expanded: _aboutExpanded,
                        onToggle: () => setState(() => _aboutExpanded = !_aboutExpanded),
                      ),

                      const SizedBox(height: 26),

                      // Tags
                      if (notice.primaryCategory.isNotEmpty ||
                          notice.secondaryTags.isNotEmpty ||
                          notice.customTags.isNotEmpty)
                        _TagsSection(notice: notice),

                      const SizedBox(height: 26),

                      // Audience
                      _AudienceGrid(notice: notice),

                      const SizedBox(height: 26),

                      // Gallery
                      if (notice.images.isNotEmpty)
                        _GallerySection(
                          images: notice.images,
                          onTap: (i) => _openFullScreenImages(notice.images, i),
                        ),

                      const SizedBox(height: 26),

                      // Attachments
                      if (notice.attachments.isNotEmpty)
                        _AttachmentsSection(
                          attachments: notice.attachments,
                          onTap: (url) => _launchCta(url),
                        ),

                      const SizedBox(height: 28),

                      // Engagement stats
                      _EngagementBar(notice: notice),

                      const SizedBox(height: 18),

                      // Footer dates
                      Text(
                        'Created ${_formatFullDate(notice.createdAt)}'
                            '${notice.updatedAt != null ? '  •  Updated ${_formatFullDate(notice.updatedAt!)}' : ''}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),

                      if (busy)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Similar notices
              if (provider.similarStatus != LoadStatus.empty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'Similar Notices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (provider.similarStatus == LoadStatus.loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final s = provider.similarNotices[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: NoticeCard(
                            notice: s,
                            compact: true,
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => NoticeDetailScreen(
                                    noticeId: s.id,
                                    canManageNotices: widget.canManageNotices,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: provider.similarNotices.length,
                    ),
                  ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  // ─── Menu helpers (unchanged logic) ──────────────────────────────

  List<PopupMenuEntry<String>> _buildMenuItems(NoticeModel notice) {
    final items = <PopupMenuEntry<String>>[];
    if (!notice.isPublished && !notice.isArchived) {
      items.add(const PopupMenuItem(
        value: 'publish',
        child: ListTile(
          leading: Icon(Icons.publish, color: Colors.white70),
          title: Text('Publish', style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.zero,
        ),
      ));
    }
    items.add(const PopupMenuItem(
      value: 'edit',
      child: ListTile(
        leading: Icon(Icons.edit, color: Colors.white70),
        title: Text('Edit', style: TextStyle(color: Colors.white)),
        contentPadding: EdgeInsets.zero,
      ),
    ));
    if (!notice.isArchived) {
      items.add(const PopupMenuItem(
        value: 'archive',
        child: ListTile(
          leading: Icon(Icons.archive_outlined, color: Colors.white70),
          title: Text('Archive', style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.zero,
        ),
      ));
    } else {
      items.add(const PopupMenuItem(
        value: 'restore',
        child: ListTile(
          leading: Icon(Icons.unarchive_outlined, color: Colors.white70),
          title: Text('Restore', style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.zero,
        ),
      ));
    }
    if (notice.isPinned) {
      items.add(const PopupMenuItem(
        value: 'unpin',
        child: ListTile(
          leading: Icon(Icons.push_pin_outlined, color: Colors.white70),
          title: Text('Unpin', style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.zero,
        ),
      ));
    } else {
      items.add(const PopupMenuItem(
        value: 'pin',
        child: ListTile(
          leading: Icon(Icons.push_pin, color: Colors.white70),
          title: Text('Pin', style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.zero,
        ),
      ));
    }
    items.add(const PopupMenuDivider());
    items.add(const PopupMenuItem(
      value: 'delete',
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.redAccent),
        title: Text('Delete', style: TextStyle(color: Colors.redAccent)),
        contentPadding: EdgeInsets.zero,
      ),
    ));
    return items;
  }

  void _handleMenuAction(
      BuildContext context,
      String action,
      NoticeModel notice,
      NoticeProvider provider,
      VoidCallback showPinSheet,
      ) {
    switch (action) {
      case 'publish':
        provider.publishNotice(notice.id);
        break;
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoticeFormScreen(existingNotice: notice)),
        );
        break;
      case 'archive':
        provider.archiveNotice(notice.id);
        break;
      case 'restore':
        provider.restoreNotice(notice.id);
        break;
      case 'pin':
        showPinSheet();
        break;
      case 'unpin':
        provider.unpinNotice(notice.id);
        break;
      case 'delete':
        _confirmDelete(notice);
        break;
    }
  }

  static String _formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $h:$min $ampm';
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final NoticeModel notice;
  final bool canManage;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final ValueChanged<String> onMenuSelected;
  final List<PopupMenuEntry<String>> menuItems;

  const _HeroHeader({
    required this.notice,
    required this.canManage,
    required this.onBack,
    required this.onBookmark,
    required this.onMenuSelected,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      leading: _GlassBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
      actions: [
        _GlassBtn(
          icon: notice.isBookmarkedByMe ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          onTap: onBookmark,
        ),
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _GlassPopup(items: menuItems, onSelected: onMenuSelected),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A),
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
            // Decorative circles (simulating the floating icons / glow)
            Positioned(
              right: -40,
              top: 20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 50,
              child: Icon(
                Icons.auto_awesome,
                size: 28,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Positioned(
              right: 90,
              top: 90,
              child: Icon(
                Icons.code,
                size: 22,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            // Cover image if available
            if (notice.coverImageUrl != null)
              Opacity(
                opacity: 0.35,
                child: Image.network(
                  notice.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withOpacity(0.08),
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPopup extends StatelessWidget {
  final List<PopupMenuEntry<String>> items;
  final ValueChanged<String> onSelected;
  const _GlassPopup({required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withOpacity(0.08),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
            onSelected: onSelected,
            color: const Color(0xFF1F1F1F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (_) => items,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BADGES
// ─────────────────────────────────────────────────────────────────

class _TopBadges extends StatelessWidget {
  final NoticeModel notice;
  const _TopBadges({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (notice.primaryCategory.isNotEmpty)
          _Pill(
            label: notice.primaryCategory.toUpperCase(),
            filled: true,
          ),
        if (notice.isImportant)
          const _Pill(
            label: 'Important',
            icon: Icons.local_fire_department_rounded,
            filled: true,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;

  const _Pill({
    required this.label,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: filled ? Colors.black : Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.black : Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PUBLISHER CARD
// ─────────────────────────────────────────────────────────────────

class _PublisherCard extends StatelessWidget {
  final NoticeModel notice;
  const _PublisherCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white12,
            backgroundImage: notice.publisherAvatarUrl != null
                ? NetworkImage(notice.publisherAvatarUrl!)
                : null,
            child: notice.publisherAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.white54, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        notice.publisherName ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 15, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Official  •  ${notice.viewCount} followers',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STATUS CHIPS
// ─────────────────────────────────────────────────────────────────

class _StatusChipsRow extends StatelessWidget {
  final NoticeModel notice;
  const _StatusChipsRow({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (notice.isPublished)
          const Expanded(
            child: _StatusChip(
              icon: Icons.check_circle_rounded,
              label: 'Published',
              sub: '1 Aug 2026',
            ),
          ),
        if (notice.isPublished) const SizedBox(width: 8),
        if (notice.isPinned)
          const Expanded(
            child: _StatusChip(
              icon: Icons.push_pin_rounded,
              label: 'Pinned',
              sub: 'by Admin',
            ),
          ),
        if (notice.isPinned) const SizedBox(width: 8),
        if (notice.autoArchive)
          const Expanded(
            child: _StatusChip(
              icon: Icons.inventory_2_outlined,
              label: 'Auto-archive',
              sub: 'Enabled',
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// QUOTE BLOCK
// ─────────────────────────────────────────────────────────────────

class _QuoteBlock extends StatelessWidget {
  final String text;
  const _QuoteBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Colors.white38, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '“',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 28,
              height: 0.8,
            ),
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Build. Design. Deploy.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CTA ROW
// ─────────────────────────────────────────────────────────────────

class _CtaRow extends StatelessWidget {
  final String ctaText;
  final VoidCallback onCta;
  final VoidCallback onShare;

  const _CtaRow({
    required this.ctaText,
    required this.onCta,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ctaText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          width: 52,
          child: OutlinedButton(
            onPressed: onShare,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.ios_share_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ABOUT SECTION
// ─────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final String body;
  final bool expanded;
  final VoidCallback onToggle;

  const _AboutSection({
    required this.body,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              'About This Workshop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          body,
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            expanded ? 'Show less' : 'Read More  ▾',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAGS
// ─────────────────────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final NoticeModel notice;
  const _TagsSection({required this.notice});

  @override
  Widget build(BuildContext context) {
    final tags = <String>[
      if (notice.primaryCategory.isNotEmpty) notice.primaryCategory,
      ...notice.secondaryTags,
      ...notice.customTags,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.sell_outlined, size: 18, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              'Tags',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                t,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AUDIENCE GRID
// ─────────────────────────────────────────────────────────────────

class _AudienceGrid extends StatelessWidget {
  final NoticeModel notice;
  const _AudienceGrid({required this.notice});

  @override
  Widget build(BuildContext context) {
    final items = <_AudienceItem>[
      if (notice.targetCampuses.isNotEmpty)
        _AudienceItem(
          icon: Icons.location_city_outlined,
          label: 'Campus',
          value: notice.targetCampuses.first,
        ),
      if (notice.targetDepartments.isNotEmpty)
        _AudienceItem(
          icon: Icons.apartment_outlined,
          label: 'Department',
          value: notice.targetDepartments.first,
        ),
      if (notice.targetProgrammes.isNotEmpty)
        _AudienceItem(
          icon: Icons.menu_book_outlined,
          label: 'Programme',
          value: notice.targetProgrammes.first,
        ),
      if (notice.targetYears.isNotEmpty)
        _AudienceItem(
          icon: Icons.school_outlined,
          label: 'Year',
          value: notice.targetYears.first,
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.groups_2_outlined, size: 18, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              'Audience',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: items.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(e.icon, size: 18, color: Colors.white54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.label,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          e.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AudienceItem {
  final IconData icon;
  final String label;
  final String value;
  const _AudienceItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// ─────────────────────────────────────────────────────────────────
// GALLERY
// ─────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  final List<NoticeMediaItem> images;
  final void Function(int) onTap;

  const _GallerySection({required this.images, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library_outlined, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              'Gallery (${images.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => onTap(0),
              child: const Text(
                'See All  >',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              return GestureDetector(
                onTap: () => onTap(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[i].url,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 90,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ATTACHMENTS
// ─────────────────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  final List<NoticeMediaItem> attachments;
  final void Function(String) onTap;

  const _AttachmentsSection({
    required this.attachments,
    required this.onTap,
  });

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  String _sizeLabel(NoticeMediaItem att) {
    // Placeholder – replace with real size if available
    return 'File';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_file_rounded, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              'Attachments (${attachments.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...attachments.map((att) {
          final name = att.fileName ?? att.url.split('/').last;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_iconFor(name), color: Colors.white70, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _sizeLabel(att),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onTap(att.url),
                  icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 20),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ENGAGEMENT BAR
// ─────────────────────────────────────────────────────────────────

class _EngagementBar extends StatelessWidget {
  final NoticeModel notice;
  const _EngagementBar({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(
            icon: Icons.favorite_rounded,
            value: '${notice.likeCount}',
            label: 'Likes',
          ),
          Container(width: 1, height: 28, color: Colors.white12),
          _Stat(
            icon: Icons.visibility_rounded,
            value: '${notice.viewCount}',
            label: 'Views',
          ),
          Container(width: 1, height: 28, color: Colors.white12),
          _Stat(
            icon: Icons.bookmark_rounded,
            value: '${notice.bookmarkCount}',
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FULL SCREEN GALLERY
// ─────────────────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  final List<NoticeMediaItem> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller =
  PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (ctx, i) => Center(
              child: InteractiveViewer(
                child: Image.network(
                  widget.images[i].url,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _GlassBtn(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_index + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}