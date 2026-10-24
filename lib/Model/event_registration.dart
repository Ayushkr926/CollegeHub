import 'dart:convert';

import 'event_model.dart';

class EventRegistration {
  const EventRegistration({
    required this.id,
    required this.event,
    required this.studentId,
    required this.status,
    required this.registeredAt,
  });

  final String id;
  final EventModel event;
  final String studentId;
  final String status;
  final DateTime? registeredAt;

  String get qrPayload => jsonEncode({
        'registrationId': id,
        'eventId': event.id,
        'studentId': studentId,
      });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    final rawEvent = json['event'];
    final eventJson = rawEvent is Map
        ? Map<String, dynamic>.from(rawEvent)
        : <String, dynamic>{};
    final rawStudent = json['registeredBy'];
    final studentId = rawStudent is Map
        ? (rawStudent['_id'] ?? rawStudent['id'] ?? '').toString()
        : (rawStudent ?? '').toString();

    return EventRegistration(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      event: EventModel.fromJson(eventJson),
      studentId: studentId,
      status: (json['status'] ?? 'confirmed').toString(),
      registeredAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}