# Notice Module

Drop this `notice/` folder into `flutter/lib/` (replacing/merging with your
existing `flutter/lib/notice/` folder). It's a self-contained MVVM feature
module: models → services → repositories → providers → screens/widgets.

## 1. Folder placement

```
your_flutter_app/
  lib/
    notice/              <-- paste this whole folder here
      models/
        notice_form_data.dart
      services/
        notice_api_service.dart
      repositories/
        notice_repository.dart
      providers/
        notice_provider.dart
      screens/
        notice_list_screen.dart
        notice_detail_screen.dart
        notice_form_screen.dart
        notice_search_screen.dart
      widgets/
        notice_card.dart
        state_views.dart
      notice.dart          <-- barrel export
      README.md            <-- this file
```

If you already have files at these exact paths (as named in your original
prompt), this **replaces them** with the full implementation. Nothing here
references any file outside this folder except Flutter/Dart packages below.

## 2. Required packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  dio: ^5.4.3
  image_picker: ^1.1.2
  file_picker: ^8.0.0
  url_launcher: ^6.3.0
```

Then run:

```bash
flutter pub get
```

Android: no extra config needed for image_picker/file_picker on modern
Flutter versions. iOS: add camera/photo library usage strings to
`ios/Runner/Info.plist` if you enable camera capture (this module uses
gallery/file picking only, so it's optional):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to attach images to notices</string>
```

## 3. Wire the provider at app startup

In your `main.dart` (or wherever you already set up Providers), add:

```dart
import 'package:provider/provider.dart';
import 'notice/notice.dart';

// You likely already have an auth provider/session holder that exposes
// the current JWT. Wire it into the token provider callback:
final noticeApiService = NoticeApiService(
  baseUrl: 'http://localhost:5000/api/v1', // swap for your prod URL / env config
  tokenProvider: () => yourAuthProvider.currentToken, // return null if signed out
);
final noticeRepository = NoticeRepository(apiService: noticeApiService);

runApp(
  MultiProvider(
    providers: [
      // ...your existing providers
      ChangeNotifierProvider(create: (_) => NoticeProvider(repository: noticeRepository)),
    ],
    child: const MyApp(),
  ),
);
```

If you use multiple base URLs per environment (dev/staging/prod), pass the
right one in based on your existing config/flavor setup — this module
takes it as a constructor parameter rather than hardcoding it, aside from
the `localhost:5000` default matching what was specified.

## 4. Navigate to the notice list

Wherever your app's navigation/menu lives:

```dart
import 'notice/notice.dart';

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => NoticeListScreen(
      canManageNotices: currentUser.role == 'admin' || currentUser.role == 'faculty',
    ),
  ),
);
```

`canManageNotices` gates the create FAB and the publish/archive/pin/restore/
delete controls on the detail screen. Students get read-only access
(browse, search, like, bookmark, mark-as-read) automatically when this is
`false`.

## 5. Adjust taxonomy lists to match your backend

`notice_form_screen.dart` and `notice_search_screen.dart` currently define
placeholder option lists for categories/campuses/departments/years/
programmes as static const lists near the top of each file:

```dart
static const _categories = ['Academic', 'Events', 'Placement', ...];
static const _campuses = ['Main Campus', 'North Campus', 'South Campus'];
```

Replace these with your actual taxonomy — either hardcode your real values,
or swap them for a provider-driven fetch from your backend if you have a
`/categories` or `/campuses` endpoint. Everything else (validation, API
calls, state) is unaffected by this change.

## 6. What's already handled

- All 20 backend endpoints from the spec, wired end-to-end
  (create/update/delete/restore/archive/publish/pin/unpin/detail/list/
  trending/recent/featured/suggestions/similar/bookmark/like/read)
- Every form field from the spec (title → versionNotes)
- Every list filter/query param from the spec (page → bookmarked)
- multipart/form-data upload for coverImage/images/attachments with JWT
  bearer auth auto-attached via Dio interceptor
- Preserving existing media on edit (only removes what the user explicitly
  removes, via `removedImageUrls`/`removedAttachmentUrls`)
- Loading / error / empty states on every screen
- Field-level validation before submit
- Autocomplete search suggestions (debounced)
- Full filter sheet (category, tags, campus, department, programme, year,
  visibility, important, pinned, draft, scheduled, expired, bookmarked,
  createdByMe, sort/order)
- Trending / Recent / Featured sections on the list screen
- List state preserved when returning from detail/edit (no refetch)
- Role-aware admin/faculty controls on the detail screen (publish, archive,
  pin with duration picker, unpin, restore, delete with confirmation)
- Optimistic like/bookmark toggling with rollback on failure
- CTA button rendering when `customCtaText`/`customCtaUrl` are present

## 7. Known integration points you should double check

- **Base URL**: defaults to `http://localhost:5000/api/v1` per the spec.
  Change this for your real backend/environment.
- **Auth token source**: `tokenProvider` is a plain callback — point it at
  wherever your app currently stores the JWT (SharedPreferences, secure
  storage, an auth ChangeNotifier, etc.). This module does not manage auth
  itself.
- **Response envelope shape**: `NoticeModel.fromJson` and
  `NoticeListResult.fromJson` are written defensively (checking for `data`
  wrappers, `items`/`notices` list keys, etc.) to match common Express/Node
  response shapes, but if your backend's actual JSON keys differ from the
  field names in the spec, adjust the `fromJson` factories in
  `notice_form_data.dart` — that's the single place all parsing happens.
