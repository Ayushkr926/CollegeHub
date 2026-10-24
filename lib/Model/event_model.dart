import 'dart:io';

import 'package:flutter/material.dart';

import 'event_enums.dart';
import '../utils/app_constants.dart';

/// Plain data holder representing a fully created event.
/// Built from CreateEventProvider's fields once the form is validated,
/// and consumed by EventDetailScreen for display. Kept independent of
/// the provider (no import of it) to avoid a circular dependency and
/// so the detail screen can also be fed mock/sample data directly.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final File? coverImage;

  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime? registrationDeadline;

  final EventMode mode;
  final String venue;
  final String meetingLink;

  final String organizingClub;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String socialLink;

  final int maxParticipants;
  final EventType type;
  final double? ticketPrice;

  final bool isTeamEvent;
  final int? minTeamSize;
  final int? maxTeamSize;

  final String eligibility;
  final String? eligibilityDepartment;
  final List<int> eligibilityYears;

  final String? impnotice;
  final String coverImageUrl;
  final String status;
  final List<String> tags;
  final int views;
  final int participantsCount;

  const EventModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.category,
    this.coverImage,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.registrationDeadline,
    required this.mode,
    this.venue = '',
    this.meetingLink = '',
    required this.organizingClub,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    this.socialLink = '',
    required this.maxParticipants,
    required this.type,
    this.ticketPrice,
    this.isTeamEvent = false,
    this.minTeamSize,
    this.maxTeamSize,
    required this.eligibility,
    this.eligibilityDepartment,
    this.eligibilityYears = const [],
    this.impnotice,
    this.coverImageUrl = '',
    this.status = '',
    this.tags = const [],
    this.views = 0,
    this.participantsCount = 0,
  });

  bool get isFree => type == EventType.free;

  Map<String, dynamic> toApiJson() => {
        'title': title,
        'description': description,
        'category': category,
        if (coverImageUrl.isNotEmpty) 'coverImageUrl': coverImageUrl,
        'eventDate': eventDate.toIso8601String(),
        'startTime': _formatTime(startTime),
        'endTime': _formatTime(endTime),
        'location': {
          'mode': mode.name,
          'venue': venue,
          'meetingLink': meetingLink,
        },
        'contact': {
          'organizingClub': organizingClub,
          'name': contactName,
          'email': contactEmail,
          'phone': contactPhone,
          'socialLink': socialLink,
        },
        'registration': {
          if (registrationDeadline != null)
            'deadline': registrationDeadline!.toIso8601String(),
          'maxParticipants': maxParticipants,
          'type': type.name,
          if (ticketPrice != null) 'ticketPrice': ticketPrice,
          'team': {
            'isTeamEvent': isTeamEvent,
            if (minTeamSize != null) 'minSize': minTeamSize,
            if (maxTeamSize != null) 'maxSize': maxTeamSize,
          },
        },
        'eligibility': {
          'type': _eligibilityApiType(eligibility),
          'departments': AppConstants.normalizeBranches(
            eligibilityDepartment?.split(',') ?? const <String>[],
          ),
          'years': _eligibilityApiType(eligibility) == 'specificYear'
              ? AppConstants.normalizeYears(
                  eligibilityYears.isNotEmpty
                      ? eligibilityYears
                      : [eligibility],
                )
              : <int>[],
        },
        'agreedToTerms': true,
      };

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String _eligibilityApiType(String value) {
    if (value == 'Specific Department') return 'specificDepartment';
    if (value.endsWith('Year Only')) return 'specificYear';
    return 'all';
  }

  String get modeLabel {
    switch (mode) {
      case EventMode.offline:
        return 'Offline';
      case EventMode.online:
        return 'Online';
      case EventMode.hybrid:
        return 'Hybrid';
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> source) {
    var json = source;
    for (final key in ['event', 'data']) {
      final nested = json[key];
      if (nested is Map) {
        json = Map<String, dynamic>.from(nested);
      }
    }

    final location = _asMap(json['location']);
    final contact = _asMap(json['contact']);
    final registration = _asMap(json['registration']);
    final team = _asMap(registration['team']);
    final eligibility = _asMap(json['eligibility']);
    final eventDate = _parseDate(json['eventDate'] ?? json['date']) ?? DateTime.now();
    final startTime = _parseTime(json['startTime'] ?? json['time'] ?? '09:00');
    final endTime = _parseTime(json['endTime'] ?? '10:00');
    final mode = _parseMode(location['mode'] ?? json['mode']);
    final type = _parseType(registration['type'] ?? json['eventType'] ?? json['type']);
    final organizer = contact['organizingClub'] ?? json['organizingClub'] ?? json['organizer'];
    final organizerName = organizer is Map
        ? organizer['name'] ?? organizer['clubName'] ?? organizer['_id']
        : organizer;
    final departmentValues = eligibility['departments'];
    final departments = departmentValues is List
      ? AppConstants.normalizeBranches(departmentValues).join(', ')
      : AppConstants.normalizeBranches([departmentValues]).join(', ');
    final eligibleYears = AppConstants.normalizeYears(
      eligibility['years'] is List ? eligibility['years'] as List : const [],
    );
    final eligibilityType = eligibility['type']?.toString();
    final eligibilityLabel = eligibilityType == 'specificDepartment'
      ? 'Specific Department'
      : eligibilityType == 'specificYear'
        ? eligibleYears.isEmpty
          ? 'Specific Year'
          : '${eligibleYears.map(AppConstants.yearLabel).join(', ')}${eligibleYears.length == 1 ? ' Only' : ''}'
        : 'Open to All';
    final teamEnabled = team['isTeamEvent'] == true;
    final ticketPrice = _asDouble(registration['ticketPrice'] ?? json['ticketPrice']);

    return EventModel(
      id: (json['_id'] ?? json['id'] ?? json['slug'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      registrationDeadline: _parseDate(registration['deadline'] ?? json['registrationDeadline']),
      mode: mode,
      venue: (location['venue'] ?? '').toString(),
      meetingLink: (location['meetingLink'] ?? '').toString(),
      organizingClub: (organizerName ?? '').toString(),
      contactName: (contact['name'] ?? '').toString(),
      contactEmail: (contact['email'] ?? '').toString(),
      contactPhone: (contact['phone'] ?? '').toString(),
      socialLink: (contact['socialLink'] ?? '').toString(),
      maxParticipants: _asInt(registration['maxParticipants'] ?? json['maxParticipants']),
      type: type,
      ticketPrice: ticketPrice,
      isTeamEvent: teamEnabled,
      minTeamSize: _asNullableInt(team['minSize']),
      maxTeamSize: _asNullableInt(team['maxSize']),
      eligibility: eligibilityLabel,
      eligibilityDepartment: departments,
      eligibilityYears: eligibleYears,
      impnotice: json['notes']?.toString(),
      coverImageUrl: (json['coverImageUrl'] ?? json['coverImage'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      tags: json['tags'] is List ? (json['tags'] as List).map((value) => value.toString()).toList() : const [],
      views: _asInt(json['views'] ?? json['viewCount']),
      participantsCount: _asInt(
        json['participantsCount'] ?? json['numberOfRegistration'],
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    return value == null ? null : DateTime.tryParse(value.toString());
  }

  static TimeOfDay _parseTime(dynamic value) {
    if (value is TimeOfDay) return value;
    final parts = (value ?? '').toString().split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return TimeOfDay(hour: hour ?? 9, minute: minute ?? 0);
  }

  static EventMode _parseMode(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'online':
        return EventMode.online;
      case 'hybrid':
        return EventMode.hybrid;
      default:
        return EventMode.offline;
    }
  }

  static EventType _parseType(dynamic value) =>
      value?.toString().toLowerCase() == 'paid' ? EventType.paid : EventType.free;

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) =>
      value == null ? null : _asInt(value);

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}