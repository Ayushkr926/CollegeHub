import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import 'package:flutter/material.dart';

import '../../BottomNav/animated_bottom_bar.dart';
import '../../Provider/club_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/club_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/featured_club_card.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF15151A);
  static const Color surfaceElevated = Color(0xFF1C1C22);
  static const Color border = Color(0xFF2A2A31);

  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9A9AA2);
  static const Color textFaint = Color(0xFF6C6C76);

  static const Color chipActiveBg = Colors.white;
  static const Color chipActiveFg = Colors.black;
  static const Color chipInactiveBg = Color(0xFF1C1C22);

  static const Color badgeBg = Color(0x40FFFFFF);

  static const Color joinButton = Colors.white;
}


class DiscoverClubsScreen extends StatelessWidget {
  const DiscoverClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final clubs = provider.filteredClubs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _TopBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Discover Clubs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Find communities that match your interests.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: _SearchBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      itemCount: provider.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        return CategoryChip(
                          label: category,
                          isActive: provider.selectedCategory == category,
                          onTap: () => provider.selectCategory(category),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: FeaturedClubCard(
                      club: provider.featured,
                      onExplore: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 28, 10, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Technical',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (clubs.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyState(onExploreAll: provider.clearFilters),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverList.separated(
                      itemCount: clubs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return ClubCard(
                          club: club,
                          onView: () {},
                          onJoin: () => provider.toggleJoin(club.id),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),

          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: const AnimatedBottomBar(selectedIndex: 2,),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElevated,
            child: Icon(Icons.person, color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'Campus Elite',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.leaderboard,
                color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<ClubProvider>();
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textFaint, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: provider.updateSearch,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search clubs...',
                      hintStyle: TextStyle(color: AppColors.textFaint),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.filter_list_rounded,
              color: AppColors.textMuted, size: 22),
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.calendar_today_rounded, 'Events'),
      (Icons.groups_rounded, 'Clubs'),
      (Icons.search_rounded, 'Search'),
      (Icons.person_rounded, 'Profile'),
    ];
    const activeIndex = 2;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final (icon, label) = items[index];
          final isActive = index == activeIndex;
          final color = isActive ? Colors.white : AppColors.textFaint;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
