import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Model/club.dart';

class ClubProvider extends ChangeNotifier {
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
  String? _errorMessage;
  Timer? _debounceTimer;

  List<Club> _clubs = [];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
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
    await fetchOrganisers();
  }

  Future<void> fetchOrganisers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('\n========== FETCH ORGANISERS START ==========');

    try {
      // Fixed double slash
      final uri = Uri.parse(
        'http://192.168.1.7:5000/api/v1/auth/organisers',
      ).replace(
        queryParameters: {
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
          if (_selectedCategory != 'All') 'category': _selectedCategory,
        },
      );

      debugPrint('URL: $uri');
      debugPrint('Search Query: $_searchQuery');
      debugPrint('Selected Category: $_selectedCategory');

      final response = await http
          .get(
        uri,
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 15));

      debugPrint('Status Code : ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        if (body['success'] == true && body['data'] != null) {
          final list = body['data']['organisers'] as List? ?? [];

          _clubs = list
              .map(
                (e) => Club.fromOrganiserJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
              .toList();

          // Sort by events → members (desc). Index 0 becomes featured.
          _sortClubs();

          for (int i = 0; i < _clubs.length; i++) {
            final c = _clubs[i];
            debugPrint(
              '[$i] ${c.name} | events=${c.events} | members=${c.members} | ${c.category}',
            );
          }

          _errorMessage = null;
          debugPrint('✅ Clubs parsed & sorted (${_clubs.length})');
        } else {
          _errorMessage =
              body['message']?.toString() ?? 'Failed to load clubs';
          debugPrint('❌ API success=false: $_errorMessage');
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
        debugPrint('❌ Server error ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      _errorMessage = 'Request timed out. Pull to retry.';
      debugPrint('⏰ Timeout: $e');
    } catch (e, st) {
      _errorMessage = 'Network error: $e';
      debugPrint('❌ Exception: $e\n$st');
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      debugPrint(
        'FINAL → loading=$_isLoading clubs=${_clubs.length} error=$_errorMessage',
      );
      debugPrint('========== FETCH ORGANISERS END ==========\n');
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    fetchOrganisers();
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
    fetchOrganisers();
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