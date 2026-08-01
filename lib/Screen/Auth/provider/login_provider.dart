import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Api/api_clients.dart';
import '../../../Api/api_constants.dart';

import '../../../Model/user_role.dart';
import '../../../storage/local_storage.dart';
import '../../../utils/app_routes.dart';

class LoginProvider extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(

        ApiConstants.studentLogin,
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseModel = RegisterResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (!responseModel.isValid) {
          final message = (responseModel.error?.isNotEmpty ?? false)
              ? responseModel.error!
              : (responseModel.message.isNotEmpty
              ? responseModel.message
              : "Login failed. Please check your credentials.");

          _errorMessage = message;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
          return;
        }

        final auth = responseModel.data!;

        await LocalStorageService.instance.setModel(
          StorageKeys.userProfile,
          auth.user,
              (s) => s.toJson(),
        );
        await LocalStorageService.instance.setString(
          StorageKeys.authToken,
          auth.token,
        );
        print("role is ${auth.user.role}");
        await LocalStorageService.instance.setString(
          StorageKeys.userrole,
          auth.user.role == Role.clubHead ? "organiser":"student",
        );
        await LocalStorageService.instance.setBool(
          StorageKeys.isLoggedIn,
          true,
        );

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
                (route) => false,
          );
        }
      } else {
        const message = "Login failed. Please try again.";
        _errorMessage = message;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(message)),
          );
        }
      }
    } on DioException catch (e) {
      String message = "Login failed.";

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
    } catch (_) {
      const message = "Something went wrong. Please try again.";
      _errorMessage = message;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(message)),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}