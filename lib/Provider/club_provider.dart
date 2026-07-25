import 'package:flutter/material.dart';
import '../Model/club.dart';

class ClubProvider extends ChangeNotifier {
  final List<String> categories = const [
    'All',
    'Technical',
    'Cultural',
    'Social',
    'Sports',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final FeaturedClub featured = const FeaturedClub(
    name: 'Google Developer Student Club',
    description:
        'Building the next generation of software engineers through community and tech.',
    imageUrl:
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1200',
  );

  final List<Club> _clubs = [
    Club(
      id: '1',
      name: 'AI Research Lab',
      description:
          'Exploring the frontiers of neural networks and machine learning in modern robotics.',
      category: 'Technical',
      members: 412,
      tag: ClubTag.popular,
      emoji: '🧠',
    ),
    Club(
      id: '2',
      name: 'Competitive Coding',
      description:
          'Mastering algorithms and data structures to dominate national hackathons.',
      category: 'Technical',
      members: 188,
      tag: ClubTag.trending,
      emoji: '💻',
    ),
  ];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Club> get filteredClubs {
    return _clubs.where((club) {
      final matchesCategory =
          _selectedCategory == 'All' || club.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          club.name.toLowerCase().contains(_searchQuery.toLowerCase());
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

  void toggleJoin(String clubId) {
    final club = _clubs.firstWhere((c) => c.id == clubId);
    club.isJoined = !club.isJoined;
    notifyListeners();
  }
}
