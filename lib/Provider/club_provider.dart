import 'dart:async';
import 'package:flutter/material.dart';

import '../Api/app_api_service.dart';
import '../Model/club.dart';

class ClubProvider extends ChangeNotifier {
  final AppApiService _apiService = AppApiService();

  ClubProvider();

  final List<String> categories = const [
    'All',
    'Technical',
    'Cultural',
    'Sports',
    'Literary',
    'Social',
    'Management',
    'Other',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  bool _isCreatingClub = false;
  bool _isLoadingRequests = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  Club? _selectedClub;
  List<Map<String, dynamic>> _joinRequests = [];

  List<Club> _clubs = [];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get isCreatingClub => _isCreatingClub;
  bool get isLoadingRequests => _isLoadingRequests;
  String? get errorMessage => _errorMessage;
  Club? get selectedClub => _selectedClub;
  List<Map<String, dynamic>> get joinRequests =>
      List.unmodifiable(_joinRequests);
  List<Club> get clubs => List.unmodifiable(_clubs);
  List<Club> get filteredClubs => clubs;

  /// Featured = highest-ranked club (index 0 after sort).
  FeaturedClub? get featured {
    if (_clubs.isEmpty) return null;
    final top = _clubs.first;
    return FeaturedClub(
      name: top.name,
      description: top.bio!,
      imageUrl: top.profilePicture.isNotEmpty
          ? top.profilePicture
          : 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1200',
    );
  }

  /// Sort: events desc, then members desc.
  void _sortClubs() {
    _clubs.sort((a, b) {
      final byEvents = b.events.compareTo(a.events);
      if (byEvents != 0) return byEvents;
      return b.members.compareTo(a.members);
    });
  }

  Future<void> ensureLoaded() async {
    if (_hasLoadedOnce && _clubs.isNotEmpty) return;
    await fetchClubs();
  }

  Future<void> fetchClubs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.listClubs();
      final list = _extractClubList(response);
      _clubs = list.map(Club.fromClubJson).toList();
      _sortClubs();
      _errorMessage = null;
    } on Exception catch (e) {
      _errorMessage = 'Unable to load clubs: $e';
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  Future<bool> createClubRecord({
    required String name,
    required String description,
  }) async {
    if (_isCreatingClub) return false;
    _isCreatingClub = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createClub(
        name: name.trim(),
        description: description.trim(),
      );
      final rawClub = response['club'] ?? response['data'] ?? response;
      if (rawClub is Map) {
        final club = Club.fromClubJson(Map<String, dynamic>.from(rawClub));
        if (club.id.isNotEmpty) {
          _clubs.removeWhere((existing) => existing.id == club.id);
          _clubs.insert(0, club);
        }
      }

      if (_clubs.isEmpty) {
        final refreshed = await _apiService.listClubs();
        _clubs = _extractClubList(refreshed).map(Club.fromClubJson).toList();
      }

      if (_clubs.isEmpty) {
        _errorMessage = 'Club was created, but no Club record was returned.';
        return false;
      }
      _hasLoadedOnce = true;
      return true;
    } on Exception catch (error) {
      _errorMessage = 'Unable to create club record: $error';
      return false;
    } finally {
      _isCreatingClub = false;
      notifyListeners();
    }
  }

  Future<Club?> getClubById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getClub(id);
      final map = _extractClubMap(response);
      final club = Club.fromClubJson(map);
      _selectedClub = club;

      final index = _clubs.indexWhere((element) => element.id == club.id);
      if (index != -1) {
        _clubs[index] = club;
      } else {
        _clubs.add(club);
      }

      _errorMessage = null;
      return club;
    } on Exception catch (e) {
      _errorMessage = 'Unable to load club details: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinClub(String clubId) async {
    try {
      final response = await _apiService.joinClub(clubId);
      final success = response.isNotEmpty;

      if (success) {
        final index = _clubs.indexWhere((element) => element.id == clubId);
        if (index != -1) {
          final current = _clubs[index];
          current.joinRequestStatus = 'pending';
        }
      }
      notifyListeners();
      return success;
    } on Exception catch (e) {
      _errorMessage = 'Unable to join club: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadJoinRequests({String? status}) async {
    _isLoadingRequests = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.listClubJoinRequests(status: status);
      final raw = response['requests'] ?? response['data'] ?? response;
      _joinRequests = raw is List
          ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];
    } on Exception catch (error) {
      _errorMessage = 'Unable to load join requests: $error';
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<bool> reviewJoinRequest(
    String requestId, {
    required bool approve,
  }) async {
    try {
      await _apiService.reviewClubJoinRequest(
        requestId,
        status: approve ? 'approved' : 'rejected',
      );
      _joinRequests.removeWhere((request) => request['_id']?.toString() == requestId);
      notifyListeners();
      return true;
    } on Exception catch (error) {
      _errorMessage = 'Unable to update join request: $error';
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> _extractClubList(Map<String, dynamic> payload) {
    final raw = payload['data'] ??
        payload['clubs'] ??
        payload['results'] ??
        payload['items'] ??
        payload;

    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
        final nested = map['clubs'] ??
          map['data'] ??
          map['results'] ??
          map['items'];
      if (nested is List) {
        return nested.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (map.containsKey('_id') || map.containsKey('name')) {
        return [map];
      }
    }

    return const [];
  }

  Map<String, dynamic> _extractClubMap(Map<String, dynamic> payload) {
    final raw = payload['data'] ?? payload['club'] ?? payload;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    throw const FormatException('Club payload is not a map');
  }

  Future<void> fetchOrganisers() async {
    await fetchClubs();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    fetchClubs();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchOrganisers();
    });
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
    fetchClubs();
  }

  void toggleJoin(String clubId) {
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index == -1) return;
    _clubs[index].isJoined = !_clubs[index].isJoined;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}