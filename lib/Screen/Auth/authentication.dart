/// Barrel file for the authentication module.
/// Import this single file from the rest of the app to access every
/// screen, widget, model and util exposed by the auth module.
library authentication;

// Utils
export '../../utils/app_colors.dart';
export '../../utils/app_text_styles.dart';
export '../../utils/app_spacing.dart';
export '../../utils/app_theme.dart';
export '../../utils/app_constants.dart';
export '../../utils/app_routes.dart';
export '../../utils/validators.dart';

// Models
export '../../Model/user_role.dart';

// Widgets
export 'widgets/primary_button.dart';
export 'widgets/custom_outlined_button.dart';
export 'widgets/loading_button.dart';
export 'widgets/custom_text_field.dart';
export 'widgets/password_field.dart';
export 'widgets/role_card.dart';
export 'widgets/app_header.dart';
export 'widgets/section_title.dart';
export 'widgets/animated_logo.dart';
export 'widgets/app_bottom_nav_bar.dart';
export 'widgets/custom_checkbox.dart';
export 'widgets/empty_state.dart';
export 'widgets/premium_dialog.dart';
export 'widgets/premium_bottom_sheet.dart';
export 'widgets/social_login_button.dart';
export 'widgets/page_indicator.dart';

// Screens
export '../../onboarding/onboarding_screen.dart';
export 'welcome_screen.dart';
export 'login_screen.dart';
export 'select_role_screen.dart';
export 'student_registration_screen.dart';
export 'club_registration_screen.dart';
export 'forgot_password_screen.dart';
export 'email_verification_screen.dart';
export 'registration_success_screen.dart';
