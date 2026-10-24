import '../providers/notice_provider.dart';

/// MVVM view-model layer for the notice feature.
///
/// This keeps the existing business logic in [NoticeProvider] while exposing a
/// dedicated MVVM entry point that screens can consume. The original provider is
/// kept for backward compatibility with the rest of the app.
class NoticeViewModel extends NoticeProvider {
  NoticeViewModel({required super.repository});
}
