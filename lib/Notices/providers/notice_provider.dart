import 'dart:io';

import 'package:flutter/foundation.dart';

import '../create_notice/model/notice_create_model.dart';
import '../repositories/notice_repository.dart';

class NoticeProvider extends ChangeNotifier {
  NoticeProvider({NoticeRepository? repository}) : _repository = repository ?? NoticeRepository();

  final NoticeRepository _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Map<String, dynamic>> _notices = const [];
  List<String> _suggestions = const [];
  Map<String, dynamic>? _activeNotice;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Map<String, dynamic>> get notices => _notices;
  List<String> get suggestions => _suggestions;
  Map<String, dynamic>? get activeNotice => _activeNotice;

  Future<bool> createNotice({
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createNotice(
        form: form,
        coverFiles: coverFiles,
        galleryFiles: galleryFiles,
        attachmentFiles: attachmentFiles,
      );
      _activeNotice = result;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateNotice({
    required String id,
    required NoticeFormData form,
    List<File> coverFiles = const [],
    List<File> galleryFiles = const [],
    List<File> attachmentFiles = const [],
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.updateNotice(
        id: id,
        form: form,
        coverFiles: coverFiles,
        galleryFiles: galleryFiles,
        attachmentFiles: attachmentFiles,
      );
      _activeNotice = result;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadNotices({String? search, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notices = await _repository.fetchNotices(search: search, category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSearchSuggestions({String? query}) async {
    try {
      _suggestions = await _repository.getSearchSuggestions(query: query);
      notifyListeners();
    } catch (_) {
      _suggestions = const [];
      notifyListeners();
    }
  }

  Future<void> loadNotice(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getNotice(id);
      _activeNotice = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBookmark(String id) async {
    try {
      final result = await _repository.bookmarkNotice(id);
      if (result['success'] == false) {
        await _repository.removeBookmark(id);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleLike(String id) async {
    try {
      final result = await _repository.likeNotice(id);
      if (result['success'] == false) {
        await _repository.unlikeNotice(id);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> togglePin(String id) async {
    try {
      final result = await _repository.pinNotice(id);
      if (result['success'] == false) {
        await _repository.unpinNotice(id);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> publishNotice(String id) async {
    try {
      await _repository.publishNotice(id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
