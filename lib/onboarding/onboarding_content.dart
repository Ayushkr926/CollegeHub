import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final double progress;
  final int currentPage;
  final int totalPages;
  final String title;
  final String subtitle;

  const OnboardingContent({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final fade = (1 - progress * 1.4).clamp(0.0, 1.0);
    final dy = progress * 24;

    return Opacity(
      opacity: fade,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 36),

            /// Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: -0.5,
                color: Color(0xFF161616),
              ),
            ),

            const SizedBox(height: 16),

            /// Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _PageIndicators(
              fade: fade,
              currentPage: currentPage,
              totalPages: totalPages,
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  final double fade;
  final int currentPage;
  final int totalPages;

  const _PageIndicators({
    required this.fade,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final active = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? Colors.black.withOpacity(fade)
                : Colors.grey.shade300.withOpacity(fade),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}