import 'package:flutter/material.dart';

/// Design tokens for the "Ohana" notice board theme.
///
/// The palette is drawn from Stitch's own coloring rather than a generic
/// "brand blue": his fur (deep royal blue), his belly/ear undersides
/// (dusty lavender-pink), and his nose (near-black navy). This keeps the
/// character feel woven into the *system*, not just pasted on as images.
class StitchColors {
  StitchColors._();

  // Core fur blues — used for primary actions, headers, active states.
  static const Color furDeep = Color(0xFF1B4EAE); // Stitch's darker fur shadow
  static const Color furCore = Color(0xFF2F6FE0); // primary brand blue
  static const Color furLight = Color(0xFF6C9CF2); // hover/lighter fills

  // Ear/belly lavender-pink — the *signature* secondary accent.
  // This is the one deliberate risk: most "themed" UIs would stop at blue.
  static const Color earPink = Color(0xFFC9A6D8);
  static const Color earPinkDeep = Color(0xFF9C6FB0);

  // Nose navy — near-black, used for primary text and high-contrast ink.
  static const Color noseInk = Color(0xFF14213D);

  // Neutrals — warm-white background, not stark #FFFFFF, so the blues
  // and pinks don't look clinical against it.
  static const Color canvas = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSunken = Color(0xFFEFF2FA);
  static const Color hairline = Color(0xFFE2E6F0);
  static const Color textMuted = Color(0xFF6B7290);
  static const Color textFaint = Color(0xFF9AA0BC);

  // Semantic
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE0A02E);
  static const Color danger = Color(0xFFE0524A); // matches the "red card" motif
  static const Color dangerSoft = Color(0xFFFBEAE9);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [furDeep, furCore, Color(0xFF3B5FCC)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient pinkAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [earPink, earPinkDeep],
  );
}

class StitchSpacing {
  StitchSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;
}

class StitchRadius {
  StitchRadius._();
  // "Pod" radii — soft, alien-pod rounded, larger than typical Material
  // defaults, echoing Stitch's rounded ears/head silhouette.
  static const double pill = 999;
  static const double pod = 24;
  static const double podSm = 16;
  static const double podXs = 10;
}

class StitchShadow {
  StitchShadow._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: StitchColors.noseInk.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> hero = [
    BoxShadow(
      color: StitchColors.furDeep.withOpacity(0.28),
      blurRadius: 28,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> floating = [
    BoxShadow(
      color: StitchColors.furDeep.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
}

/// Local asset paths for the Stitch character set. Drop the seven supplied
/// images into these paths (any format is fine — jpg/png both work; update
/// the extension below to match what you actually place there).
class StitchAssets {
  StitchAssets._();

  /// Fist-pump / celebrating Stitch — used for success & empty-positive states.
  static const String happy = 'assets/images/Stitch/happy.png';

  /// Peeking through torn paper — used as the loading motif.
  static const String peek = 'assets/images/Stitch/hey1.png';

  /// Sad "Sorry..." Stitch with Scrump — used for error states.
  static const String sorry = 'assets/images/Stitch/error.png';

  /// Upside-down curious Stitch — used for the pull-to-refresh spinner glyph.
  static const String upsideDown = 'assets/images/Stitch/loader.png';

  /// Red-card Stitch — used for "clear filters" / destructive-adjacent actions.
  static const String redCard = 'assets/images/Stitch/revoke.png';
}