import 'package:flutter/material.dart';

import '../screens/notice_detail_screen.dart';

/// View wrapper used by the MVVM layer.
class NoticeDetailView extends StatelessWidget {
  const NoticeDetailView({super.key, required this.noticeId, this.canManageNotices = false});

  final String noticeId;
  final bool canManageNotices;

  @override
  Widget build(BuildContext context) {
    return NoticeDetailScreen(
      noticeId: noticeId,
      canManageNotices: canManageNotices,
    );
  }
}
