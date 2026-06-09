import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/chatbot/data/chatbot_dtos.dart';
import 'package:ai_teacher/core/chatbot/presentation/chatbot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Self-contained chatbot UI. Pass [onClose] to show a close button in the
/// header (used when embedded in a bottom sheet).
class ChatbotView extends ConsumerStatefulWidget {
  const ChatbotView({
    super.key,
    this.onClose,
    this.onInputFocusChanged,
    this.onInputTyped,
    this.trailingAction,
    this.emptyHintText,
    this.assistantIcon = Icons.auto_awesome_rounded,
  });

  final VoidCallback? onClose;
  final ValueChanged<bool>? onInputFocusChanged;
  final VoidCallback? onInputTyped;
  final Widget? trailingAction;
  final String? emptyHintText;
  final IconData assistantIcon;

  @override
  ConsumerState<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends ConsumerState<ChatbotView> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      widget.onInputFocusChanged?.call(_inputFocusNode.hasFocus);
    });
    _textCtrl.addListener(() {
      if (_textCtrl.text.isNotEmpty) widget.onInputTyped?.call();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    await ref.read(chatbotControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatbotControllerProvider);

    ref.listen(chatbotControllerProvider, (prev, next) {
      if (next.valueOrNull?.messages.length !=
          prev?.valueOrNull?.messages.length) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        if (widget.onClose != null)
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(
              child: Text(
                'Chatbot yuklanmadi',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
            data: (state) => _MessageList(
              messages: state.messages,
              isSending: state.isSending,
              error: state.error,
              scrollController: _scrollCtrl,
              emptyHintText: widget.emptyHintText,
              assistantIcon: widget.assistantIcon,
            ),
          ),
        ),
        _InputBar(
          controller: _textCtrl,
          focusNode: _inputFocusNode,
          enabled: async.valueOrNull?.isSending != true,
          onSend: _send,
          trailingAction: widget.trailingAction,
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isSending,
    required this.scrollController,
    required this.assistantIcon,
    this.error,
    this.emptyHintText,
  });

  final List<ChatbotMessage> messages;
  final bool isSending;
  final String? error;
  final ScrollController scrollController;
  final String? emptyHintText;
  final IconData assistantIcon;

  @override
  Widget build(BuildContext context) {
    final extraCount =
        (isSending ? 1 : 0) +
        (error != null ? 1 : 0) +
        (messages.isEmpty && !isSending ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: messages.length + extraCount,
      itemBuilder: (context, i) {
        if (messages.isEmpty && !isSending && i == 0 && error == null) {
          return _EmptyHint(text: emptyHintText);
        }
        if (i < messages.length) {
          return _MessageBubble(
            message: messages[i],
            assistantIcon: assistantIcon,
          );
        }
        if (isSending && i == messages.length) {
          return _TypingIndicator(assistantIcon: assistantIcon);
        }
        if (error != null) return _ErrorBubble(text: error!);
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          Text(
            text ?? 'Ingliz tili bo\'yicha\nbiror savol bering!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.assistantIcon});

  final ChatbotMessage message;
  final IconData assistantIcon;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatbotRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(assistantIcon, size: 13, color: AppColors.primary),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                        strong: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                        em: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                        ),
                        code: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                        listBullet: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          height: 1.45,
                        ),
                        blockSpacing: 6,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.assistantIcon});

  final IconData assistantIcon;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.assistantIcon,
              size: 13,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    final delay = i * 0.3;
                    final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
                    final opacity =
                        (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(
                          0.0,
                          1.0,
                        );
                    return Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.enabled,
    this.focusNode,
    this.trailingAction,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final FocusNode? focusNode;
  final Widget? trailingAction;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.enabled && _hasText;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: canSend ? (_) => widget.onSend() : null,
              decoration: InputDecoration(
                hintText: 'Savolingizni yozing…',
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          if (widget.trailingAction != null) ...[
            const SizedBox(width: 8),
            widget.trailingAction!,
          ],
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: canSend
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 18),
              color: canSend
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              onPressed: canSend ? widget.onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
