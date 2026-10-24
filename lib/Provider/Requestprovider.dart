import 'package:flutter/material.dart';

import '../Api/app_api_service.dart';
import '../Model/request.dart';

class Requestprovider extends ChangeNotifier {
  final AppApiService _apiService = AppApiService();
  final List<String> categories = const [
    'All',
    'Pending',
    'Accepted',
    'Declined',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<Request> _requests = [];
  bool _isLoading = false;
  String? _error;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount =>
      _requests.where((r) => r.status == RequestStatus.pending).length;

  List<Request> get filteredClubs {
    return _requests.where((r) {
      final matchesCategory = switch (_selectedCategory) {
        'Pending' => r.status == RequestStatus.pending,
        'Accepted' => r.status == RequestStatus.accepted,
        'Declined' => r.status == RequestStatus.declined,
        _ => true,
      };

      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.branch.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final payload = await _apiService.listClubJoinRequests(
        status: switch (_selectedCategory) {
          'Pending' => 'pending',
          'Accepted' => 'approved',
          'Declined' => 'rejected',
          _ => null,
        },
      );
      final raw = payload['requests'] ?? payload['data'] ?? payload;
      _requests
        ..clear()
        ..addAll(raw is List
            ? raw.whereType<Map>().map(
                (item) => Request.fromJson(Map<String, dynamic>.from(item)),
              )
            : const <Request>[]);
    } on Exception catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    loadRequests();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> reviewRequest(String id, {required bool approve}) async {
    final ok = await _apiService.reviewClubJoinRequest(
      id,
      status: approve ? 'approved' : 'rejected',
    );
    if (ok.isNotEmpty) {
      _requests.removeWhere((request) => request.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}