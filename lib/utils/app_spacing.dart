/// Centralized spacing, radius and sizing constants.
/// Using a fixed scale keeps the layout rhythm consistent across screens.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Screen padding
  static const double screenHorizontal = 24;
  static const double screenVertical = 24;
}

/// Corner radii used across cards, buttons and inputs.
class AppRadius {
  AppRadius._();

  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xLarge = 24;
  static const double xxLarge = 28;
  static const double pill = 100;
}

/// Standard animation durations/curves used throughout the module.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration splash = Duration(milliseconds: 1400);
}
