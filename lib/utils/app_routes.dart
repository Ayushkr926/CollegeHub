import 'package:college/Screen/Clubs/discover_clubs_screen.dart';
import 'package:college/Screen/Profile/Profilescreen.dart';
import 'package:college/Screen/Profile/studentprofile.dart';
import 'package:college/Screen/Request/requestscreen.dart';
import 'package:college/onboarding/HomeScreen.dart';
import 'package:flutter/material.dart';
import '../Model/user_role.dart';
import '../Screen/Auth/club_registration_screen.dart';
import '../Screen/Auth/email_verification_screen.dart';
import '../Screen/Auth/forgot_password_screen.dart';
import '../Screen/Auth/login_screen.dart';
import '../Screen/Auth/registration_success_screen.dart';
import '../Screen/Auth/select_role_screen.dart';
import '../Screen/Auth/splash_screen.dart';
import '../Screen/Auth/student_registration_screen.dart';
import '../Screen/Auth/welcome_screen.dart';
import '../Screen/Events/createevent.dart';
import '../onboarding/onboarding_screen.dart';

/// Centralized route names for the authentication module.
/// GoRouter-ready: swap [AppRoutes.onGenerateRoute] for a GoRouter config
/// later without touching call sites, since navigation always goes
/// through these named constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String selectRole = '/select-role';
  static const String studentRegistration = '/register/student';
  static const String clubRegistration = '/register/club';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/verify-email';
  static const String registrationSuccess = '/registration-success';
  static const String home = '/Home';
  static const String clubprofile = '/clubprofile';
  static const String stuprofile = '/stuprofile';
  static const String clubs = '/clubs';
  static const String request = '/request';
  static const String createevent = '/createevent';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);
      case welcome:
        return _fadeRoute(const WelcomeScreen(), settings);
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case selectRole:
        return _fadeRoute(const SelectRoleScreen(), settings);
      case studentRegistration:
        return _fadeRoute(const StudentRegistrationScreen(), settings);
      case clubRegistration:
        return _fadeRoute(const ClubRegistrationScreen(), settings);
      case forgotPassword:
        return _fadeRoute(const ForgotPasswordScreen(), settings);
      case emailVerification:
        return _fadeRoute(const EmailVerificationScreen(), settings);
      case registrationSuccess:
        return _fadeRoute(const RegistrationSuccessScreen(), settings);
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      case clubprofile:
        return _fadeRoute(const ClubProfileScreen(), settings);
      case stuprofile:
        return _fadeRoute(const ProfileScreen(), settings);
      case clubs:
        return _fadeRoute(const DiscoverClubsScreen(), settings);
      case request:
        return _fadeRoute(const Requestscreen(), settings);
      case createevent:
        return _fadeRoute(const CreateEventScreen(), settings);
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  /// Shared smooth fade+slide transition for a premium feel across the app.
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

/// Typed navigation arguments for [AppRoutes.selectRole] onward, e.g. when a
/// user picks a role and we forward it to the corresponding registration
/// screen.
class RoleArguments {
  final Role role;
  const RoleArguments(this.role);
}
