import 'dart:io';

import 'package:flutter/material.dart';

import 'event_enums.dart';

/// Plain data holder representing a fully created event.
/// Built from CreateEventProvider's fields once the form is validated,
/// and consumed by EventDetailScreen for display. Kept independent of
/// the provider (no import of it) to avoid a circular dependency and
/// so the detail screen can also be fed mock/sample data directly.
class EventModel {
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

  final String? impnotice;

  const EventModel({
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
    this.impnotice,
  });

  bool get isFree => type == EventType.free;

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
}