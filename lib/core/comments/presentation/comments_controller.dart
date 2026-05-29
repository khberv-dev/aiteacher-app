import 'package:ai_teacher/core/comments/data/comment.dart';
import 'package:ai_teacher/core/comments/data/comments_repository.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentsController extends AutoDisposeAsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() {
    return ref.read(commentsRepositoryProvider).getComments();
  }

  Future<void> postComment(String text) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final author = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName
        : 'Foydalanuvchi';
    final comment = await ref
        .read(commentsRepositoryProvider)
        .postComment(author: author, text: text);
    final current = state.valueOrNull ?? [];
    state = AsyncData([comment, ...current]);
  }
}

final commentsControllerProvider =
    AsyncNotifierProvider.autoDispose<CommentsController, List<Comment>>(
      CommentsController.new,
    );
