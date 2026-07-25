import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Model/event_enums.dart';
import '../Model/event_model.dart';
import '../Screen/Events/eventdetail.dart';




class CreateEventProvider extends ChangeNotifier {
  // ---------------- Basic details ----------------
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String _category = '';

  final List<Map<String, dynamic>> categories = [
    {"name": "Academic", "icon": Icons.school},
    {"name": "Technical", "icon": Icons.computer},
    {"name": "Career", "icon": Icons.work},
    {"name": "Entrepreneurship", "icon": Icons.lightbulb},
    {"name": "Cultural", "icon": Icons.theater_comedy},
    {"name": "Sports", "icon": Icons.sports_soccer},
    {"name": "Club Activities", "icon": Icons.groups},
    {"name": "Social", "icon": Icons.volunteer_activism},
    {"name": "Celebrations", "icon": Icons.celebration},
    {"name": "Administration", "icon": Icons.campaign},
  ];

  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  // ---------------- Date & time ----------------
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _registrationDeadline;

  // ---------------- Location ----------------
  EventMode _eventMode = EventMode.offline;
  final TextEditingController venueController = TextEditingController();
  final TextEditingController meetingLinkController = TextEditingController();

  // ---------------- Organizer & contact ----------------
  final TextEditingController organizingClubController =
  TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactEmailController =
  TextEditingController();
  final TextEditingController contactPhoneController =
  TextEditingController();

  // ---------------- Registration & capacity ----------------
  final TextEditingController maxParticipantsController =
  TextEditingController();
  EventType? _eventType;
  final TextEditingController ticketPriceController = TextEditingController();

  final TextEditingController impcontroller = TextEditingController();

  bool _isTeamEvent = false;
  final TextEditingController minTeamSizeController = TextEditingController();
  final TextEditingController maxTeamSizeController = TextEditingController();

  // ---------------- Eligibility ----------------
  String _eligibility = 'Open to All';
  final List<String> eligibilityOptions = [
    'Open to All',
    '1st Year Only',
    '2nd Year Only',
    '3rd Year Only',
    'Final Year Only',
    'Specific Department',
  ];
  final TextEditingController eligibilityDepartmentController =
  TextEditingController();

  // ---------------- Additional ----------------
  final TextEditingController socialLinkController = TextEditingController();
  bool _agreedToTerms = false;

  // ================= Getters =================
  String get category => _category;
  File? get coverImage => _coverImage;
  DateTime? get eventDate => _eventDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  DateTime? get registrationDeadline => _registrationDeadline;
  EventMode get eventMode => _eventMode;
  EventType? get eventType => _eventType;
  bool get isTeamEvent => _isTeamEvent;
  String get eligibility => _eligibility;
  bool get agreedToTerms => _agreedToTerms;

  // ================= Setters =================
  set category(String newCategory) {
    _category = newCategory;
    notifyListeners();
  }

  set coverImage(File? image) {
    _coverImage = image;
    notifyListeners();
  }

  set eventType(EventType? newType) {
    _eventType = newType;
    notifyListeners();
  }

  set eventMode(EventMode mode) {
    _eventMode = mode;
    notifyListeners();
  }

  set isTeamEvent(bool value) {
    _isTeamEvent = value;
    notifyListeners();
  }

  set eligibility(String value) {
    _eligibility = value;
    notifyListeners();
  }

  set agreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  // ================= Pickers =================
  Future<void> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined,
                    color: Colors.white),
                title: const Text('Take a photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: Colors.white),
                title: const Text('Choose from gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_coverImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: Color(0xFFE8395C)),
                  title: const Text('Remove photo',
                      style: TextStyle(color: Color(0xFFE8395C))),
                  onTap: () => Navigator.pop(context, null),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) {
      coverImage = null;
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (picked != null) {
        coverImage = File(picked.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open image picker: $e')),
        );
      }
    }
  }

  Future<void> pickEventDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      _eventDate = picked;
      notifyListeners();
    }
  }

  Future<void> pickRegistrationDeadline(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDeadline ?? now,
      firstDate: now,
      lastDate: _eventDate ?? DateTime(now.year + 3),
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      _registrationDeadline = picked;
      notifyListeners();
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) => _timePickerTheme(child),
    );
    if (picked != null) {
      _startTime = picked;
      notifyListeners();
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) => _timePickerTheme(child),
    );
    if (picked != null) {
      _endTime = picked;
      notifyListeners();
    }
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8395C),
          onPrimary: Colors.white,
          surface: Color(0xFF262626),
          onSurface: Colors.white,
        ),
      ),
      child: child!,
    );
  }

  Widget _timePickerTheme(Widget? child) => _datePickerTheme(child);

  void showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xff1F1F1F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Category",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final c = categories[index];
                  final selected = category == c["name"];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      category = c["name"];
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xff4F46E5)
                            : const Color(0xff2D2D2D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xff4F46E5)
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(c["icon"], color: Colors.white),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              c["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle,
                                color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showEligibilityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              for (final e in eligibilityOptions)
                ListTile(
                  title:
                  Text(e, style: const TextStyle(color: Colors.white)),
                  trailing: e == _eligibility
                      ? const Icon(Icons.check, color: Color(0xFFE8395C))
                      : null,
                  onTap: () {
                    eligibility = e;
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ================= Validation & submit =================
  String? validate() {
    if (titleController.text.trim().isEmpty) {
      return 'Please add an event title';
    }
    if (_category.isEmpty) {
      return 'Please select an event category';
    }
    if (_eventDate == null) {
      return 'Please pick an event date';
    }
    if (_startTime == null || _endTime == null) {
      return 'Please pick a start and end time';
    }
    if (_eventMode != EventMode.online && venueController.text.trim().isEmpty) {
      return 'Please add a venue';
    }
    if (_eventMode != EventMode.offline &&
        meetingLinkController.text.trim().isEmpty) {
      return 'Please add an online meeting link';
    }
    if (organizingClubController.text.trim().isEmpty) {
      return 'Please add the organizing club or department';
    }
    if (contactNameController.text.trim().isEmpty ||
        contactEmailController.text.trim().isEmpty ||
        contactPhoneController.text.trim().isEmpty) {
      return 'Please add complete contact details';
    }
    if (maxParticipantsController.text.trim().isEmpty) {
      return 'Please set a maximum participant count';
    }
    if (_eventType == null) {
      return 'Please choose Free or Paid';
    }
    if (_eventType == EventType.paid &&
        ticketPriceController.text.trim().isEmpty) {
      return 'Please add a ticket price';
    }
    if (_isTeamEvent &&
        (minTeamSizeController.text.trim().isEmpty ||
            maxTeamSizeController.text.trim().isEmpty)) {
      return 'Please add min and max team size';
    }
    if (!_agreedToTerms) {
      return 'Please agree to the terms & guidelines';
    }
    return null;
  }

  void createEvent(BuildContext context) {
    final error = validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final event = EventModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: _category,
      coverImage: _coverImage,
      eventDate: _eventDate!,
      startTime: _startTime!,
      endTime: _endTime!,
      registrationDeadline: _registrationDeadline,
      mode: _eventMode,
      venue: venueController.text.trim(),
      meetingLink: meetingLinkController.text.trim(),
      organizingClub: organizingClubController.text.trim(),
      contactName: contactNameController.text.trim(),
      contactEmail: contactEmailController.text.trim(),
      contactPhone: contactPhoneController.text.trim(),
      socialLink: socialLinkController.text.trim(),
      maxParticipants: int.parse(maxParticipantsController.text.trim()),
      type: _eventType!,
      ticketPrice: _eventType == EventType.paid
          ? double.tryParse(ticketPriceController.text.trim())
          : null,
      isTeamEvent: _isTeamEvent,
      minTeamSize:
      _isTeamEvent ? int.tryParse(minTeamSizeController.text.trim()) : null,
      maxTeamSize:
      _isTeamEvent ? int.tryParse(maxTeamSizeController.text.trim()) : null,
      eligibility: _eligibility,
      eligibilityDepartment: _eligibility == 'Specific Department'
          ? eligibilityDepartmentController.text.trim()
          : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    meetingLinkController.dispose();
    organizingClubController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    maxParticipantsController.dispose();
    ticketPriceController.dispose();
    minTeamSizeController.dispose();
    maxTeamSizeController.dispose();
    eligibilityDepartmentController.dispose();
    socialLinkController.dispose();
    impcontroller.dispose();
    super.dispose();
  }
}