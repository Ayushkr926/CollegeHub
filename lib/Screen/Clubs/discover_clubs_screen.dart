import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BottomNav/animated_bottom_bar.dart';
import '../../Provider/club_provider.dart';
import '../../Model/club.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/club_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/featured_club_card.dart';
import 'club_detail_screen.dart';

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

class DiscoverClubsScreen extends StatefulWidget {
  const DiscoverClubsScreen({super.key});

  @override
  State<DiscoverClubsScreen> createState() => _DiscoverClubsScreenState();
}

class _DiscoverClubsScreenState extends State<DiscoverClubsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubProvider>().ensureLoaded();
    });
  }

  Future<void> _onRefresh() {
    return context.read<ClubProvider>().fetchClubs();
  }

  Future<void> _openClub(Club club) async {
    final detailedClub = await context.read<ClubProvider>().getClubById(club.id);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubDetailScreen(club: detailedClub ?? club),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final clubs = provider.filteredClubs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.white,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _TopBar()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: _SearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
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
              if (provider.featured != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: FeaturedClubCard(
                      club: provider.featured!,
                      onExplore: () {
                        if (provider.clubs.isNotEmpty) {
                          // open provider.clubs.first
                        }
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.selectedCategory == 'All'
                            ? 'All Clubs'
                            : provider.selectedCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (provider.selectedCategory != 'All')
                        TextButton(
                          onPressed: provider.clearFilters,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),

              // Loading
              if (provider.isLoading && !provider.hasLoadedOnce)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                )
              // Error
              else if (provider.errorMessage != null && clubs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: provider.fetchClubs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              // Empty
              else if (clubs.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyState(onExploreAll: provider.clearFilters),
                  )
                // List
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
                          onView: () => _openClub(club),
                          onJoin: () async {
                            await provider.joinClub(club.id);
                          },
                        );
                      },
                    ),
                  ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(8.0),
        child: AnimatedBottomBar(selectedIndex: 2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

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
            child: const Icon(
              Icons.leaderboard,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

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
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textFaint,
                  size: 22,
                ),
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
          child: const Icon(
            Icons.filter_list_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
        ),
      ],
    );
  }
}