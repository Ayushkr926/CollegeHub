import 'package:college/Model/request.dart';
import 'package:flutter/material.dart';

import '../requestscreen.dart';

class Requestcard extends StatelessWidget {
  final Request request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const Requestcard({
    super.key,
    required this.request,
    this.onAccept,
    this.onDecline,
  });

  String _safeBranch(String branch) {
    const maxLen = 20;
    if (branch.length <= maxLen) return branch;
    return '${branch.substring(0, maxLen)}..';
  }

  Color _statusColor() {
    switch (request.status) {
      case RequestStatus.accepted:
        return const Color(0xFF34D399);
      case RequestStatus.declined:
        return const Color(0xFFF87171);
      case RequestStatus.pending:
        return AppColors.textFaint;
    }
  }

  String _timeAgo() {
    final createdAt = DateTime.tryParse(request.timeago);
    if (createdAt == null) return request.timeago;
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RequestStatus.pending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surfaceElevated,
                  child: ClipOval(
                    child: request.image.startsWith('http')
                        ? Image.network(
                            request.image,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54),
                          )
                        : Image.asset(
                            request.image,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_safeBranch(request.branch)} · Year ${request.year}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeAgo(),
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (request.clubName.isNotEmpty) ...[
            Text(
              'Requesting: ${request.clubName}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    background: Colors.white,
                    foreground: Colors.black,
                    onTap: onAccept,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Decline',
                    background: Colors.transparent,
                    foreground: Colors.white,
                    borderColor: Colors.white24,
                    onTap: onDecline,
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _statusColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _statusColor().withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    request.status == RequestStatus.accepted
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _statusColor(),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    request.status == RequestStatus.accepted
                        ? 'Accepted'
                        : 'Declined',
                    style: TextStyle(
                      color: _statusColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}