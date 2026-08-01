import 'package:college/Notices/create_notice/model/notice_create_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoticeFormData backend mapping', () {
    test('builds a multipart-compatible payload for create/update requests', () {
      final form = NoticeFormData(
        title: 'Placement Drive',
        summary: 'Drive details',
        body: 'Full details',
        primaryCategory: 'Placements',
        publisherId: 'user-1',
        publisherName: 'Placement Cell',
        visibility: VisibilityType.collegeWide,
        publishType: PublishType.now,
        isImportant: true,
        isPinned: true,
        sendPush: true,
        attachmentPaths: ['file1.pdf'],
        secondaryTags: ['placement', 'drive'],
        customTags: ['urgent'],
        targetCampuses: ['main'],
        targetDepartments: ['CSE'],
        targetYears: ['2026'],
        targetProgrammes: ['B.Tech'],
        allowGuestAccess: true,
        customCtaText: 'Register',
        customCtaUrl: 'https://example.com',
      );

      final payload = form.toBackendPayload();

      expect(payload['title'], 'Placement Drive');
      expect(payload['summary'], 'Drive details');
      expect(payload['body'], 'Full details');
      expect(payload['primaryCategory'], 'Placements');
      expect(payload['visibility'], 'collegeWide');
      expect(payload['publishType'], 'immediate');
      expect(payload['secondaryTags'], ['placement', 'drive']);
      expect(payload['customTags'], ['urgent']);
      expect(payload['attachmentPaths'], ['file1.pdf']);
      expect(payload['allowGuestAccess'], true);
      expect(payload['isImportant'], true);
      expect(payload['isPinned'], true);
      expect(payload['sendPush'], true);
    });
  });
}
