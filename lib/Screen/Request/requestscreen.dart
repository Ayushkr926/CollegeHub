import 'package:college/Screen/Request/widget/requestcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BottomNav/animated_bottom_bar.dart';
import '../../Model/request.dart';
import '../../Provider/Requestprovider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';

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

class Requestscreen extends StatefulWidget {
  const Requestscreen({super.key});

  @override
  State<Requestscreen> createState() => _RequestscreenState();
}

class _RequestscreenState extends State<Requestscreen> {
  void _handleAccept(Requestprovider provider, Request request) {
    provider.acceptRequest(request.id);
    _showUndoSnackbar(
      message: '${request.name} accepted',
      onUndo: () => provider.undoAction(request.id),
    );
  }

  void _handleDecline(Requestprovider provider, Request request) {
    provider.declineRequest(request.id);
    _showUndoSnackbar(
      message: '${request.name} declined',
      onUndo: () => provider.undoAction(request.id),
    );
  }

  void _showUndoSnackbar({
    required String message,
    required VoidCallback onUndo,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: onUndo,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Requestprovider>();
    final requestlist = provider.filteredClubs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _TopBar(pendingCount: provider.pendingCount),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 10,
                  ),
                  child: const Text(
                    'Manage students requesting to join your club',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 18),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _SearchBar()),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
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
              if (requestlist.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(onExploreAll: provider.clearFilters),
                )
              else
                SliverList.separated(
                  itemCount: requestlist.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final request = requestlist[index];
                    return Requestcard(
                      key: ValueKey(request.id),
                      request: request,
                      onAccept: () => _handleAccept(provider, request),
                      onDecline: () => _handleDecline(provider, request),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 124)),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: const AnimatedBottomBar(selectedIndex: 1,),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TopBar extends StatelessWidget {
  final int pendingCount;

  const _TopBar({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).maybePop(),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElevated,
            child: Icon(Icons.arrow_back, color: AppColors.textMuted, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Join Request',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pendingCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<Requestprovider>();
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
                      hintText: 'Search by name or major..',
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
      ],
    );
  }
}