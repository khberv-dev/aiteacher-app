import 'package:ai_teacher/core/speaking/data/conversation_summary.dart';
import 'package:ai_teacher/core/speaking/data/speaking_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assessmentHistoryProvider = FutureProvider<List<ConversationSummary>>((
  ref,
) {
  return ref.watch(speakingRepositoryProvider).listConversations();
});
