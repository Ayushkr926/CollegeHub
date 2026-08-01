import 'package:flutter/material.dart';
import '../notice_models.dart';
import 'notice_card.dart';

class PinnedSection extends StatelessWidget {
  final List<Notice> notices;
  final void Function(Notice) onTap;
  final void Function(Notice) onBookmark;
  final void Function(Notice) onPublisherTap;

  const PinnedSection({
    super.key,
    required this.notices,
    required this.onTap,
    required this.onBookmark,
    required this.onPublisherTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.push_pin_rounded,
                  size: 15,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pinned Notices',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${notices.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (notices.length > 3)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('See all', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        ...notices.take(3).map(
              (n) => NoticeCard(
                notice: n,
                onTap: () => onTap(n),
                onBookmark: () => onBookmark(n),
                onPublisherTap: () => onPublisherTap(n),
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}