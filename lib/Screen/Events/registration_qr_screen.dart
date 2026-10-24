import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Model/event_registration.dart';

class RegistrationQrScreen extends StatelessWidget {
  const RegistrationQrScreen({super.key, required this.registration});

  final EventRegistration registration;

  @override
  Widget build(BuildContext context) {
    final event = registration.event;
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Event Ticket'),
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year} · ${event.startTime.format(context)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: QrImageView(
                    data: registration.qrPayload,
                    version: QrVersions.auto,
                    size: 260,
                    backgroundColor: Colors.white,
                    semanticsLabel: 'Registration QR for ${event.title}',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Show this QR code at event check-in',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'Registration ID: ${registration.id}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${registration.status}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}