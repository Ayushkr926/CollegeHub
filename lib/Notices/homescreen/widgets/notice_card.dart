import 'package:flutter/material.dart';
import '../notice_models.dart';
import 'package:intl/intl.dart';

class NoticeCard extends StatefulWidget {
  final Notice notice;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onPublisherTap;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
    required this.onBookmark,
    required this.onPublisherTap,
  });

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _bookmarkController;
  late Animation<double> _bookmarkScale;

  @override
  void initState() {
    super.initState();
    _bookmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bookmarkController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bookmarkController.dispose();
    super.dispose();
  }

  void _onBookmarkTap() {
    _bookmarkController.forward(from: 0.0);
    widget.onBookmark();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !widget.notice.isRead;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? theme.colorScheme.primary.withOpacity(0.4)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isUnread ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar + Name + Time
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onPublisherTap,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.notice.publisher.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onPublisherTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.notice.publisher.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.notice.publisher.isVerified) ...[
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 15,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(widget.notice.publishedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Badges
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      if (widget.notice.isImportant)
                        _Badge(
                          label: 'Important',
                          color: const Color(0xFFEF4444),
                          icon: Icons.priority_high_rounded,
                        ),
                      if (widget.notice.isPinned)
                        _Badge(
                          label: 'Pinned',
                          color: const Color(0xFFF59E0B),
                          icon: Icons.push_pin_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.notice.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Snippet
                  Text(
                    widget.notice.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                      fontSize: 13.5,
                    ),
                  ),

                  // Footer
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (widget.notice.hasAttachment) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.notice.attachmentCount} Attachment',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),

                      // Animated Bookmark Button
                      ScaleTransition(
                        scale: _bookmarkScale,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            widget.notice.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: widget.notice.isBookmarked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          onPressed: _onBookmarkTap,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.share_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {},
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}