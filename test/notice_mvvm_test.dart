import 'package:college/notice/notice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notice feature exposes MVVM view model', () {
    expect(NoticeViewModel, isNotNull);
  });
}
