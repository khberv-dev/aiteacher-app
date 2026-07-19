import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/comments/data/comment.dart';
import 'package:ai_teacher/core/comments/data/comments_repository.dart';
import 'package:ai_teacher/core/comments/presentation/comments_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentsPage extends ConsumerStatefulWidget {
  const CommentsPage({super.key});

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  bool _checkingCanPost = false;

  Future<void> _onFabTap() async {
    if (_checkingCanPost) return;
    setState(() => _checkingCanPost = true);
    try {
      final result = await ref.read(commentsRepositoryProvider).checkCanPost();
      if (!mounted) return;
      if (result.canPost) {
        _openWriteDialog();
      } else {
        _showCannotPostDialog(result);
      }
    } catch (_) {
      if (mounted) _openWriteDialog();
    } finally {
      if (mounted) setState(() => _checkingCanPost = false);
    }
  }

  void _openWriteDialog() {
    showDialog<String>(
      context: context,
      builder: (_) => const _WriteCommentDialog(),
    ).then((text) {
      if (text == null || text.trim().isEmpty) return;
      ref.read(commentsControllerProvider.notifier).postComment(text.trim());
    });
  }

  void _showCannotPostDialog(CanPostResult result) {
    final l10n = AppLocalizations.of(context);
    final String title;
    final String body;

    if (!result.hasPayment) {
      title = l10n.blogNoPaymentHistoryTitle;
      body = l10n.blogNoPaymentHistoryBody;
    } else {
      final next = result.nextAllowedAt;
      final dateStr = next != null
          ? '${next.day.toString().padLeft(2, '0')}.${next.month.toString().padLeft(2, '0')}.${next.year}'
          : '';
      title = l10n.blogCommentLimitTitle;
      body = l10n.blogCommentLimitBody(dateStr);
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.blogGotItButton,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncComments = ref.watch(commentsControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                l10n.blogPageTitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              if (asyncComments.valueOrNull != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${asyncComments.value!.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              asyncComments.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                error: (e, _) => _ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(commentsControllerProvider),
                ),
                data: (comments) => comments.isEmpty
                    ? const _EmptyView()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _CommentCard(comment: comments[i]),
                      ),
              ),
              Positioned(
                bottom: 24,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _checkingCanPost ? null : _onFabTap,
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _checkingCanPost
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final Comment comment;

  static Color _avatarColor(String author) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF9333EA),
      Color(0xFF059669),
      Color(0xFFDC2626),
      Color(0xFFD97706),
      Color(0xFF0891B2),
    ];
    return colors[author.hashCode.abs() % colors.length];
  }

  static String _initials(String author) {
    final parts = author.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return author.isNotEmpty
        ? author.substring(0, author.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  static String _relativeTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l10n.blogTimeJustNow;
    if (diff.inMinutes < 60) return l10n.blogTimeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.blogTimeHoursAgo(diff.inHours);
    if (diff.inDays < 30) return l10n.blogTimeDaysAgo(diff.inDays);
    if (diff.inDays < 365) {
      return l10n.blogTimeMonthsAgo((diff.inDays / 30).floor());
    }
    return l10n.blogTimeYearsAgo((diff.inDays / 365).floor());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _avatarColor(comment.author);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            _initials(comment.author),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.author,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _relativeTime(comment.createdAt, l10n),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Text(
                  comment.text,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
              if (comment.reply != null && comment.reply!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AI Teacher',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.reply!,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            l10n.blogEmptyTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.blogEmptySubtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB91C1C),
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.blogLoadErrorTitle,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteCommentDialog extends StatefulWidget {
  const _WriteCommentDialog();

  @override
  State<_WriteCommentDialog> createState() => _WriteCommentDialogState();
}

class _WriteCommentDialogState extends State<_WriteCommentDialog> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.blogWriteCommentTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF94A3B8),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 5,
                minLines: 3,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: l10n.blogWriteCommentHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _hasText ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.blogSubmitButton,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
