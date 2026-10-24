import 'package:flutter/material.dart';

import '../Model/event_model.dart';

class HomeEventCard extends StatelessWidget {
  const HomeEventCard({super.key, required this.event, this.onTap});

  final EventModel event;
  final VoidCallback? onTap;

  static const _surface = Color(0xFF121212);
  static const _surfaceElevated = Color(0xFF1A1A1A);
  static const _border = Color(0x1FFFFFFF);
  static const _textSecondary = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context) {
    final isRegistrationOpen = const {
      'open',
      'live',
      'approved',
      'active',
    }.contains(event.status.toLowerCase());

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 110),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 15, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(event.eventDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.access_time_rounded,
                      size: 15, color: _textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    event.startTime.format(context),
                    style: const TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.venue.isNotEmpty ? event.venue : event.modeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: _border, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceElevated,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_outlined,
                            color: _textSecondary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${event.participantsCount} Going',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isRegistrationOpen
                            ? Colors.white
                            : const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRegistrationOpen
                                ? Icons.check_circle_rounded
                                : Icons.event_busy_outlined,
                            color: isRegistrationOpen
                                ? Colors.black
                                : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isRegistrationOpen
                                  ? 'Registration Open'
                                  : 'Registration Closed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isRegistrationOpen
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}