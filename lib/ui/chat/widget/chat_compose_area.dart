import 'package:flutter/material.dart';

class ChatComposeArea extends StatelessWidget {
  const ChatComposeArea({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x12000000), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: _ComposeRow(controller: controller, onSend: onSend),
      ),
    );
  }
}

class _ComposeRow extends StatelessWidget {
  const _ComposeRow({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: 'Xabar yozing...',
                hintStyle: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SendButton(onTap: onSend),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.send_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
