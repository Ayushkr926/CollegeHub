import 'package:flutter/material.dart';

class CenterFAB extends StatefulWidget {
  final VoidCallback onTap;

  const CenterFAB({
    super.key,
    required this.onTap,
  });

  @override
  State<CenterFAB> createState() => _CenterFABState();
}

class _CenterFABState extends State<CenterFAB> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 9,
      shape: const CircleBorder(),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) {
          setState(() => pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: pressed ? .92 : 1,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.20),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffFFB6C1),
                    Color(0xffFF6A5C),
                    Color(0xffF44336),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(.45),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}