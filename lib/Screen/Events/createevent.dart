import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/event_enums.dart';
import '../../Provider/Create_event_provider.dart';


const _bg = Color(0xFF1A1A1A);
const _card = Color(0xFF262626);
const _cardBorder = Color(0xFF3A3A3A);
const _pink = Color(0xFFE8395C);
const _muted = Color(0xFFA0A0A0);

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateEventProvider(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Event',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Expanded(child: _CreateEventForm()),
              const _CreateEventButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateEventForm extends StatelessWidget {
  const _CreateEventForm();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateEventProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        // ---------------- Cover image ----------------
        GestureDetector(
          onTap: () => provider.pickImage(context),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: provider.coverImage != null
                      ? Image.file(provider.coverImage!, fit: BoxFit.cover)
                      : Container(
                    color: _card,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              color: _muted, size: 36),
                          SizedBox(height: 8),
                          Text('Tap to add a cover photo / poster',
                              style: TextStyle(color: _muted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Add', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ---------------- Basic details ----------------
        const _SectionHeader('Basic Details'),
        _label('Event Title'),
        TextField(
          controller: provider.titleController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: 'e.g. TechFest 2026'),
        ),
        const SizedBox(height: 16),

        _label('Description'),
        TextField(
          controller: provider.descriptionController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, height: 1.4),
          decoration: _fieldDecoration(hint: 'What is this event about?'),
        ),
        const SizedBox(height: 16),

        _label('Event Category'),
        _pickerField(
          value: provider.category.isEmpty ? 'Select a category' : provider.category,
          onTap: () => provider.showCategoryPicker(context),
          isPlaceholder: provider.category.isEmpty,
        ),
        const SizedBox(height: 24),

        // ---------------- Date & time ----------------
        const _SectionHeader('Date & Time'),
        Row(
          children: [
            Expanded(
              child: _pickerField(
                label: 'Event Date',
                value: provider.eventDate == null
                    ? 'Select date'
                    : _formatDate(provider.eventDate!),
                onTap: () => provider.pickEventDate(context),
                isPlaceholder: provider.eventDate == null,
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _pickerField(
                label: 'Start Time',
                value: provider.startTime == null
                    ? 'Select time'
                    : provider.startTime!.format(context),
                onTap: () => provider.pickStartTime(context),
                isPlaceholder: provider.startTime == null,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _pickerField(
                label: 'End Time',
                value: provider.endTime == null
                    ? 'Select time'
                    : provider.endTime!.format(context),
                onTap: () => provider.pickEndTime(context),
                isPlaceholder: provider.endTime == null,
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _pickerField(
          label: 'Registration Deadline',
          value: provider.registrationDeadline == null
              ? 'Select date'
              : _formatDate(provider.registrationDeadline!),
          onTap: () => provider.pickRegistrationDeadline(context),
          isPlaceholder: provider.registrationDeadline == null,
          icon: Icons.event_available_outlined,
        ),
        const SizedBox(height: 24),

        // ---------------- Location ----------------
        const _SectionHeader('Location'),
        _label('Event Mode'),
        Row(
          children: [
            Expanded(
              child: _ChipOption(
                label: 'Offline',
                selected: provider.eventMode == EventMode.offline,
                onTap: () => provider.eventMode = EventMode.offline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChipOption(
                label: 'Online',
                selected: provider.eventMode == EventMode.online,
                onTap: () => provider.eventMode = EventMode.online,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChipOption(
                label: 'Hybrid',
                selected: provider.eventMode == EventMode.hybrid,
                onTap: () => provider.eventMode = EventMode.hybrid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.eventMode != EventMode.online) ...[
          _label('Venue'),
          TextField(
            controller: provider.venueController,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(
                hint: 'e.g. Main Auditorium, Block C'),
          ),
          const SizedBox(height: 16),
        ],
        if (provider.eventMode != EventMode.offline) ...[
          _label('Online Meeting Link'),
          TextField(
            controller: provider.meetingLinkController,
            style: const TextStyle(color: Colors.white),
            decoration:
            _fieldDecoration(hint: 'Zoom / Google Meet / MS Teams link'),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),

        // ---------------- Organizer & contact ----------------
        const _SectionHeader('Organizer & Contact'),
        _label('Organizing Club / Department'),
        TextField(
          controller: provider.organizingClubController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: 'e.g. Computer Science Society'),
        ),
        const SizedBox(height: 16),

        _label('Contact Person Name'),
        TextField(
          controller: provider.contactNameController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: 'Point of contact for queries'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Contact Email'),
                  TextField(
                    controller: provider.contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _fieldDecoration(hint: 'club@college.edu'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label('Contact Phone'),
        TextField(
          controller: provider.contactPhoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: '+91 98765 43210'),
        ),
        const SizedBox(height: 16),

        _label('WhatsApp / Social Group Link (optional)'),
        TextField(
          controller: provider.socialLinkController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: 'Group link for updates'),
        ),
        const SizedBox(height: 24),

        // ---------------- Registration & capacity ----------------
        const _SectionHeader('Registration & Capacity'),
        _label('Maximum Participants'),
        TextField(
          controller: provider.maxParticipantsController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: 'e.g. 150'),
        ),
        const SizedBox(height: 16),

        _label('Event Type'),
        Row(
          children: [
            Expanded(
              child: _EventTypeOption(
                label: 'Free',
                selected: provider.eventType == EventType.free,
                onTap: () => provider.eventType = EventType.free,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EventTypeOption(
                label: 'Paid',
                selected: provider.eventType == EventType.paid,
                onTap: () => provider.eventType = EventType.paid,
              ),
            ),
          ],
        ),
        if (provider.eventType == EventType.paid) ...[
          const SizedBox(height: 16),
          _label('Ticket Price (per head)'),
          TextField(
            controller: provider.ticketPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(hint: '₹ 0.00'),
          ),
        ],
        const SizedBox(height: 16),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: _pink,
          tileColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _cardBorder),
          ),
          title: const Text('Team Event',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          subtitle: const Text('Toggle on if participants register as teams',
              style: TextStyle(color: _muted, fontSize: 12)),
          value: provider.isTeamEvent,
          onChanged: (v) => provider.isTeamEvent = v,
        ),
        if (provider.isTeamEvent) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Min Team Size'),
                    TextField(
                      controller: provider.minTeamSizeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(hint: '2'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Max Team Size'),
                    TextField(
                      controller: provider.maxTeamSizeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(hint: '5'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // ---------------- Eligibility ----------------
        const _SectionHeader('Eligibility'),
        _pickerField(
          value: provider.eligibility,
          onTap: () => provider.showEligibilityPicker(context),
          isPlaceholder: false,
        ),
        if (provider.eligibility == 'Specific Department') ...[
          const SizedBox(height: 16),
          _label('Which Department(s)'),
          TextField(
            controller: provider.eligibilityDepartmentController,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(hint: 'e.g. CSE, IT, ECE'),
          ),
        ],
        const SizedBox(height: 24),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Imp Notes(Optional'),
              TextField(
                controller: provider.impcontroller,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration(hint: 'Write here'),
              ),
            ],
          ),
        ),

        // ---------------- Terms ----------------
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: _pink,
          checkColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          value: provider.agreedToTerms,
          onChanged: (v) => provider.agreedToTerms = v ?? false,
          title: const Text(
            'I confirm this event follows college guidelines and has faculty approval',
            style: TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: _muted, fontSize: 13.5, fontWeight: FontWeight.w500),
      ),
    );
  }

  static InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: _card,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _pink),
      ),
    );
  }

  static Widget _pickerField({
    String? label,
    required String value,
    required VoidCallback onTap,
    required bool isPlaceholder,
    IconData icon = Icons.keyboard_arrow_down,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _label(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isPlaceholder ? _muted : Colors.white,
                  ),
                ),
                Icon(icon, color: _muted, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: _pink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipOption extends StatelessWidget {
  const _ChipOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _pink.withValues(alpha: 0.15) : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _pink : _cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _pink : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _EventTypeOption extends StatelessWidget {
  const _EventTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _pink : _cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _pink : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _CreateEventButton extends StatelessWidget {
  const _CreateEventButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CreateEventProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => provider.createEvent(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Create Event',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}