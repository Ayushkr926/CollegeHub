import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


/// -----------------------------------------------------------------------
/// LocalStorageService
/// -----------------------------------------------------------------------
/// An advanced, production-ready wrapper around SharedPreferences.
///
/// Features:
///  - Singleton access (LocalStorageService.instance)
///  - Must be initialized once at app startup (await LocalStorageService.init())
///  - In-memory cache layer for fast synchronous reads after first load
///  - Type-safe getters/setters for String, int, double, bool, List<String>
///  - JSON object (Map) and List<Map> storage helpers
///  - Enum storage helpers
///  - DateTime storage helpers
///  - Namespacing / key prefixing support (useful for multi-user apps)
///  - Safe error handling (never throws on read, returns default instead)
///  - clearAll(), remove(), containsKey(), getKeys()
///
/// Usage:
///   await LocalStorageService.init();
///   final storage = LocalStorageService.instance;
///   await storage.setString(StorageKeys.username, "Ahmed");
///   final name = storage.getString(StorageKeys.username);
/// -----------------------------------------------------------------------
///
///
class StorageKeys {
  StorageKeys._();

  static const String username = 'username';
  static const String authToken = 'auth_token';
  static const String isLoggedIn = 'is_logged_in';
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastSyncDate = 'last_sync_date';
  static const String userProfile = 'user_profile';
  static const String cartItems = 'cart_items';
}

class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();

  /// Global singleton access point.
  static LocalStorageService get instance => _instance;

  static SharedPreferences? _prefs;

  /// Optional prefix applied to every key (e.g. per-user namespacing).
  /// Set this via [setNamespace] if you need to isolate storage per user.
  String _namespace = '';

  /// In-memory cache to avoid hitting SharedPreferences repeatedly
  /// and to allow instant synchronous reads.
  final Map<String, Object?> _cache = {};

  /// Must be called once (e.g. in main()) before using the service.
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await LocalStorageService.init();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
        'LocalStorageService not initialized. '
            'Call `await LocalStorageService.init()` before using it.',
      );
    }
  }

  /// Apply a namespace/prefix to all keys, useful for multi-account apps
  /// where you want to isolate stored data per logged-in user.
  void setNamespace(String namespace) {
    _namespace = namespace.isEmpty ? '' : '${namespace}_';
    _cache.clear(); // invalidate cache when namespace changes
  }

  String _key(String key) => '$_namespace$key';

  // ---------------------------------------------------------------------
  // Generic helpers
  // ---------------------------------------------------------------------

  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(_key(key));
  }

  Future<bool> remove(String key) async {
    _ensureInitialized();
    _cache.remove(_key(key));
    try {
      return await _prefs!.remove(_key(key));
    } catch (_) {
      return false;
    }
  }

  /// Clears ALL data in SharedPreferences (every namespace too).
  Future<bool> clearAll() async {
    _ensureInitialized();
    _cache.clear();
    try {
      return await _prefs!.clear();
    } catch (_) {
      return false;
    }
  }

  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  Future<void> reloadFromDisk() async {
    _ensureInitialized();
    _cache.clear();
    await _prefs!.reload();
  }

  // ---------------------------------------------------------------------
  // String
  // ---------------------------------------------------------------------

  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    try {
      final ok = await _prefs!.setString(_key(key), value);
      if (ok) _cache[_key(key)] = value;
      return ok;
    } catch (_) {
      return false;
    }
  }

  String? getString(String key, {String? defaultValue}) {
    _ensureInitialized();
    final k = _key(key);
    if (_cache.containsKey(k)) return _cache[k] as String? ?? defaultValue;
    try {
      final value = _prefs!.getString(k);
      _cache[k] = value;
      return value ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  // ---------------------------------------------------------------------
  // Int
  // ---------------------------------------------------------------------

  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    try {
      final ok = await _prefs!.setInt(_key(key), value);
      if (ok) _cache[_key(key)] = value;
      return ok;
    } catch (_) {
      return false;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    _ensureInitialized();
    final k = _key(key);
    if (_cache.containsKey(k)) return _cache[k] as int? ?? defaultValue;
    try {
      final value = _prefs!.getInt(k);
      _cache[k] = value;
      return value ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  // ---------------------------------------------------------------------
  // Double
  // ---------------------------------------------------------------------

  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    try {
      final ok = await _prefs!.setDouble(_key(key), value);
      if (ok) _cache[_key(key)] = value;
      return ok;
    } catch (_) {
      return false;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    _ensureInitialized();
    final k = _key(key);
    if (_cache.containsKey(k)) return _cache[k] as double? ?? defaultValue;
    try {
      final value = _prefs!.getDouble(k);
      _cache[k] = value;
      return value ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  // ---------------------------------------------------------------------
  // Bool
  // ---------------------------------------------------------------------

  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    try {
      final ok = await _prefs!.setBool(_key(key), value);
      if (ok) _cache[_key(key)] = value;
      return ok;
    } catch (_) {
      return false;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    final k = _key(key);
    if (_cache.containsKey(k)) return _cache[k] as bool? ?? defaultValue;
    try {
      final value = _prefs!.getBool(k);
      _cache[k] = value;
      return value ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  // ---------------------------------------------------------------------
  // List<String>
  // ---------------------------------------------------------------------

  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    try {
      final ok = await _prefs!.setStringList(_key(key), value);
      if (ok) _cache[_key(key)] = value;
      return ok;
    } catch (_) {
      return false;
    }
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    _ensureInitialized();
    final k = _key(key);
    if (_cache.containsKey(k)) {
      return (_cache[k] as List<String>?) ?? defaultValue ?? [];
    }
    try {
      final value = _prefs!.getStringList(k);
      _cache[k] = value;
      return value ?? defaultValue ?? [];
    } catch (_) {
      return defaultValue ?? [];
    }
  }

  // ---------------------------------------------------------------------
  // JSON object (Map<String, dynamic>) storage
  // ---------------------------------------------------------------------

  /// Stores any JSON-serializable object (Map, or a model's `.toJson()`).
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves a stored JSON object as a Map. Returns null if not found
  /// or if decoding fails.
  Map<String, dynamic>? getObject(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // List of JSON objects (List<Map<String, dynamic>>)
  // ---------------------------------------------------------------------

  Future<bool> setObjectList(
      String key,
      List<Map<String, dynamic>> value,
      ) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (_) {
      return false;
    }
  }

  List<Map<String, dynamic>> getObjectList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------
  // DateTime helpers
  // ---------------------------------------------------------------------

  Future<bool> setDateTime(String key, DateTime value) async {
    return setString(key, value.toIso8601String());
  }

  DateTime? getDateTime(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // ---------------------------------------------------------------------
  // Enum helpers
  // ---------------------------------------------------------------------

  /// Stores an enum by its `.name` (Dart 2.15+).
  Future<bool> setEnum<T extends Enum>(String key, T value) async {
    return setString(key, value.name);
  }

  /// Retrieves an enum value by matching against [values].
  ///
  /// Example:
  /// ```dart
  /// final mode = storage.getEnum(StorageKeys.themeMode, ThemeMode.values, ThemeMode.system);
  /// ```
  T getEnum<T extends Enum>(String key, List<T> values, T defaultValue) {
    final raw = getString(key);
    if (raw == null) return defaultValue;
    return values.firstWhere(
          (e) => e.name == raw,
      orElse: () => defaultValue,
    );
  }

  // ---------------------------------------------------------------------
  // Convenience: generic model save/load using fromJson/toJson callbacks
  // ---------------------------------------------------------------------

  /// Save any model that has a `toJson()` method.
  Future<bool> setModel<T>(
      String key,
      T model,
      Map<String, dynamic> Function(T) toJson,
      ) async {
    return setObject(key, toJson(model));
  }

  /// Load any model using a `fromJson()` factory/constructor.
  T? getModel<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final map = getObject(key);
    if (map == null) return null;
    try {
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }
}