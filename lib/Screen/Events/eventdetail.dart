import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Model/event_enums.dart';
import '../../Model/event_model.dart';
import '../../Provider/events_provider.dart';
import '../../storage/local_storage.dart';

const _bg = Color(0xFF121212);
const _card = Color(0xFF1E1E1E);
const _cardBorder = Color(0xFF303030);
const _pink = Color(0xFFE8395C);
const _muted = Color(0xFF9A9A9A);
const _green = Color(0xFF3DDC84);

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventModel event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _bookmarked = false;
  bool _isSubmitting = false;
  bool _isStudent = false;
  bool _isCheckingRegistration = true;
  bool _isRegistered = false;
  late EventModel _event = widget.event;

  EventModel get event => _event;

  @override
  void initState() {
    super.initState();
    _isStudent = LocalStorageService.instance.getString('role') == 'student';
    _isCheckingRegistration = _isStudent && widget.event.id.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isCheckingRegistration) {
        await context.read<EventsProvider>().loadMyRegistrations();
        if (mounted) {
          setState(() {
            _isRegistered = context
                .read<EventsProvider>()
                .isRegisteredFor(widget.event.id);
            _isCheckingRegistration = false;
          });
        }
      }
      if (widget.event.id.isNotEmpty) {
        final updated = await context.read<EventsProvider>().getEventById(widget.event.id);
        if (mounted && updated != null) setState(() => _event = updated);
      }
    });
  }

  double get _totalAmount => event.ticketPrice ?? 0;

  bool get _hasVenue =>
      event.mode != EventMode.online && event.venue.isNotEmpty;
  bool get _hasMeetingLink =>
      event.mode != EventMode.offline && event.meetingLink.isNotEmpty;

  Future<void> _launch(String url, {String? failureMessage}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureMessage ?? 'Could not open $url')),
      );
    }
  }

  Future<void> _copy(
    String value, {
    String label = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(label)));
    }
  }

  void _messageHost() {
    if (event.contactPhone.isNotEmpty) {
      _launch(
        'sms:${event.contactPhone}',
        failureMessage: 'No messaging app available',
      );
    } else if (event.contactEmail.isNotEmpty) {
      _launch(
        'mailto:${event.contactEmail}',
        failureMessage: 'No email app available',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact details provided')),
      );
    }
  }

  void _callHost() {
    if (event.contactPhone.isNotEmpty) {
      _launch(
        'tel:${event.contactPhone}',
        failureMessage: 'Could not place call',
      );
    }
  }

  void _emailHost() {
    if (event.contactEmail.isNotEmpty) {
      _launch(
        'mailto:${event.contactEmail}',
        failureMessage: 'No email app available',
      );
    }
  }

  void _openVenue() {
    if (_hasVenue) {
      _launch(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.venue)}',
        failureMessage: 'Could not open maps',
      );
    }
  }

  void _openMeetingLink() {
    if (_hasMeetingLink) {
      _launch(event.meetingLink, failureMessage: 'Could not open the link');
    }
  }

  Future<void> _buyOrRegister() async {
    if (!_isStudent) return;
    if (event.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This event is not available for registration yet')),
      );
      return;
    }

    String? teamName;
    List<String>? members;
    if (event.isTeamEvent) {
      final teamDetails = await _teamRegistrationDetails();
      if (!mounted) return;
      if (teamDetails == null) return;
      teamName = teamDetails.$1;
      members = teamDetails.$2;
    }

    setState(() => _isSubmitting = true);
    try {
      await context.read<EventsProvider>().register(
            event.id,
            teamName: teamName,
            members: members,
          );
      if (!mounted) return;
          setState(() => _isRegistered = true);
          await context.read<EventsProvider>().loadMyRegistrations();
          if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered for "${event.title}"')),
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<(String, List<String>)?> _teamRegistrationDetails() async {
    final teamNameController = TextEditingController();
    final membersController = TextEditingController();
    final result = await showDialog<(String, List<String>)>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Team registration', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: teamNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Team name', labelStyle: TextStyle(color: _muted)),
            ),
            TextField(
              controller: membersController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Member IDs, comma separated', labelStyle: TextStyle(color: _muted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final members = membersController.text
                  .split(',')
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty)
                  .toList();
              Navigator.pop(context, (teamNameController.text.trim(), members));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    teamNameController.dispose();
    membersController.dispose();
    return result;
  }

  Future<void> _markAttended() async {
    if (event.id.isEmpty) return;
    try {
      await context.read<EventsProvider>().attend(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance recorded')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record attendance: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              bookmarked: _bookmarked,
              onBack: () => Navigator.maybePop(context),
              onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share sheet would open here')),
              ),
              onBookmark: () => setState(() => _bookmarked = !_bookmarked),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  _CoverImage(event: event),
                  const SizedBox(height: 18),

                  // ---------------- Title & badges ----------------
                  Text(
                    event.title.isEmpty ? 'Untitled Event' : event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (event.organizingClub.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          color: _muted,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Hosted by ${event.organizingClub}',
                            style: const TextStyle(color: _muted, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event.category.isNotEmpty)
                        _Badge(text: event.category),
                      _Badge(
                        text: event.isFree
                            ? 'Free'
                            : '₹${_trimZero(event.ticketPrice)}',
                        color: event.isFree ? _green : _pink,
                      ),
                      _Badge(
                        text: event.modeLabel,
                        icon: _modeIcon(event.mode),
                      ),
                      if (event.isTeamEvent)
                        const _Badge(
                          text: 'Team Event',
                          icon: Icons.diversity_3,
                        ),
                    ],
                  ),
                  if (event.tags.isNotEmpty || event.views > 0 || event.status.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (event.status.isNotEmpty) _Badge(text: event.status),
                        if (event.views > 0) _Badge(text: '${event.views} views'),
                        ...event.tags.map((tag) => _Badge(text: '#$tag')),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _TicketRow(
                    event: event,
                  ),
                  const SizedBox(height: 20),

                  // ---------------- Quick info ----------------
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: _formatDate(event.eventDate),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.schedule,
                          label: 'Time',
                          value:
                              '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.people_outline,
                          label: 'Capacity',
                          value: '${event.maxParticipants} spots',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.verified_user_outlined,
                          label: 'Eligibility',
                          value: event.eligibility,
                        ),
                      ),
                    ],
                  ),
                  if (event.maxParticipants > 0) ...[
                    const SizedBox(height: 12),
                    _CapacityBar(
                      used: event.participantsCount,
                      total: event.maxParticipants,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ---------------- About ----------------
                  const _SectionTitle('About this event'),
                  const SizedBox(height: 10),
                  _ExpandableText(
                    text: event.description.isEmpty
                        ? 'No description provided.'
                        : event.description,
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Location ----------------
                  const _SectionTitle('Location'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasVenue)
                          _TappableRow(
                            icon: Icons.location_on_outlined,
                            value: event.venue,
                            trailingIcon: Icons.open_in_new,
                            onTap: _openVenue,
                          ),
                        if (_hasVenue && _hasMeetingLink)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: _cardBorder, height: 1),
                          ),
                        if (_hasMeetingLink)
                          _TappableRow(
                            icon: Icons.videocam_outlined,
                            value: event.meetingLink,
                            trailingIcon: Icons.open_in_new,
                            onTap: _openMeetingLink,
                          ),
                        if (!_hasVenue && !_hasMeetingLink)
                          const Text(
                            'Location not set',
                            style: TextStyle(color: _muted, fontSize: 13),
                          ),
                        if (event.registrationDeadline != null) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: _cardBorder, height: 1),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_busy_outlined,
                                color: _pink,
                                size: 17,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Register before ${_formatDate(event.registrationDeadline!)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Organizer & contact ----------------
                  const _SectionTitle('Organizer & Contact'),
                  const SizedBox(height: 10),
                  _OrganizerCard(
                    event: event,
                    onMessage: _messageHost,
                    onCall: _callHost,
                    onEmail: _emailHost,
                    onCopy: _copy,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _markAttended,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark attendance'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Registration & tickets ----------------

                  if (event.isTeamEvent) ...[
                    const _SectionTitle('Registration Rule'),
                    const SizedBox(height: 10),
                    _NoteRow(
                      icon: Icons.diversity_3,
                      text:
                          'Register as a team of ${event.minTeamSize ?? '-'}–${event.maxTeamSize ?? '-'} members.',
                    ),
                  ],
                  if (event.eligibility == 'Specific Department' &&
                      (event.eligibilityDepartment?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    _NoteRow(
                      icon: Icons.school_outlined,
                      text: 'Open to: ${event.eligibilityDepartment}',
                    ),
                  ],

                  // ---------------- Stay updated ----------------
                  if (event.socialLink.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Stay Updated'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: _TappableRow(
                        icon: Icons.groups_2_outlined,
                        value: event.socialLink,
                        trailingIcon: Icons.open_in_new,
                        onTap: () => _launch(
                          event.socialLink,
                          failureMessage: 'Could not open the link',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (event.impnotice == null) ...[
                    const _SectionTitle("Important Notice"),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF8E8).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Please Read Carefully",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Organizer card, made functional — tapping the email/phone rows launches email or a call; long-press on either copies it to clipboard.  still opens SMS.",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    height: 1.6,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (_isStudent && !_isRegistered && !_isCheckingRegistration)
              _BottomBar(
                amount: _totalAmount,
                isFree: event.isFree,
                isStudent: _isStudent,
                onPressed: _isSubmitting ? null : _buyOrRegister,
              ),
          ],
        ),
      ),
    );
  }

  static IconData _modeIcon(EventMode m) {
    switch (m) {
      case EventMode.offline:
        return Icons.location_on_outlined;
      case EventMode.online:
        return Icons.videocam_outlined;
      case EventMode.hybrid:
        return Icons.hub_outlined;
    }
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _trimZero(double? v) {
    if (v == null) return '0';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
}

// ============================================================= Top bar
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.bookmarked,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
  });

  final bool bookmarked;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _circleIcon(Icons.arrow_back_ios_new, onBack),
          const Expanded(
            child: Text(
              'Event Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _circleIcon(Icons.send_outlined, onShare),
          const SizedBox(width: 8),
          _circleIcon(
            bookmarked ? Icons.bookmark : Icons.bookmark_border,
            onBookmark,
            highlighted: bookmarked,
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(
    IconData icon,
    VoidCallback onTap, {
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _card,
          shape: BoxShape.circle,
          border: Border.all(color: _cardBorder),
        ),
        child: Icon(icon, color: highlighted ? _pink : Colors.white, size: 18),
      ),
    );
  }
}

// ============================================================= Cover image
class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: event.coverImage != null
            ? Image.file(event.coverImage!, fit: BoxFit.cover)
            : event.coverImageUrl.isNotEmpty
                ? Image.network(
                    event.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _card,
                      child: const Center(child: Icon(Icons.image_outlined, color: _muted, size: 40)),
                    ),
                  )
                : Container(
                color: _card,
                child: const Center(
                  child: Icon(Icons.image_outlined, color: _muted, size: 40),
                ),
              ),
      ),
    );
  }
}

// ============================================================= Badge
class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.color, this.icon});
  final String text;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color == null ? _card : c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color == null ? _cardBorder : c),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: c,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================= Info tile
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _pink, size: 17),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================= Section title
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 15,
          decoration: BoxDecoration(
            color: _pink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================= Expandable description
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});
  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;
  static const _collapsedLines = 3;

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(
      color: Color(0xFFD0D0D0),
      fontSize: 13.8,
      height: 1.5,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: _collapsedLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    color: _pink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================= Tappable row (location, links)
class _TappableRow extends StatelessWidget {
  const _TappableRow({
    required this.icon,
    required this.value,
    required this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _pink, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Icon(trailingIcon, color: _muted, size: 15),
        ],
      ),
    );
  }
}

// ============================================================= Note row (team size, eligibility notes)
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pink.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _pink, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================= Organizer card
class _OrganizerCard extends StatelessWidget {
  const _OrganizerCard({
    required this.event,
    required this.onMessage,
    required this.onCall,
    required this.onEmail,
    required this.onCopy,
  });

  final EventModel event;
  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final void Function(String value, {String label}) onCopy;

  @override
  Widget build(BuildContext context) {
    final name = event.contactName.isEmpty
        ? 'Event Organizer'
        : event.contactName;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _pink.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: _pink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      event.organizingClub.isEmpty
                          ? 'Host'
                          : event.organizingClub,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (event.contactEmail.isNotEmpty ||
              event.contactPhone.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: _cardBorder, height: 1),
            ),
            if (event.contactEmail.isNotEmpty)
              _ContactLine(
                icon: Icons.email_outlined,
                value: event.contactEmail,
                onTap: onEmail,
                onLongPress: () =>
                    onCopy(event.contactEmail, label: 'Email copied'),
              ),
            if (event.contactEmail.isNotEmpty && event.contactPhone.isNotEmpty)
              const SizedBox(height: 10),
            if (event.contactPhone.isNotEmpty)
              _ContactLine(
                icon: Icons.call_outlined,
                value: event.contactPhone,
                onTap: onCall,
                onLongPress: () =>
                    onCopy(event.contactPhone, label: 'Phone number copied'),
              ),
          ],
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.value,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, color: _pink, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.copy_rounded, color: _muted, size: 14),
        ],
      ),
    );
  }
}

// ============================================================= Ticket row
class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final label = event.isFree
        ? 'Free Entry'
        : (event.category.isEmpty ? 'General Admission' : event.category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  event.isFree ? 'Free' : '₹${_trimZero(event.ticketPrice)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Text('1 attendee', style: TextStyle(color: _muted, fontSize: 12)),
        ],
      ),
    );
  }

  static String _trimZero(double? v) {
    if (v == null) return '0';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
}

// ============================================================= Capacity bar
class _CapacityBar extends StatelessWidget {
  const _CapacityBar({required this.used, required this.total});
  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    final ratio = (used / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: _card,
            valueColor: const AlwaysStoppedAnimation(_pink),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$used of $total spots registered',
          style: const TextStyle(color: _muted, fontSize: 11.5),
        ),
      ],
    );
  }
}

// ============================================================= Bottom bar
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.amount,
    required this.isFree,
    required this.isStudent,
    required this.onPressed,
  });

  final double amount;
  final bool isFree;
  final bool isStudent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFree ? 'Free' : '₹${_trimZero(amount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isFree ? 'Registration' : 'Per attendee',
                  style: const TextStyle(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 190,
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isStudent ? 'Register Now' : 'Students only',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _trimZero(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }
}
