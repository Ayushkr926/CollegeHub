import 'package:college/storage/local_storage.dart';
import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import 'bottom_bar_painter.dart';
import 'center_fab.dart';
import 'nav_item.dart';

class AnimatedBottomBar extends StatefulWidget {
  final int selectedIndex;
  final String? role;

  const AnimatedBottomBar({
    super.key,
    this.selectedIndex = 0,
    this.role,
  });

  @override
  State<AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> {
  late int selected;
  String? role;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedIndex;
    checkRole();
  }

  Future<void> checkRole() async {
    final storedRole =
    await LocalStorageService.instance.getString("role");

    if (!mounted) return;

    setState(() {
      role = storedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("role is ${role}");
    return SizedBox(
      height: 95,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: 18,
            child: CustomPaint(
              painter: BottomBarPainter(),
            ),
          ),

          Positioned(
            left: 22,
            right: 22,
            top: 26,
            bottom: 8,
            child: Row(
              children: [
                Expanded(
                  child: NavItem(
                    icon: Icons.search_rounded,
                    title: "Discover",
                    active: selected == 0,
                    onTap: () {
                      setState(() => selected = 0);
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.home);
                    },
                  ),
                ),

                Expanded(
                  child: NavItem(
                    icon: Icons.mail_outline_rounded,
                    title: role == 'organiser' ? 'Requests' : 'Tickets',
                    active: selected == 1,
                    onTap: () {
                      setState(() => selected = 1);
                      Navigator.pushReplacementNamed(
                        context,
                        role == 'organiser'
                          ? AppRoutes.request
                          : AppRoutes.registeredEvents,
                        );
                    },
                  ),
                ),

                const SizedBox(width: 78),

                Expanded(
                  child: NavItem(
                    icon: Icons.people,
                    title: "Clubs",
                    active: selected == 2,
                    onTap: () {
                      setState(() => selected = 2);
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.clubs);
                    },
                  ),
                ),

                Expanded(
                  child: NavItem(
                    icon: Icons.person_outline,
                    title: "Profile",
                    active: selected == 3,
                    onTap: () {
                      setState(() => selected = 3);

                      Navigator.pushReplacementNamed(
                        context,
                        role == "organiser"
                            ? AppRoutes.clubprofile
                            : AppRoutes.stuprofile,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: CenterFAB(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  role == 'organiser' || role == 'admin'
                      ? AppRoutes.createevent
                      : AppRoutes.events,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}