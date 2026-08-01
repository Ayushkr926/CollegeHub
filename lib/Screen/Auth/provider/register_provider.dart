import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Api/api_clients.dart';
import '../../../Api/api_constants.dart';
import '../../../Model/user_role.dart';

import '../../../storage/local_storage.dart';
import '../../../utils/app_routes.dart';

class RegisterProvider extends ChangeNotifier {
  // Text Editing Controllers
  final _formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String? get errorMessage => _errorMessage;

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //student_registration_screen
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedYear;
  bool _acceptedTerms = false;
  bool _termsError = false;
  String buttomtext = "Create Account";

  // Getters
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;
  TextEditingController get rollNumberController => _rollNumberController;
  TextEditingController get courseController => _courseController;
  TextEditingController get branchController => _branchController;
  TextEditingController get phoneController => _phoneController;

  String? get selectedYear => _selectedYear;
  bool get acceptedTerms => _acceptedTerms;
  bool get termsError => _termsError;
  GlobalKey<FormState> get formkey => _formKey;

  // Setters
  void setSelectedYear(String? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setAcceptedTerms(bool value) {
    _acceptedTerms = value;
    _termsError = false;
    notifyListeners();
  }

  void setTermsError(bool value) {
    _termsError = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _courseController.dispose();
    _branchController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Extracts the leading integer from a value like "3rd Year" -> 3.
  /// Falls back to 0 if nothing numeric is found.
  int _yearToInt(String? value) {
    if (value == null) return 0;
    final match = RegExp(r'\d+').firstMatch(value);
    if (match == null) return 0;
    return int.tryParse(match.group(0)!) ?? 0;
  }

  Future<void> handleCreateAccount(BuildContext context) async {
    debugPrint("========== REGISTER STARTED ==========");

    final isFormValid = _formKey.currentState!.validate();
    final isTermsAccepted = _acceptedTerms;

    debugPrint("Form Valid: $isFormValid");
    debugPrint("Terms Accepted: $isTermsAccepted");

    _termsError = !isTermsAccepted;
    notifyListeners();

    if (!isFormValid || !isTermsAccepted) {
      debugPrint("Registration stopped due to validation.");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    buttomtext = "Loading";
    notifyListeners();

    try {
      final payload = {
        "name": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "phoneNumber": phoneController.text.trim(),
        "rollNumber": rollNumberController.text.trim(),
        "branch": branchController.text.trim(),
        "course": courseController.text.trim(),
        "year": _yearToInt(selectedYear),
      };

      debugPrint("Sending registration request...");
      debugPrint(payload.toString());

      debugPrint("api is ${ApiConstants.studentRegister}");

      final response = await ApiClient.dio.post(
        ApiConstants.studentRegister,
        data: payload,
      );

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Parsing response...");

        // Dio already decodes the JSON body into a Map, so use fromJson
        // (NOT fromRawJson, which expects a raw JSON String).
        final responseModel = RegisterResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        debugPrint("Parsed Model: $responseModel");

        if (!responseModel.isValid) {
          debugPrint("Response model is invalid.");

          final message = (responseModel.error?.isNotEmpty ?? false)
              ? responseModel.error!
              : (responseModel.message.isNotEmpty
              ? responseModel.message
              : "Registration failed. Please try again.");

          _errorMessage = message;

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
          return;
        }

        final auth = responseModel.data!;

        debugPrint("Saving user to LocalStorage...");
        debugPrint("Token: ${auth.token}");
        debugPrint("Student: ${auth.user.toJson()}");

        await LocalStorageService.instance.setModel(
          StorageKeys.userProfile,
          auth.user,
              (s) => s.toJson(),
        );

        await LocalStorageService.instance.setString(
          StorageKeys.authToken,
          auth.token,
        );

        debugPrint("LocalStorage saved successfully.");

        if (context.mounted) {
          debugPrint("Navigating to Registration Success...");
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.registrationSuccess,
          );
        }
      } else {
        debugPrint("Unexpected status code: ${response.statusCode}");
        const message = "Registration failed. Please try again.";
        _errorMessage = message;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(message)),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint("========== DIO EXCEPTION ==========");
      debugPrint("Message: ${e.message}");
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Response: ${e.response?.data}");

      String message = "Registration failed.";

      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          message = data["message"] ?? data["error"] ?? message;
        }
      } else {
        message = e.message ?? message;
      }

      _errorMessage = message;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("========== UNKNOWN ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      const message = "Something went wrong. Please try again.";
      _errorMessage = message;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(message)),
        );
      }
    } finally {
      debugPrint("Registration finished.");

      _isLoading = false;
      buttomtext = "Create Account";
      notifyListeners();

      debugPrint("========== REGISTER END ==========");
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Registration Logic (unused placeholder — kept as-is; consider removing
  // if `handleCreateAccount` is the real registration flow).
  Future<bool> register(BuildContext context) async {
    if (!_validateInputs()) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      await Future.delayed(const Duration(seconds: 2));

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  bool _validateInputs() {
    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = "Passwords do not match";
      notifyListeners();
      return false;
    }
    if (passwordController.text.length < 6) {
      _errorMessage = "Password must be at least 6 characters";
      notifyListeners();
      return false;
    }
    return true;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}