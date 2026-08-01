/// Barrel export for the notice feature module.
/// Import this single file wherever you need notice functionality:
///   import 'package:your_app/notice/notice.dart';
library notice;

export 'models/notice_form_data.dart';
export 'services/notice_api_service.dart';
export 'repositories/notice_repository.dart';
export 'providers/notice_provider.dart';

export 'screens/notice_list_screen.dart';
export 'screens/notice_detail_screen.dart';
export 'screens/notice_form_screen.dart';
export 'screens/notice_search_screen.dart';

export 'widgets/notice_card.dart';
export 'widgets/state_views.dart';
