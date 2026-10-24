import 'package:college/Model/event_enums.dart';
import 'package:college/Model/event_model.dart';
import 'package:college/Model/event_registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses populated event response into detail fields', () {
    final event = EventModel.fromJson({
      'event': {
        '_id': 'event-123',
        'title': 'Campus Hackathon',
        'description': 'A weekend build event',
        'category': 'Technical',
        'eventDate': '2026-11-10T00:00:00.000Z',
        'startTime': '09:30',
        'endTime': '18:00',
        'status': 'published',
        'coverImageUrl': 'https://example.com/cover.jpg',
        'tags': ['coding', 'students'],
        'views': 31,
        'location': {
          'mode': 'hybrid',
          'venue': 'Main Hall',
          'meetingLink': 'https://meet.example.com',
        },
        'contact': {
          'organizingClub': {'name': 'Tech Society'},
          'name': 'Alex',
          'email': 'alex@example.com',
          'phone': '1234567890',
          'socialLink': 'https://example.com/group',
        },
        'registration': {
          'deadline': '2026-11-08T00:00:00.000Z',
          'maxParticipants': 100,
          'type': 'paid',
          'ticketPrice': 25,
          'team': {'isTeamEvent': true, 'minSize': 2, 'maxSize': 4},
        },
        'eligibility': {'type': 'Specific Department', 'departments': ['CSE', 'IT']},
        'notes': 'Bring a laptop',
      },
    });

    expect(event.id, 'event-123');
    expect(event.title, 'Campus Hackathon');
    expect(event.mode, EventMode.hybrid);
    expect(event.type, EventType.paid);
    expect(event.startTime, const TimeOfDay(hour: 9, minute: 30));
    expect(event.organizingClub, 'Tech Society');
    expect(event.isTeamEvent, isTrue);
    expect(event.eligibilityDepartment, 'CSE, IT');
    expect(event.views, 31);
    expect(event.tags, ['coding', 'students']);
  });

  test('serializes the event create contract with nested fields', () {
    final event = EventModel(
      title: 'Campus Hackathon',
      description: 'Build something',
      category: 'Technical',
      eventDate: DateTime(2026, 11, 10),
      startTime: const TimeOfDay(hour: 9, minute: 30),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      mode: EventMode.online,
      meetingLink: 'https://meet.example.com',
      organizingClub: 'Tech Society',
      contactName: 'Alex',
      contactEmail: 'alex@example.com',
      contactPhone: '1234567890',
      maxParticipants: 100,
      type: EventType.paid,
      ticketPrice: 25,
      isTeamEvent: true,
      minTeamSize: 2,
      maxTeamSize: 4,
      eligibility: 'Specific Department',
      eligibilityDepartment: 'CSE, IT',
      coverImageUrl: 'https://example.com/cover.jpg',
    );

    final json = event.toApiJson();
    expect(json['title'], 'Campus Hackathon');
    expect(json['coverImageUrl'], 'https://example.com/cover.jpg');
    expect(json['location'], {
      'mode': 'online',
      'venue': '',
      'meetingLink': 'https://meet.example.com',
    });
    expect((json['registration'] as Map)['team'], {
      'isTeamEvent': true,
      'minSize': 2,
      'maxSize': 4,
    });
    expect((json['eligibility'] as Map)['departments'], ['CSE', 'IT']);
    expect(json['agreedToTerms'], isTrue);
  });

  test('registration ticket QR contains registration, event, and student IDs', () {
    final registration = EventRegistration.fromJson({
      '_id': 'registration-1',
      'status': 'confirmed',
      'registeredBy': {'_id': 'student-1', 'name': 'Student'},
      'event': {
        '_id': 'event-1',
        'title': 'Campus Fest',
        'eventDate': '2026-11-10T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '10:00',
        'registration': {'maxParticipants': 40, 'type': 'free'},
        'eligibility': {'type': 'all'},
        'contact': {},
        'location': {'mode': 'offline', 'venue': 'Hall'},
      },
    });

    expect(registration.id, 'registration-1');
    expect(registration.event.id, 'event-1');
    expect(registration.studentId, 'student-1');
    expect(registration.qrPayload, contains('registration-1'));
    expect(registration.qrPayload, contains('event-1'));
    expect(registration.qrPayload, contains('student-1'));
  });
}
