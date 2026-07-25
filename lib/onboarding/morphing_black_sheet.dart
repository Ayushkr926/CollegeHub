import 'package:flutter/material.dart';

import '../painter/curved_sheet_painter.dart';
import 'draggable_start_button.dart';

/// The liquid black shape that starts as a small rounded bar behind the
/// start button and stretches upward — corner radius softening to zero —
/// until it fills the entire screen.
class MorphingBlackSheet extends StatelessWidget {
  /// 0..1 drag/expansion progress.
  final double progress;

  /// The y-position of the sheet's top edge at rest (progress == 0).
  final double collapsedTop;

  final double buttonBottomInset;

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;

  const MorphingBlackSheet({
    super.key,
    required this.progress,
    required this.collapsedTop,
    required this.buttonBottomInset,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Geometry driving the CustomPainter below — all pure functions of
    // progress, so the whole shape stays perfectly in sync with the drag.
    final currentTop = collapsedTop * (1 - progress); // -> 0 at full expand
    final cornerRadius = 194.0 * (1 - progress);

    // Parabola: 0 at progress 0 and 1, peaks (~26px) around the midpoint.
    // This is what gives the sheet its "liquid" life while being dragged.
    final bulge = progress * (1 - progress) * 4 * 72;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: CurvedSheetPainter(
              topY: currentTop,
              cornerRadius: cornerRadius,
              liquidBulge: bulge,
              color: Colors.black
              ,
            ),
          ),
        ),
        // Hide the button once the sheet has essentially taken over the
        // screen — its label has already faded out by this point too.
        if (progress < 1.9)
          Positioned(
            left: 0,
            right: 0,
            bottom: buttonBottomInset,
            child: Center(
              child: DraggableStartButton(
                progress: progress,
                onDragStart: onDragStart,
                onDragUpdate: onDragUpdate,
                onDragEnd: onDragEnd,
              ),
            ),
          ),
      ],
    );
  }
}
