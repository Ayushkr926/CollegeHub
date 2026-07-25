import 'package:flutter/material.dart';

import '../Model/request.dart';

class Requestprovider extends ChangeNotifier {
  final List<String> categories = const [
    'All',
    'Pending',
    'Accepted',
    'Declined',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Request> _requests = [
    Request(
      id: '1',
      name: 'Ayush Kumar',
      branch: 'CSE (Data Science)',
      year: 3,
      image: 'assets/images/onboarding.jpg',
      timeago: '5 min ago',
    ),
    Request(
      id: '2',
      name: 'Priya Sharma',
      branch: 'Information Technology',
      year: 2,
      image: 'assets/images/onboarding.jpg',
      timeago: '12 min ago',
    ),
    Request(
      id: '3',
      name: 'Rohit Verma',
      branch: 'Computer Science',
      year: 4,
      image: 'assets/images/onboarding.jpg',
      timeago: '25 min ago',
    ),
    Request(
      id: '4',
      name: 'Ananya Gupta',
      branch: 'Electronics & Communication',
      year: 1,
      image: 'assets/images/onboarding.jpg',
      timeago: '40 min ago',
    ),
    Request(
      id: '5',
      name: 'Karan Singh',
      branch: 'Mechanical Engineering',
      year: 3,
      image: 'assets/images/onboarding.jpg',
      timeago: '1h ago',
    ),
    Request(
      id: '6',
      name: 'Sneha Patel',
      branch: 'Artificial Intelligence',
      year: 2,
      image: 'assets/images/onboarding.jpg',
      timeago: '2h ago',
    ),
    Request(
      id: '7',
      name: 'Aditya Mishra',
      branch: 'Electrical Engineering',
      year: 4,
      image: 'assets/images/onboarding.jpg',
      timeago: '3h ago',
    ),
    Request(
      id: '8',
      name: 'Neha Agarwal',
      branch: 'Civil Engineering',
      year: 1,
      image: 'assets/images/onboarding.jpg',
      timeago: 'Yesterday',
    ),
    Request(
      id: '9',
      name: 'Rahul Yadav',
      branch: 'CSE (AI & ML)',
      year: 3,
      image: 'assets/images/onboarding.jpg',
      timeago: 'Yesterday',
    ),
    Request(
      id: '10',
      name: 'Divyansh Saxena',
      branch: 'Computer Science',
      year: 2,
      image: 'assets/images/onboarding.jpg',
      timeago: '2 days ago',
    ),
  ];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

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

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
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

  void acceptRequest(String id) => _setStatus(id, RequestStatus.accepted);

  void declineRequest(String id) => _setStatus(id, RequestStatus.declined);

  /// Reverts a request back to pending (used for the Snackbar "Undo" action).
  void undoAction(String id) => _setStatus(id, RequestStatus.pending);

  void _setStatus(String id, RequestStatus status) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _requests[index].status = status;
    notifyListeners();
  }
}