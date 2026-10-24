import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/events_provider.dart';
import '../../Provider/profile_provider_student.dart';
import '../../storage/local_storage.dart';
import '../../utils/app_routes.dart';
import '../../widgets/home_event_card.dart';
import 'eventdetail.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const _background = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);
  static const _accent = Color(0xFFE8395C);
  static const _muted = Color(0xFF9A9A9A);
  bool _isOrganiser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForCurrentRole();
    });
    _scrollController.addListener(_loadMoreWhenNearEnd);
  }

  Future<void> _loadForCurrentRole() async {
    final role = await LocalStorageService.instance.getString('role');
    if (!mounted) return;
    _isOrganiser = role == 'organiser' || role == 'admin';
    if (_isOrganiser) {
      final profile = context.read<ProfileProvider>();
      if (profile.id.isEmpty) await profile.loadProfile(isorganiser: true);
      if (!mounted) return;
      if (profile.id.isNotEmpty) {
        await context.read<EventsProvider>().loadOrganizerEvents(profile.id);
      } else {
        await context.read<EventsProvider>().loadEvents(refresh: true);
      }
    } else {
      await context.read<EventsProvider>().loadEvents(refresh: true);
    }
    if (mounted) setState(() {});
  }

  Future<void> _refresh(EventsProvider provider) async {
    if (_isOrganiser) {
      final profile = context.read<ProfileProvider>();
      await provider.loadOrganizerEvents(profile.id);
    } else {
      await provider.loadEvents(refresh: true);
    }
  }

  void _loadMoreWhenNearEnd() {
    if (_scrollController.position.extentAfter < 400) {
      context.read<EventsProvider>().loadEvents();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: Text(_isOrganiser ? 'Manage Events' : 'Events'),
        actions: [
          if (!_isOrganiser)
            IconButton(
            tooltip: 'My registrations',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.registeredEvents,
            ),
            icon: const Icon(Icons.confirmation_number_outlined),
            ),
          IconButton(
            tooltip: 'Refresh events',
              onPressed: () => _refresh(provider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: provider.search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search events',
                hintStyle: const TextStyle(color: _muted),
                prefixIcon: const Icon(Icons.search, color: _muted),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: () => provider.search(_searchController.text),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip(provider, null, 'All'),
                _categoryChip(provider, 'Academic', 'Academic'),
                _categoryChip(provider, 'Technical', 'Technical'),
                _categoryChip(provider, 'Cultural', 'Cultural'),
                _categoryChip(provider, 'Sports', 'Sports'),
                _categoryChip(provider, 'Career', 'Career'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(provider),
              color: _accent,
              child: provider.events.isEmpty && provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _accent))
                  : provider.events.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Icon(Icons.event_busy_outlined, color: Colors.white54, size: 42),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                provider.error ?? 'No events found',
                                style: const TextStyle(color: _muted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _refresh(provider),
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: provider.events.length + (provider.isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == provider.events.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(color: _accent),
                                ),
                              );
                            }
                            final event = provider.events[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                HomeEventCard(
                                  event: event,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(event: event),
                                    ),
                                  ),
                                ),
                                if (_isOrganiser)
                                  PopupMenuButton<String>(
                                    tooltip: 'Manage event status',
                                    onSelected: (status) async {
                                      final success = await provider.updateStatus(event.id, status);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(success ? 'Event marked $status' : 'Could not update event')),
                                      );
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'live', child: Text('Publish / Live')),
                                      PopupMenuItem(value: 'completed', child: Text('Mark completed')),
                                      PopupMenuItem(value: 'cancelled', child: Text('Cancel event')),
                                    ],
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.more_horiz, color: Colors.white70),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isOrganiser
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createevent),
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Create event'),
            )
          : null,
    );
  }

  Widget _categoryChip(EventsProvider provider, String? value, String label) {
    final selected = provider.category == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: () => provider.filterByCategory(value),
        backgroundColor: selected ? _accent : _surface,
        labelStyle: const TextStyle(color: Colors.white),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}