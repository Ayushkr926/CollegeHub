import 'package:college/Model/event_enums.dart';
import 'package:college/Model/event_model.dart';
import 'package:college/Model/user_role.dart';
import 'package:college/utils/app_constants.dart';
import 'package:college/Notices/create_notice/model/notice_create_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes existing course, branch, and year aliases', () {
    expect(AppConstants.normalizeCourse('b tech'), 'B.Tech');
    expect(AppConstants.normalizeCourse('Master of Business Administration'), 'MBA');
    expect(AppConstants.normalizeBranch('Computer Science'), 'CSE');
    expect(AppConstants.normalizeBranch('Electronics & Communication'), 'ECE');
    expect(AppConstants.normalizeYear('3rd Year'), 3);
    expect(AppConstants.yearLabel(4), '4th Year');
    expect(AppConstants.normalizeYears(['All Years']), [1, 2, 3, 4, 5]);
  });

  test('normalizes profile academic values from legacy records', () {
    final student = Student.fromJson({
      '_id': 'student-1',
      'name': 'Student',
      'email': 'student@example.com',
      'branch': 'Computer Science',
      'course': 'b tech',
      'year': '2nd Year',
    });

    expect(student.branch, 'CSE');
    expect(student.course, 'B.Tech');
    expect(student.year, 2);
  });

  test('notice audiences serialize canonical branch and numeric years', () {
    final payload = NoticeFormData(
      targetDepartments: ['Computer Science', 'Electronics & Communication'],
      targetProgrammes: ['b tech'],
      targetYears: ['1st Year', '3rd Year'],
    ).toBackendPayload();

    expect(payload['targetDepartments'], ['CSE', 'ECE']);
    expect(payload['targetProgrammes'], ['B.Tech']);
    expect(payload['targetYears'], [1, 3]);
  });

  test('event eligibility serializes as backend enum and canonical arrays', () {
    final event = EventModel(
      title: 'Workshop',
      description: 'Details',
      category: 'Academic',
      eventDate: DateTime(2026, 11, 10),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      mode: EventMode.offline,
      venue: 'Hall',
      organizingClub: 'Tech Club',
      contactName: 'Host',
      contactEmail: 'host@example.com',
      contactPhone: '1234567890',
      maxParticipants: 40,
      type: EventType.free,
      eligibility: 'Specific Department',
      eligibilityDepartment: 'Computer Science, Electronics & Communication',
    );

    final payload = event.toApiJson();
    final eligibility = payload['eligibility'] as Map<String, dynamic>;
    expect(eligibility['type'], 'specificDepartment');
    expect(eligibility['departments'], ['CSE', 'ECE']);
    expect(eligibility['years'], isEmpty);
  });

  test('event year eligibility serializes the shared numeric year value', () {
    final event = EventModel(
      title: 'Workshop',
      description: 'Details',
      category: 'Academic',
      eventDate: DateTime(2026, 11, 10),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      mode: EventMode.offline,
      venue: 'Hall',
      organizingClub: 'Tech Club',
      contactName: 'Host',
      contactEmail: 'host@example.com',
      contactPhone: '1234567890',
      maxParticipants: 40,
      type: EventType.free,
      eligibility: '3rd Year Only',
    );

    final payload = event.toApiJson();
    final eligibility = payload['eligibility'] as Map<String, dynamic>;
    expect(eligibility['type'], 'specificYear');
    expect(eligibility['years'], [3]);
  });
}
