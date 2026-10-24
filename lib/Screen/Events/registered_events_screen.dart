import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../BottomNav/animated_bottom_bar.dart';
import '../../Model/event_registration.dart';
import '../../Provider/events_provider.dart';
import '../../widgets/home_event_card.dart';
import 'registration_qr_screen.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  State<RegisteredEventsScreen> createState() =>
      _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadMyRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('My Registrations'),
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh registrations',
            onPressed: provider.loadMyRegistrations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.isLoading && provider.registrations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.registrations.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.confirmation_number_outlined,
                            size: 48, color: Colors.white54),
                        const SizedBox(height: 12),
                        Text(
                          provider.error ?? 'No event registrations yet',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: provider.loadMyRegistrations,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: provider.loadMyRegistrations,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: provider.registrations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => _RegistrationCard(
                      registration: provider.registrations[index],
                    ),
                  ),
                ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(8),
        child: AnimatedBottomBar(selectedIndex: 0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.registration});

  final EventRegistration registration;

  @override
  Widget build(BuildContext context) {
    final event = registration.event;
    return HomeEventCard(
      event: event,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationQrScreen(registration: registration),
        ),
      ),
    );
  }
}