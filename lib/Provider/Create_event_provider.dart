import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Api/app_api_service.dart';
import '../Api/api_constants.dart';
import '../Model/club.dart';
import '../Model/event_enums.dart';
import '../Model/event_model.dart';
import '../utils/app_constants.dart';
import 'events_provider.dart';
import '../Screen/Events/eventdetail.dart';




class CreateEventProvider extends ChangeNotifier {
  final AppApiService _apiService = AppApiService();
  bool _isSubmitting = false;
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
  final TextEditingController organizingClubRefController = TextEditingController();
  final TextEditingController coverImageUrlController = TextEditingController();
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
  String _selectedClubId = '';
  final List<String> eligibilityOptions = [
    'Open to All',
    ...AppConstants.years.map((year) => '$year Only'),
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
  List<String> get eligibilityDepartments => AppConstants.normalizeBranches(
        eligibilityDepartmentController.text.split(','),
      );
  bool get agreedToTerms => _agreedToTerms;
  bool get isSubmitting => _isSubmitting;
  String get selectedClubId => _selectedClubId;

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

  void toggleEligibilityDepartment(String department) {
    final selected = eligibilityDepartments.toSet();
    if (!selected.add(AppConstants.normalizeBranch(department))) {
      selected.remove(AppConstants.normalizeBranch(department));
    }
    eligibilityDepartmentController.text = selected.join(', ');
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
    if (organizingClubRefController.text.trim().isEmpty) {
      return 'Please add the organizing club reference ID';
    }
    if (contactNameController.text.trim().isEmpty ||
        contactEmailController.text.trim().isEmpty ||
        contactPhoneController.text.trim().isEmpty) {
      return 'Please add complete contact details';
    }
    if (maxParticipantsController.text.trim().isEmpty) {
      return 'Please set a maximum participant count';
    }
    if (int.tryParse(maxParticipantsController.text.trim()) == null ||
        int.parse(maxParticipantsController.text.trim()) < 1) {
      return 'Please enter a valid maximum participant count';
    }
    if (_eventType == null) {
      return 'Please choose Free or Paid';
    }
    if (_eventType == EventType.paid &&
        ticketPriceController.text.trim().isEmpty) {
      return 'Please add a ticket price';
    }
    if (_eventType == EventType.paid &&
        double.tryParse(ticketPriceController.text.trim()) == null) {
      return 'Please enter a valid ticket price';
    }
    if (_isTeamEvent &&
        (minTeamSizeController.text.trim().isEmpty ||
            maxTeamSizeController.text.trim().isEmpty)) {
      return 'Please add min and max team size';
    }
    if (_isTeamEvent &&
        (int.tryParse(minTeamSizeController.text.trim()) == null ||
            int.tryParse(maxTeamSizeController.text.trim()) == null)) {
      return 'Please enter valid team sizes';
    }
    if (_eligibility == 'Specific Department' &&
        eligibilityDepartments.isEmpty) {
      return 'Please add at least one eligible department';
    }
    if (!_agreedToTerms) {
      return 'Please agree to the terms & guidelines';
    }
    return null;
  }
  Future<void> createEvent(BuildContext context) async {
    debugPrint('════════════════════════════════════════════');
    debugPrint('[CreateEvent] 🚀 createEvent() STARTED');

    if (_isSubmitting) {
      debugPrint('[CreateEvent] ⚠️ Already submitting. Returning...');
      return;
    }

    debugPrint('[CreateEvent] Step 1: Validating form...');

    final error = validate();

    if (error != null) {
      debugPrint('[CreateEvent] ❌ Validation failed: $error');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }

      return;
    }

    debugPrint('[CreateEvent] ✅ Validation passed');

    debugPrint('[CreateEvent] Step 2: Reading form values...');

    debugPrint('[CreateEvent] Title: ${titleController.text.trim()}');
    debugPrint('[CreateEvent] Description: ${descriptionController.text.trim()}');
    debugPrint('[CreateEvent] Category: $_category');
    debugPrint('[CreateEvent] Event Date: $_eventDate');
    debugPrint('[CreateEvent] Start Time: $_startTime');
    debugPrint('[CreateEvent] End Time: $_endTime');
    debugPrint('[CreateEvent] Registration Deadline: $_registrationDeadline');
    debugPrint('[CreateEvent] Event Mode: $_eventMode');
    debugPrint('[CreateEvent] Venue: ${venueController.text.trim()}');
    debugPrint('[CreateEvent] Meeting Link: ${meetingLinkController.text.trim()}');
    debugPrint('[CreateEvent] Organizing Club: ${organizingClubController.text.trim()}');
    debugPrint('[CreateEvent] Organizing Club Ref: ${organizingClubRefController.text.trim()}');
    debugPrint('[CreateEvent] Contact Name: ${contactNameController.text.trim()}');
    debugPrint('[CreateEvent] Contact Email: ${contactEmailController.text.trim()}');
    debugPrint('[CreateEvent] Contact Phone: ${contactPhoneController.text.trim()}');
    debugPrint('[CreateEvent] Social Link: ${socialLinkController.text.trim()}');
    debugPrint('[CreateEvent] Max Participants: ${maxParticipantsController.text.trim()}');
    debugPrint('[CreateEvent] Event Type: $_eventType');
    debugPrint('[CreateEvent] Ticket Price: ${ticketPriceController.text.trim()}');
    debugPrint('[CreateEvent] Is Team Event: $_isTeamEvent');
    debugPrint('[CreateEvent] Min Team Size: ${minTeamSizeController.text.trim()}');
    debugPrint('[CreateEvent] Max Team Size: ${maxTeamSizeController.text.trim()}');
    debugPrint('[CreateEvent] Eligibility: $_eligibility');
    debugPrint(
      '[CreateEvent] Eligibility Department: ${eligibilityDepartmentController.text.trim()}',
    );
    debugPrint('[CreateEvent] Important Notice: ${impcontroller.text.trim()}');
    debugPrint('[CreateEvent] Cover Image: $_coverImage');
    debugPrint(
      '[CreateEvent] Cover Image URL: ${coverImageUrlController.text.trim()}',
    );
    debugPrint('[CreateEvent] Agreed To Terms: $_agreedToTerms');

    try {
      debugPrint('[CreateEvent] Step 3: Creating EventModel...');

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
        maxParticipants: int.parse(
          maxParticipantsController.text.trim(),
        ),
        type: _eventType!,
        ticketPrice: _eventType == EventType.paid
            ? double.tryParse(ticketPriceController.text.trim())
            : null,
        isTeamEvent: _isTeamEvent,
        minTeamSize: _isTeamEvent
            ? int.tryParse(minTeamSizeController.text.trim())
            : null,
        maxTeamSize: _isTeamEvent
            ? int.tryParse(maxTeamSizeController.text.trim())
            : null,
        eligibility: _eligibility,
        eligibilityDepartment: _eligibility == 'Specific Department'
            ? eligibilityDepartmentController.text.trim()
            : null,
        impnotice: impcontroller.text.trim().isEmpty
            ? null
            : impcontroller.text.trim(),
        coverImageUrl: coverImageUrlController.text.trim(),
      );

      debugPrint('[CreateEvent] ✅ EventModel created successfully');

      debugPrint('[CreateEvent] Step 4: Setting submitting state...');

      _isSubmitting = true;
      notifyListeners();

      debugPrint('[CreateEvent] _isSubmitting = $_isSubmitting');

      debugPrint('[CreateEvent] Step 5: Creating API request body...');

      final requestBody = {
        ...event.toApiJson(),
        'agreedToTerms': _agreedToTerms,
        'organizingClubRef': organizingClubRefController.text.trim(),
        if (event.impnotice != null) 'notes': event.impnotice,
      };

      debugPrint('[CreateEvent] ✅ Request body created');
      debugPrint('[CreateEvent] API URL: ${ApiConstants.events}');
      debugPrint('[CreateEvent] HTTP Method: POST');
      debugPrint('[CreateEvent] Payload: $requestBody');

      debugPrint('[CreateEvent] Step 6: Sending API request...');

      final response = await _apiService.createEvent(requestBody);

      debugPrint('[CreateEvent] ✅ API request completed');
      debugPrint('[CreateEvent] Raw API response: $response');

      debugPrint('[CreateEvent] Step 7: Extracting event payload...');

      final remoteEvent = _eventPayload(response);

      debugPrint('[CreateEvent] Remote event payload: $remoteEvent');

      debugPrint('[CreateEvent] Step 8: Creating EventModel from API response...');

      final createdEvent = EventModel.fromJson({
        ...event.toApiJson(),
        'organizingClubRef': organizingClubRefController.text.trim(),
        if (event.impnotice != null) 'notes': event.impnotice,
        ...remoteEvent,
      });

      debugPrint('[CreateEvent] ✅ Created EventModel from response');
      debugPrint('[CreateEvent] Created Event: $createdEvent');

      if (!context.mounted) {
        debugPrint('[CreateEvent] ⚠️ Context is no longer mounted');
        return;
      }

      debugPrint('[CreateEvent] Step 9: Refreshing events list...');

      await context.read<EventsProvider>().loadEvents(refresh: true);

      debugPrint('[CreateEvent] ✅ Events list refreshed');

      debugPrint('[CreateEvent] Step 10: Navigating to EventDetailScreen...');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(
            event: createdEvent,
          ),
        ),
      );

      debugPrint('[CreateEvent] ✅ Navigation completed');
      debugPrint('[CreateEvent] 🎉 EVENT CREATED SUCCESSFULLY');
    } on DioException catch (error, stackTrace) {
      debugPrint('════════════════════════════════════════════');
      debugPrint('[CreateEvent] ❌ DIO EXCEPTION');
      debugPrint('[CreateEvent] Error: $error');
      debugPrint('[CreateEvent] Message: ${error.message}');
      debugPrint('[CreateEvent] Type: ${error.type}');
      debugPrint('[CreateEvent] Method: ${error.requestOptions.method}');
      debugPrint('[CreateEvent] URL: ${error.requestOptions.uri}');
      debugPrint('[CreateEvent] Request Headers: ${error.requestOptions.headers}');
      debugPrint('[CreateEvent] Request Data: ${error.requestOptions.data}');
      debugPrint('[CreateEvent] HTTP Status: ${error.response?.statusCode}');
      debugPrint('[CreateEvent] Response Headers: ${error.response?.headers}');
      debugPrint('[CreateEvent] Server Response: ${error.response?.data}');
      debugPrint('[CreateEvent] StackTrace: $stackTrace');
      debugPrint('════════════════════════════════════════════');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not create event: '
                  '${error.response?.data ?? error.message}',
            ),
          ),
        );
      }
    } on FormatException catch (error, stackTrace) {
      debugPrint('════════════════════════════════════════════');
      debugPrint('[CreateEvent] ❌ FORMAT EXCEPTION');
      debugPrint('[CreateEvent] Error: $error');
      debugPrint('[CreateEvent] StackTrace: $stackTrace');
      debugPrint('════════════════════════════════════════════');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid event data: $error'),
          ),
        );
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('════════════════════════════════════════════');
      debugPrint('[CreateEvent] ❌ GENERAL EXCEPTION');
      debugPrint('[CreateEvent] Error: $error');
      debugPrint('[CreateEvent] StackTrace: $stackTrace');
      debugPrint('════════════════════════════════════════════');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not create event: $error'),
          ),
        );
      }
    } finally {
      debugPrint('[CreateEvent] Step 11: Resetting submitting state...');

      _isSubmitting = false;
      notifyListeners();

      debugPrint('[CreateEvent] _isSubmitting = $_isSubmitting');
      debugPrint('[CreateEvent] 🏁 createEvent() FINISHED');
      debugPrint('════════════════════════════════════════════');
    }
  }

  Map<String, dynamic> _eventPayload(Map<String, dynamic> response) {
    dynamic payload = response['event'] ?? response['data'] ?? response;
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final nested = map['event'];
      return nested is Map ? Map<String, dynamic>.from(nested) : map;
    }
    return const {};
  }

  void selectOrganizingClub(Club club) {
    organizingClubController.text = club.name;
    _selectedClubId = club.id;
    organizingClubRefController.text = club.ownerUserId;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    meetingLinkController.dispose();
    organizingClubController.dispose();
    organizingClubRefController.dispose();
    coverImageUrlController.dispose();
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