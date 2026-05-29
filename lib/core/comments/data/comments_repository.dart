import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/comments/data/comment.dart'
    show CanPostResult, Comment;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepository(ref.watch(dioProvider));
});

class CommentsRepository {
  CommentsRepository(this._dio);

  final Dio _dio;

  Future<List<Comment>> getComments({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'comments',
      queryParameters: {'page': page, 'limit': limit},
    );
    final items = (response.data?['items'] as List?) ?? const [];
    return items
        .whereType<Map>()
        .map((e) => Comment.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<CanPostResult> checkCanPost() async {
    final response = await _dio.get<Map<String, dynamic>>('comments/can-post');
    return CanPostResult.fromJson(response.data ?? const {});
  }

  Future<Comment> postComment({
    required String author,
    required String text,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'comments',
      data: {'author': author, 'text': text},
    );
    return Comment.fromJson(response.data ?? const {});
  }
}
