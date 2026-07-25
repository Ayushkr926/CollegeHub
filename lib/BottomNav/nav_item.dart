import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: active ? 1.18 : 1,
                child: Icon(
                  icon,
                  size: 27,
                  color: active
                      ? const Color(0xff1A1A1A)
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? const Color(0xff1A1A1A)
                      : Colors.grey.shade500,
                ),
                child: Text(title),
              )
            ],
          ),
        ),
      ),
    );
  }
}