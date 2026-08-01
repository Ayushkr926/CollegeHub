// lib/providers/club_registration_provider.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Api/api_clients.dart';
import '../../../Api/api_constants.dart';
import '../../../utils/app_routes.dart';


class ClubRegistrationProvider extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────
  File? _logoFile;
  String? _selectedCategory;
  bool _isOfficialClub = false;
  bool _officialClubError = false;
  bool _isLoading = false;
  String? _error;
  String _buttonText = 'Submit Club Request';

  // ── Getters ──────────────────────────────────────────────────
  File? get logoFile => _logoFile;
  String? get selectedCategory => _selectedCategory;
  bool get isOfficialClub => _isOfficialClub;
  bool get officialClubError => _officialClubError;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLogo => _logoFile != null;
  String get buttonText => _buttonText;

  // ── Logo ─────────────────────────────────────────────────────
  Future<void> pickLogo({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      _logoFile = File(file.path);
      notifyListeners();
    } catch (e) {
      _error = 'Could not pick image: $e';
      notifyListeners();
    }
  }

  void removeLogo() {
    _logoFile = null;
    notifyListeners();
  }

  // ── Form fields ──────────────────────────────────────────────
  void setCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setOfficialClub(bool value) {
    _isOfficialClub = value;
    if (value) _officialClubError = false;
    notifyListeners();
  }

  // ── Submit ───────────────────────────────────────────────────
  /// Call this from the screen AFTER the Form has been validated.
  /// Pass the controller values in — provider never owns TextEditingControllers.
  Future<bool> handleCreateClub(
      BuildContext context, {
        required String clubName,
        required String email,
        required String password,
        required String facultyName,
        required String facultyEmail,
        required String description,
        required String phone,
      }) async {
    debugPrint("\n========== CLUB REGISTER START ==========");
    debugPrint("Club Name      : $clubName");
    debugPrint("Email          : $email");
    debugPrint("Password       : ${'*' * password.length}");
    debugPrint("Category       : $_selectedCategory");
    debugPrint("Faculty Name   : $facultyName");
    debugPrint("Faculty Email  : $facultyEmail");
    debugPrint("Phone          : $phone");
    debugPrint("Description    : $description");
    debugPrint("Official Club  : $_isOfficialClub");

    // 1. Confirmation checkbox
    if (!_isOfficialClub) {
      _officialClubError = true;
      notifyListeners();
      debugPrint("Registration stopped: Official club checkbox not checked.");
      return false;
    }

    // 2. Category required
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _error = 'Please select a category';
      notifyListeners();
      debugPrint("Registration stopped: No category selected.");
      return false;
    }

    _isLoading = true;
    _error = null;
    _officialClubError = false;
    _buttonText = 'Submitting...';
    notifyListeners();

    try {
      final formData = {
        'clubName': clubName.trim(),
        'email': email.trim(),
        'password': password,
        'category': _selectedCategory,
        'description': description.trim(),
        'phone': phone.trim(),
        'facultyName': facultyName.trim(),
        'facultyEmail': facultyEmail.trim(),
      };

      debugPrint("\n========== REQUEST ==========");
      debugPrint("URL: ${ApiConstants.organiserRegister}");

      debugPrint("Headers:");
      ApiClient.dio.options.headers.forEach((key, value) {
        debugPrint("$key : $value");
      });





      final response = await ApiClient.dio.post(
        ApiConstants.organiserRegister,
        data: formData,
      );

      debugPrint("\n========== RESPONSE ==========");
      debugPrint("Status Code : ${response.statusCode}");
      debugPrint("Status      : ${response.statusMessage}");
      debugPrint("Response    : ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Club registration successful.");

        if (context.mounted) {
          debugPrint("Navigating to registration success screen.");
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.registrationSuccess,
          );
        }

        return true;
      }

      _error = 'Registration failed. Please try again.';
      debugPrint("Unexpected Status Code: ${response.statusCode}");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }

      return false;
    } on DioException catch (e) {
      debugPrint("\n========== DIO EXCEPTION ==========");
      debugPrint("Type        : ${e.type}");
      debugPrint("Message     : ${e.message}");
      debugPrint("Status Code : ${e.response?.statusCode}");
      debugPrint("Headers     : ${e.response?.headers}");
      debugPrint("Response    : ${e.response?.data}");
      debugPrint("Request URL : ${e.requestOptions.uri}");
      debugPrint("Method      : ${e.requestOptions.method}");

      String message = 'Registration failed.';

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        message = data['message'] ?? data['error'] ?? message;
      } else if (e.message != null) {
        message = e.message!;
      }

      _error = message;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint("\n========== UNKNOWN ERROR ==========");
      debugPrint("Error:");
      debugPrint(e.toString());

      debugPrint("\nStackTrace:");
      debugPrint(stackTrace.toString());

      _error = 'Something went wrong. Please try again.';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }

      return false;
    } finally {
      _isLoading = false;
      _buttonText = 'Submit Club Request';
      notifyListeners();

      debugPrint("Loading: $_isLoading");
      debugPrint("Error  : $_error");
      debugPrint("========== CLUB REGISTER END ==========\n");
    }
  }

  // ── Helpers ──────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Call when leaving the screen so the next open starts clean.
  void reset() {
    _logoFile = null;
    _selectedCategory = null;
    _isOfficialClub = false;
    _officialClubError = false;
    _isLoading = false;
    _error = null;
    _buttonText = 'Submit Club Request';
    notifyListeners();
  }
}