import 'package:college/Screen/Auth/authentication.dart';
import 'package:flutter/material.dart';

import 'bottom_bar_painter.dart';
import 'center_fab.dart';
import 'nav_item.dart';

class AnimatedBottomBar extends StatefulWidget {
  final int selectedIndex;
  const AnimatedBottomBar({super.key, this.selectedIndex=0});

  @override
  State<AnimatedBottomBar> createState() =>
      _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> {
  late int selected = widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
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
                      setState(() {
                        selected = 0;
                      });
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                  ),
                ),

                Expanded(
                  child: NavItem(
                    icon: Icons.mail_outline_rounded,
                    title: "Request",
                    active: selected == 1,
                    onTap: () {
                      setState(() {
                        selected = 1;
                      });
                      Navigator.pushNamed(context, AppRoutes.request);
                    },
                  ),
                ),

                const SizedBox(width: 78),

                Expanded(
                  child: NavItem(
                    icon: Icons.people_sharp,
                    title: "Clubs",
                    active: selected == 2,
                    onTap: () {
                      setState(() {
                        selected = 2;
                      });
                      Navigator.pushNamed(context, AppRoutes.clubs);
                    },
                  ),
                ),

                Expanded(
                  child: NavItem(
                    icon: Icons.person_outline,
                    title: "Profile",
                    active: selected == 3,
                    onTap: () {
                      setState(() {
                        selected = 3;
                      });
                      Navigator.pushNamed(context, AppRoutes.stuprofile);
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
                Navigator.pushNamed(context, AppRoutes.createevent);
              },
            ),
          ),
        ],
      ),
    );
  }
}