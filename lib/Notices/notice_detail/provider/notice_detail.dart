import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../homescreen/notice_models.dart';
import 'notice_detail_provider.dart';


class AppColors {
  // ===== Primary Palette (Modern Indigo-Blue) =====
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySoft = Color(0xFFDBEAFE);

  // ===== Header Gradient Colors =====
  static const Color headerGradientStart = Color(0xFF1E3A8A);
  static const Color headerGradientEnd = Color(0xFF2563EB);

  // ===== Backgrounds =====
  static const Color background = Color(0xFFF8FAFC); // App background slate
  static const Color surface = Color(0xFFFFFFFF); // Card / container surface
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Section background
  static const Color cardHover = Color(0xFFF8FAFC);

  // ===== Borders =====
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // ===== Text Hierarchy =====
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // ===== Icons =====
  static const Color icon = Color(0xFF3B82F6);
  static const Color iconInactive = Color(0xFF94A3B8);

  // ===== Buttons =====
  static const Color button = primary;
  static const Color buttonHover = Color(0xFF1D4ED8);
  static const Color buttonDisabled = Color(0xFF93C5FD);

  // ===== Chips =====
  static const Color chip = Color(0xFFF1F5F9);
  static const Color chipSelected = primary;
  static const Color chipBorder = Color(0xFFCBD5E1);

  // ===== Inputs =====
  static const Color inputFill = Colors.white;
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputFocused = primary;

  // ===== Navigation =====
  static const Color navBackground = Colors.white;
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF64748B);

  // ===== Status =====
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = primary;

  // ===== Shadows =====
  static const Color shadow = Color(0x0F0F172A);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.primaryLight,
      onSecondary: AppColors.textPrimary,

      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,

      secondaryContainer: AppColors.surfaceVariant,
      onSecondaryContainer: AppColors.textPrimary,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,

      outline: AppColors.border,
      outlineVariant: AppColors.divider,

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        side: const BorderSide(color: AppColors.border),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 8,
        shadowColor: AppColors.shadow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}


class NoticeDetailScreen extends StatefulWidget {
  final String noticeId;
  final Notice? cachedNotice;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
    this.cachedNotice,
  });

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  late final NoticeDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NoticeDetailProvider();
    // Load immediately
    _provider.load(widget.noticeId, cached: widget.cachedNotice);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<NoticeDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, provider),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────
  // APP BAR
  // ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, NoticeDetailProvider provider) {
    final notice = provider.notice;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        notice?.publisher.name ?? 'Notice',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            notice?.isBookmarked == true
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: notice?.isBookmarked == true
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          onPressed: notice == null
              ? null
              : () {
            final wasBookmarked = notice.isBookmarked;
            provider.toggleBookmark();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(wasBookmarked
                    ? 'Removed from bookmarks'
                    : 'Added to bookmarks'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: provider.toggleBookmark,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: notice == null ? null : () {
            // TODO: Share.share(...)
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            switch (value) {
              case 'unread':
                provider.markAsUnread();
                break;
              case 'copy':
                Clipboard.setData(ClipboardData(
                  text: 'https://college.app/notice/${notice?.id}',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
                break;
              case 'report':
                _showReportSheet(context);
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'unread', child: Text('Mark as Unread')),
            PopupMenuItem(value: 'copy', child: Text('Copy Link')),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'report',
              child: Text('Report Notice', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────
  // BODY
  // ────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, NoticeDetailProvider provider) {
    switch (provider.state) {
      case NoticeDetailState.loading:
        return _buildSkeleton();
      case NoticeDetailState.error:
        return _buildError(provider);
      case NoticeDetailState.notFound:
        return _buildNotFound();
      case NoticeDetailState.permissionDenied:
        return _buildPermissionDenied();
      case NoticeDetailState.success:
      case NoticeDetailState.offline:
        return _buildContent(context, provider);
    }
  }

  Widget _buildContent(BuildContext context, NoticeDetailProvider provider) {
    final notice = provider.notice!;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (provider.isOffline)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: AppColors.warning.withOpacity(0.12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Offline – showing cached version',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),

          if (notice.expiresAt != null &&
              notice.expiresAt!.isBefore(DateTime.now()))
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: AppColors.error.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.event_busy_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Expired on ${DateFormat('dd MMM yyyy').format(notice.expiresAt!)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PublisherHeader(notice: notice),
                const SizedBox(height: 14),
                _BadgesRow(notice: notice),
                const SizedBox(height: 18),

                // Title
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                _MetaRow(notice: notice),
                const SizedBox(height: 24),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 20),

                // Body
                SelectableText(
                  notice.body,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.65,
                    color: AppColors.textPrimary,
                  ),
                ),

                // Attachments
                if (notice.attachments.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'Attachments (${notice.attachments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...notice.attachments.map((a) => _AttachmentCard(
                    attachment: a,
                    progress: provider.downloadProgress[a.id],
                    onDownload: () => provider.downloadAttachment(a),
                  )),
                ],

                // Related
                if (provider.relatedNotices.isNotEmpty) ...[
                  const SizedBox(height: 36),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'More from ${notice.publisher.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.relatedNotices.map((n) => _RelatedNoticeTile(
                    notice: n,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoticeDetailScreen(noticeId: n.id),
                        ),
                      );
                    },
                  )),
                ],

                const SizedBox(height: 36),
                Center(
                  child: TextButton(
                    onPressed: () => _showReportSheet(context),
                    child: const Text(
                      'Report this notice',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STATES
  // ────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 140, height: 14, color: AppColors.border),
            const SizedBox(height: 6),
            Container(width: 100, height: 11, color: AppColors.border),
          ]),
        ]),
        const SizedBox(height: 24),
        Container(width: double.infinity, height: 26, color: AppColors.border),
        const SizedBox(height: 10),
        Container(width: 220, height: 26, color: AppColors.border),
        const SizedBox(height: 28),
        ...List.generate(
          8,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(width: double.infinity, height: 13, color: AppColors.border),
          ),
        ),
      ],
    );
  }

  Widget _buildError(NoticeDetailProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(provider.errorMessage ?? 'Something went wrong'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => provider.load(widget.noticeId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('This notice is no longer available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'You do not have permission to view this notice',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report Notice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['Inappropriate content', 'Spam / Misleading', 'Incorrect information', 'Other']
                .map((reason) => ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. Thank you.')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Small private widgets (same as before)
// ────────────────────────────────────────────────

class _PublisherHeader extends StatelessWidget {
  final Notice notice;
  const _PublisherHeader({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primarySoft,
          child: Text(
            notice.publisher.name[0],
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      notice.publisher.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (notice.publisher.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${notice.publisher.name} · ${_timeAgo(notice.publishedAt)}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }
}

class _BadgesRow extends StatelessWidget {
  final Notice notice;
  const _BadgesRow({required this.notice});

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (notice.isImportant) badges.add(_chip('Important', AppColors.error));
    if (notice.isPinned) badges.add(_chip('Pinned', AppColors.warning));
    if (!notice.isRead && DateTime.now().difference(notice.publishedAt).inHours < 48) {
      badges.add(_chip('New', AppColors.info));
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, children: badges);
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Notice notice;
  const _MetaRow({required this.notice});

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      DateFormat('dd MMM yyyy, hh:mm a').format(notice.publishedAt),
    ];
    if (notice.expiresAt != null) {
      items.add('Expires ${DateFormat('dd MMM yyyy').format(notice.expiresAt!)}');
    }
    if (notice.viewCount > 0) {
      items.add('${_formatViews(notice.viewCount)} views');
    }
    return Text(items.join('  ·  '),
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary));
  }

  String _formatViews(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }
}

class _AttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final double? progress;
  final VoidCallback onDownload;

  const _AttachmentCard({
    required this.attachment,
    required this.progress,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloading = progress != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(attachment.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(attachment.readableSize,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (isDownloading)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isDownloading ? Icons.downloading_rounded : Icons.download_rounded,
              color: AppColors.primary,
            ),
            onPressed: isDownloading ? null : onDownload,
          ),
        ],
      ),
    );
  }
}

class _RelatedNoticeTile extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;

  const _RelatedNoticeTile({required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(notice.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(DateFormat('dd MMM').format(notice.publishedAt),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}