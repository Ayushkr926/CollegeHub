import 'dart:async';

import 'package:flutter/material.dart';

import '../Api/app_api_service.dart';
import '../Model/event_registration.dart';
import '../Model/event_model.dart';

class EventsProvider extends ChangeNotifier {
  EventsProvider({AppApiService? apiService})
      : _apiService = apiService ?? AppApiService();

  final AppApiService _apiService;
  final List<EventModel> _events = [];
  final List<EventRegistration> _registrations = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  String _search = '';
  String? _category;
  String? _organizerId;
  int _page = 1;

  List<EventModel> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get category => _category;
  List<EventRegistration> get registrations =>
      List.unmodifiable(_registrations);

    bool isRegisteredFor(String eventId) =>
      _registrations.any((registration) => registration.event.id == eventId);

  Future<void> loadEvents({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final payload = await _apiService.listEvents(
        search: _search,
        category: _category,
        organizingClubRef: _organizerId,
        page: _page,
        limit: 20,
      );
      final rawEvents = _eventList(payload);
      final pageEvents = rawEvents.map(EventModel.fromJson).toList();
      if (refresh || _page == 1) {
        _events
          ..clear()
          ..addAll(pageEvents);
      } else {
        _events.addAll(pageEvents);
      }
      _hasMore = pageEvents.length == 20;
      if (_hasMore) _page++;
    } on Exception catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrganizerEvents(String organizerId) async {
    _organizerId = organizerId;
    _search = '';
    _category = null;
    _page = 1;
    _hasMore = false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final payload = await _apiService.listEvents(
        search: _search,
        category: _category,
        organizingClubRef: organizerId,
        page: 1,
        limit: 100,
      );
      _events
        ..clear()
        ..addAll(_eventList(payload).map(EventModel.fromJson));
    } on Exception catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      final response = await _apiService.updateEventStatus(id, status: status);
      final raw = response['event'] ?? response['data'] ?? response;
      if (raw is Map) {
        final updated = EventModel.fromJson(Map<String, dynamic>.from(raw));
        final index = _events.indexWhere((event) => event.id == updated.id);
        if (index != -1) _events[index] = updated;
      }
      notifyListeners();
      return true;
    } on Exception catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _page = 1;
    _hasMore = true;
    await loadEvents(refresh: true);
  }

  Future<void> filterByCategory(String? value) async {
    _category = value;
    _page = 1;
    _hasMore = true;
    await loadEvents(refresh: true);
  }

  Future<EventModel?> getEventById(String id) async {
    try {
      final payload = await _apiService.getEvent(id);
      final event = EventModel.fromJson(payload);
      final index = _events.indexWhere((item) => item.id == event.id);
      if (index >= 0) {
        _events[index] = event;
      }
      notifyListeners();
      return event;
    } on Exception catch (error) {
      _error = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> register(String id, {String? teamName, List<String>? members}) async {
    await _apiService.registerForEvent(id, teamName: teamName, members: members);
  }

  Future<void> attend(String id) async {
    await _apiService.attendEvent(id);
  }

  Future<void> loadMyRegistrations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final payload = await _apiService.getMyEventRegistrations();
      final raw = payload['data'] ?? payload['registrations'] ?? payload;
      final rows = raw is List
          ? raw.whereType<Map>().map((row) => Map<String, dynamic>.from(row))
          : const <Map<String, dynamic>>[];
      _registrations
        ..clear()
        ..addAll(rows.map(EventRegistration.fromJson));
    } on Exception catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _eventList(Map<String, dynamic> payload) {
    dynamic raw = payload['events'] ?? payload['results'] ?? payload['items'] ?? payload['data'] ?? payload;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      raw = map['events'] ?? map['results'] ?? map['items'] ?? map['data'] ?? map;
    }
    if (raw is List) {
      return raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return const [];
  }
}