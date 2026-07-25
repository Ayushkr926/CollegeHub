import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Centralized spring physics configurations for the onboarding experience.
///
/// Using named spring descriptions keeps motion consistent across the whole
/// interaction (drag, snap-back, and fullscreen expansion) and makes it easy
/// to tune "feel" from a single place.
class AppSprings {
  AppSprings._();

  /// Used when the drag doesn't pass the activation threshold.
  /// Slightly bouncy — communicates "not yet" without feeling harsh.
  static const SpringDescription snapBack = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 20,
  );

  /// Used when the drag passes the activation threshold and the sheet
  /// commits to expanding fullscreen. Stiffer & less bouncy so the motion
  /// reads as "confident" rather than "wobbly".
  static const SpringDescription expand = SpringDescription(
    mass: 1,
    stiffness: 220,
    damping: 26,
  );

  /// Builds a [SpringSimulation] that animates [controller]'s value from its
  /// current position to [target] using [description], optionally seeded
  /// with the finger's release velocity for a natural hand-off.
  static SpringSimulation build({
    required AnimationController controller,
    required SpringDescription description,
    required double target,
    double velocity = 0,
  }) {
    return SpringSimulation(
      description,
      controller.value,
      target,
      velocity,
    );
  }
}
