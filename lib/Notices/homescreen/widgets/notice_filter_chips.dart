import 'package:flutter/material.dart';
import '../provider/home_provider.dart';

class FilterChipsRow extends StatelessWidget {
  final FeedFilter activeFilter;
  final ValueChanged<FeedFilter> onFilterSelected;
  final VoidCallback onClear;

  const FilterChipsRow({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    required this.onClear,
  });

  static const _filters = [
    (FeedFilter.all, 'All'),
    (FeedFilter.unread, 'Unread'),
    (FeedFilter.important, 'Important'),
    (FeedFilter.placements, 'Placements'),
    (FeedFilter.examinations, 'Examinations'),
    (FeedFilter.myDepartments, 'My Depts'),
    (FeedFilter.clubs, 'Clubs'),
    (FeedFilter.today, 'Today'),
    (FeedFilter.thisWeek, 'This Week'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filters.length + (activeFilter != FeedFilter.all ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (activeFilter != FeedFilter.all && index == _filters.length) {
            return GestureDetector(
              onTap: onClear,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final (filter, label) = _filters[index];
          final isSelected = activeFilter == filter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedScale(
              scale: isSelected ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withBlue(245),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}