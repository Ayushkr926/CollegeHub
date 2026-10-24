import 'package:college/Api/api_constants.dart';
import 'package:college/Api/app_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app api service exposes api groups from backend spec', () {
    expect(AppApiService, isNotNull);
    expect(ApiConstants.authStudentRegister.endsWith('/auth/student/register'), isTrue);
    expect(ApiConstants.authLogin.endsWith('/auth/login'), isTrue);
    expect(ApiConstants.clubs.endsWith('/clubs'), isTrue);
    expect(ApiConstants.notices.endsWith('/notices'), isTrue);
    expect(ApiConstants.analyticsDashboard.endsWith('/analytics/dashboard'), isTrue);
  });
}
