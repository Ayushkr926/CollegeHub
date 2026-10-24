import 'package:flutter/material.dart';
import '../models/notice_form_data.dart';
import '../stitch/stitch_token.dart';

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
          splashColor: const Color(0xFF8B5CF6).withOpacity(0.06),
          highlightColor: const Color(0xFF8B5CF6).withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111218),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unread
                    ? const Color(0xFF8B5CF6).withOpacity(0.25)
                    : const Color(0xFF2C2F3A),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar / Cover
                      _Avatar(notice: notice),
                      const SizedBox(width: 12),

                      // Title + badges + summary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges
                            if (notice.isPinned || notice.isImportant)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    if (notice.isPinned)
                                      const _Badge(
                                        icon: Icons.push_pin_rounded,
                                        label: 'Pinned',
                                        color: Color(0xFFFBBF24), // yellow
                                      ),
                                    if (notice.isPinned && notice.isImportant)
                                      const SizedBox(width: 6),
                                    if (notice.isImportant)
                                      const _Badge(
                                        icon: Icons.priority_high_rounded,
                                        label: 'Important',
                                        color: Color(0xFFEF4444), // red
                                      ),
                                  ],
                                ),
                              ),

                            // Title + unread dot
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.25,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (unread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(left: 8, top: 5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6), // blue
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 3),

                            // Summary
                            Text(
                              notice.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.2,
                                color: Colors.white.withOpacity(0.55),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Meta row (category + time) ────────────
                  Row(
                    children: [
                      if (notice.isDraft)
                        const _Chip(
                          label: 'Draft',
                          color: Color(0xFF6B7280),
                          background: Color(0xFF1F2937),
                        ),
                      if (notice.isDraft && notice.primaryCategory.isNotEmpty)
                        const SizedBox(width: 6),
                      if (notice.primaryCategory.isNotEmpty)
                        _Chip(
                          label: notice.primaryCategory,
                          color: const Color(0xFFC4B5FD),
                          background: const Color(0xFF2E1F5E),
                        ),
                      const Spacer(),
                      Text(
                        _formatDate(notice.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Footer (publisher + actions) ──────────
                  Row(
                    children: [
                      // Publisher
                      Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: Colors.white.withOpacity(0.45),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          notice.publisherName ?? 'System',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),

                      // Like
                      _ActionButton(
                        icon: notice.isLikedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        active: notice.isLikedByMe,
                        activeColor: const Color(0xFFF91880),
                        onTap: widget.onLikeTap,
                      ),
                      const SizedBox(width: 4),

                      // Bookmark
                      _ActionButton(
                        icon: notice.isBookmarkedByMe
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        active: notice.isBookmarkedByMe,
                        activeColor: const Color(0xFF8B5CF6),
                        onTap: widget.onBookmarkTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

// ─────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final NoticeModel notice;
  const _Avatar({required this.notice});

  @override
  Widget build(BuildContext context) {
    const size = 46.0;

    if (notice.coverImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          notice.coverImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(size),
        ),
      );
    }

    return _fallback(size);
  }

  Widget _fallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2F3A)),
      ),
      child: const Icon(
        Icons.campaign_rounded,
        size: 22,
        color: Color(0xFF8B5CF6),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Badges
// ─────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Category / Status Chip
// ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _Chip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Like / Bookmark buttons
// ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: active ? activeColor : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}