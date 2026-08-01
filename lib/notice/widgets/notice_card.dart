import 'package:flutter/material.dart';
import '../models/notice_form_data.dart';
import '../stitch/stitch_token.dart';

/// Notice card — X / Twitter inspired timeline style.
/// Public API is unchanged.
class NoticeCard extends StatefulWidget {
  final NoticeModel notice;
  final VoidCallback onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onBookmarkTap;
  final bool compact;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
    this.onLikeTap,
    this.onBookmarkTap,
    this.compact = false,
  });

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final unread = !notice.isReadByMe;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          splashColor: StitchColors.furCore.withOpacity(0.05),
          highlightColor: StitchColors.furCore.withOpacity(0.03),
          borderRadius: BorderRadius.circular(
            widget.compact ? StitchRadius.podSm : StitchRadius.pod,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: widget.compact ? 0 : 0,
              vertical: 0,
            ),
            decoration: BoxDecoration(
              color: StitchColors.surface,
              borderRadius: BorderRadius.circular(
                widget.compact ? StitchRadius.podSm : StitchRadius.pod,
              ),
              border: Border.all(
                color: unread
                    ? StitchColors.furCore.withOpacity(0.22)
                    : StitchColors.hairline,
                width: unread ? 1.1 : 0.8,
              ),
              boxShadow: widget.compact
                  ? null
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                widget.compact ? 12 : 14,
                widget.compact ? 12 : 14,
                widget.compact ? 12 : 14,
                widget.compact ? 10 : 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(notice: notice, compact: widget.compact),
                  if (!widget.compact) ...[
                    const SizedBox(height: 10),
                    _MetaRow(notice: notice),
                    const SizedBox(height: 10),
                    _FooterRow(
                      notice: notice,
                      onLikeTap: widget.onLikeTap,
                      onBookmarkTap: widget.onBookmarkTap,
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    _MetaRow(notice: notice),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Header
// ===========================================================================

class _Header extends StatelessWidget {
  final NoticeModel notice;
  final bool compact;
  const _Header({required this.notice, required this.compact});

  @override
  Widget build(BuildContext context) {
    final imageSize = compact ? 42.0 : 48.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notice.coverImageUrl != null) ...[
          _CoverThumb(url: notice.coverImageUrl!, size: imageSize),
          const SizedBox(width: 11),
        ] else ...[
          // Fallback avatar when no cover image
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              color: StitchColors.surfaceSunken,
              borderRadius: BorderRadius.circular(StitchRadius.podXs),
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: imageSize * 0.42,
              color: StitchColors.textFaint,
            ),
          ),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges row
              if (notice.isPinned || notice.isImportant)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      if (notice.isPinned)
                        const _MiniBadge(
                          icon: Icons.push_pin_rounded,
                          label: 'Pinned',
                          color: StitchColors.warning,
                        ),
                      if (notice.isPinned && notice.isImportant)
                        const SizedBox(width: 5),
                      if (notice.isImportant)
                        const _MiniBadge(
                          icon: Icons.priority_high_rounded,
                          label: 'Important',
                          color: StitchColors.danger,
                        ),
                    ],
                  ),
                ),

              // Title + unread indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 14.0 : 15.0,
                        fontWeight: FontWeight.w700,
                        color: StitchColors.noseInk,
                        height: 1.28,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  if (!notice.isReadByMe)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(left: 7, top: 5),
                      decoration: const BoxDecoration(
                        color: StitchColors.furCore,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 3),

              // Summary
              Text(
                notice.summary,
                maxLines: compact ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 12.5 : 13.0,
                  color: StitchColors.textMuted,
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String url;
  final double size;
  const _CoverThumb({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: StitchColors.surfaceSunken,
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: StitchColors.furCore,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: StitchColors.surfaceSunken,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: StitchColors.textFaint,
            size: size * 0.34,
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Meta row
// ===========================================================================

class _MetaRow extends StatelessWidget {
  final NoticeModel notice;
  const _MetaRow({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusChip(notice: notice),
        if (notice.primaryCategory.isNotEmpty) ...[
          if (_hasStatus(notice)) const SizedBox(width: 6),
          _CategoryChip(label: notice.primaryCategory),
        ],
        const Spacer(),
        Text(
          _formatDate(notice.createdAt),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: StitchColors.textFaint,
          ),
        ),
      ],
    );
  }

  bool _hasStatus(NoticeModel n) {
    return n.isDraft ||
        n.isArchived ||
        n.isExpired ||
        (n.scheduledAt != null && n.scheduledAt!.isAfter(DateTime.now()));
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: StitchColors.earPink.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: StitchColors.earPinkDeep,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final NoticeModel notice;
  const _StatusChip({required this.notice});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (notice.isDraft) {
      label = 'Draft';
      color = StitchColors.textMuted;
    } else if (notice.isArchived) {
      label = 'Archived';
      color = const Color(0xFF8A6D4A);
    } else if (notice.isExpired) {
      label = 'Expired';
      color = StitchColors.danger;
    } else if (notice.scheduledAt != null &&
        notice.scheduledAt!.isAfter(DateTime.now())) {
      label = 'Scheduled';
      color = StitchColors.furCore;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.22), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ===========================================================================
// Footer — X-style engagement
// ===========================================================================

class _FooterRow extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback? onLikeTap;
  final VoidCallback? onBookmarkTap;

  const _FooterRow({
    required this.notice,
    required this.onLikeTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Publisher
        if (notice.publisherName != null) ...[
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: StitchColors.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 11,
              color: StitchColors.textMuted,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              notice.publisherName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: StitchColors.textMuted,
              ),
            ),
          ),
        ] else
          const Spacer(),

        const SizedBox(width: 8),

        // Like
        _EngagementButton(
          icon: notice.isLikedByMe
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          activeColor: const Color(0xFFF91880), // X-style pink
          inactiveColor: StitchColors.textFaint,
          active: notice.isLikedByMe,
          count: notice.likeCount,
          onTap: onLikeTap,
        ),

        const SizedBox(width: 2),

        // Bookmark
        _EngagementButton(
          icon: notice.isBookmarkedByMe
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          activeColor: StitchColors.furCore,
          inactiveColor: StitchColors.textFaint,
          active: notice.isBookmarkedByMe,
          count: notice.bookmarkCount,
          onTap: onBookmarkTap,
        ),
      ],
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;
  final bool active;
  final int count;
  final VoidCallback? onTap;

  const _EngagementButton({
    required this.icon,
    required this.activeColor,
    required this.inactiveColor,
    required this.active,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutBack,
                child: Icon(icon, size: 16.5, color: color),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}