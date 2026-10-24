import 'package:flutter/material.dart';

import '../screens/notice_list_screen.dart';

/// View wrapper used by the MVVM layer.
class NoticeListView extends StatelessWidget {
  const NoticeListView({super.key, this.canManageNotices = true});

  final bool canManageNotices;

  @override
  Widget build(BuildContext context) {
    return NoticeListScreen(canManageNotices: canManageNotices);
  }
}
