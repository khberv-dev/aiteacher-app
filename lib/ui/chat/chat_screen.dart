import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/chat/data/chat_dtos.dart' show ChatMessage;
import 'package:ai_teacher/core/chat/presentation/chat_room_controller.dart';
import 'package:ai_teacher/ui/chat/chat_data.dart' as ui;
import 'package:ai_teacher/ui/chat/widget/activity_date_separator.dart';
import 'package:ai_teacher/ui/chat/widget/activity_item_view.dart';
import 'package:ai_teacher/ui/chat/widget/chat_compose_area.dart';
import 'package:ai_teacher/ui/chat/widget/chat_header.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _composeController = TextEditingController();
  String? _lastErrorShown;

  static const _meColors = [Color(0xFF0D9488), Color(0xFF0F766E)];
  static const _months = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  @override
  void dispose() {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _composeController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.main.name);
    }
  }

  Future<void> _onSend() async {
    final text = _composeController.text.trim();
    if (text.isEmpty) return;
    final ok = await ref.read(chatRoomControllerProvider.notifier).send(text);
    if (!mounted || !ok) return;
    _composeController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomControllerProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    if (state.error != null && state.error != _lastErrorShown) {
      _lastErrorShown = state.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!)));
      });
    }

    final groups = _buildGroups(state.messages, currentUserId);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChatHeader(
                title: 'Chat',
                subtitle: 'Muloqot maydoni',
                onClose: _onBack,
              ),
              Expanded(child: _buildBody(state, groups)),
              ChatComposeArea(controller: _composeController, onSend: _onSend),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ChatRoomState state, List<ui.ActivityGroup> groups) {
    if (state.loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            state.error ?? "Hozircha xabarlar yo'q.\nIlk xabaringizni yozing.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A8580),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: groups.length,
      reverse: true,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 4 : 8),
              child: ActivityDateSeparator(label: group.dateLabel),
            ),
            for (final item in group.items)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ActivityItemView(item: item),
              ),
          ],
        );
      },
    );
  }

  List<ui.ActivityGroup> _buildGroups(
    List<ChatMessage> messages,
    String? currentUserId,
  ) {
    final filtered = messages;
    if (filtered.isEmpty) return const [];

    final asc = filtered.reversed.toList();
    final byKey = <String, List<ChatMessage>>{};
    final order = <String>[];
    for (final m in asc) {
      final key = _dayKey(m.sentAt);
      byKey
          .putIfAbsent(key, () {
            order.add(key);
            return <ChatMessage>[];
          })
          .add(m);
    }

    return order.reversed.map((key) {
      final dayMessages = byKey[key]!;
      return ui.ActivityGroup(
        dateLabel: _dateLabel(dayMessages.first.sentAt),
        items: [for (final m in dayMessages) _toActivityItem(m, currentUserId)],
      );
    }).toList();
  }

  ui.ActivityItem _toActivityItem(ChatMessage msg, String? currentUserId) {
    final mine = currentUserId != null && msg.authorUserId == currentUserId;
    return ui.ActivityItem(
      authorName: mine ? 'Siz' : msg.authorFullName,
      initials: mine ? 'S' : _initials(msg.authorFullName),
      avatarColors: mine ? _meColors : _colorsFor(msg.authorUserId),
      role: _roleLabel(msg.authorRole),
      time: _formatTime(msg.sentAt),
      body: msg.text,
      mine: mine,
    );
  }

  String _roleLabel(String role) => switch (role) {
    'mentor' => 'Mentor',
    'admin' => 'Admin',
    _ => "O'quvchi",
  };

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  List<Color> _colorsFor(String userId) {
    const palette = <List<Color>>[
      [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      [Color(0xFFF59E0B), Color(0xFFD97706)],
      [Color(0xFFF472B6), Color(0xFFEC4899)],
      [Color(0xFF64748B), Color(0xFF334155)],
      [Color(0xFF0D9488), Color(0xFF059669)],
    ];
    if (userId.isEmpty) return palette.first;
    final hash = userId.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  String _formatTime(DateTime d) {
    final local = d.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dayKey(DateTime d) {
    final l = d.toLocal();
    return '${l.year}-${l.month}-${l.day}';
  }

  String _dateLabel(DateTime d) {
    final local = d.toLocal();
    final today = DateTime.now();
    if (_sameDay(local, today)) {
      return 'Bugun, ${local.day}-${_months[local.month - 1]}';
    }
    final yest = today.subtract(const Duration(days: 1));
    if (_sameDay(local, yest)) {
      return 'Kecha, ${local.day}-${_months[local.month - 1]}';
    }
    return '${local.day}-${_months[local.month - 1]}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
