/// Static option lists used by dropdown fields across registration screens.
class AppConstants {
  AppConstants._();

  static const List<String> courses = [
    'B.Tech',
    'M.Tech',
    'BCA',
    'MCA',
    'MBA',
    'BBA',
    'PhD',
    'Other',
  ];

  static const List<String> branches = [
    'CSE',
    'CSE (Data Science)',
    'CSE (AI/ML)',
    'IT',
    'ECE',
    'EE',
    'ME',
    'CE',
    'Other',
  ];

  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
  ];

  static const List<int> yearNumbers = [1, 2, 3, 4, 5];

  static String normalizeCourse(String? value) {
    final key = _key(value);
    if (key.isEmpty) return '';
    const aliases = {
      'btech': 'B.Tech',
      'bacheloroftechnology': 'B.Tech',
      'mtech': 'M.Tech',
      'masteroftechnology': 'M.Tech',
      'bca': 'BCA',
      'bachelorofcomputerapplications': 'BCA',
      'mca': 'MCA',
      'masterofcomputerapplications': 'MCA',
      'mba': 'MBA',
      'masterofbusinessadministration': 'MBA',
      'bba': 'BBA',
      'bachelorofbusinessadministration': 'BBA',
      'phd': 'PhD',
      'doctorofphilosophy': 'PhD',
      'other': 'Other',
    };
    if (aliases.containsKey(key)) return aliases[key]!;
    if (key.startsWith('btech')) return 'B.Tech';
    if (key.startsWith('mtech')) return 'M.Tech';
    if (key.startsWith('bca')) return 'BCA';
    if (key.startsWith('mca')) return 'MCA';
    if (key.startsWith('mba')) return 'MBA';
    if (key.startsWith('bba')) return 'BBA';
    if (key.startsWith('phd')) return 'PhD';
    return 'Other';
  }

  static String normalizeBranch(String? value) {
    final key = _key(value);
    if (key.isEmpty) return '';
    const aliases = {
      'cse': 'CSE',
      'cs': 'CSE',
      'computerscience': 'CSE',
      'computerscienceengineering': 'CSE',
      'computerengineering': 'CSE',
      'csedatascience': 'CSE (Data Science)',
      'computersciencedatascience': 'CSE (Data Science)',
      'artificialintelligenceanddatascience': 'CSE (Data Science)',
      'cseaiml': 'CSE (AI/ML)',
      'cseaimachinelearning': 'CSE (AI/ML)',
      'artificialintelligence': 'CSE (AI/ML)',
      'it': 'IT',
      'informationtechnology': 'IT',
      'ece': 'ECE',
      'electronics': 'ECE',
      'electronicscommunication': 'ECE',
      'electronicsandcommunication': 'ECE',
      'electricalandelectronics': 'ECE',
      'ee': 'EE',
      'electrical': 'EE',
      'electricalengineering': 'EE',
      'me': 'ME',
      'mechanical': 'ME',
      'mechanicalengineering': 'ME',
      'ce': 'CE',
      'civil': 'CE',
      'civilengineering': 'CE',
      'other': 'Other',
    };
    return aliases[key] ?? 'Other';
  }

  static int? normalizeYear(dynamic value) {
    if (value is int) return value > 0 ? value : null;
    if (value is num) return value > 0 ? value.toInt() : null;
    if (value == null) return null;

    final text = value.toString().trim().toLowerCase();
    final match = RegExp(r'\d+').firstMatch(text);
    if (match != null) {
      final parsed = int.tryParse(match.group(0)!);
      return parsed != null && parsed > 0 ? parsed : null;
    }
    const words = {
      'first year': 1,
      'second year': 2,
      'third year': 3,
      'fourth year': 4,
      'fifth year': 5,
    };
    return words[text];
  }

  static String yearLabel(dynamic value) {
    final year = normalizeYear(value);
    if (year == null) return '';
    if (year < 1 || year > 5) return year.toString();
    final suffix = year == 1 ? 'st' : year == 2 ? 'nd' : year == 3 ? 'rd' : 'th';
    return '$year$suffix Year';
  }

  static List<int> normalizeYears(Iterable<dynamic> values) {
    final years = <int>{};
    for (final value in values) {
      if (_key(value?.toString()) == 'allyears') {
        years.addAll(yearNumbers);
        continue;
      }
      final year = normalizeYear(value);
      if (year != null) years.add(year);
    }
    return years.toList()..sort();
  }

  static List<String> yearLabels(Iterable<dynamic> values) => values
      .map(yearLabel)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  static List<String> normalizeBranches(Iterable<dynamic> values) => values
      .map((value) => normalizeBranch(value?.toString()))
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  static List<String> normalizeCourses(Iterable<dynamic> values) => values
      .map((value) => normalizeCourse(value?.toString()))
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  static String _key(String? value) =>
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static const List<String> clubCategories = [
    'Technical',
    'Cultural',
    'Sports',
    'Literary',
    'Music & Dance',
    'Social Service',
    'Entrepreneurship',
    'Other',
  ];
}
