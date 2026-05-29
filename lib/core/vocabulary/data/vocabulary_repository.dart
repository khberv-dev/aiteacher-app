import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/vocabulary/data/speaking_evaluation.dart';
import 'package:ai_teacher/core/vocabulary/data/vocabulary_word.dart';
import 'package:ai_teacher/core/vocabulary/data/word_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository(ref.watch(dioProvider));
});

class VocabularyRepository {
  VocabularyRepository(this._dio);

  final Dio _dio;

  /// Fetches up to [size] words to practise next — server returns new
  /// words first, then least-recently-trained. The first call for any
  /// fresh word triggers a Gemini enrichment server-side, so this
  /// request can be slow on a cold list (5–10 s).
  Future<List<VocabularyWord>> getTrainingBatch({int size = 10}) async {
    final response = await _dio.get<List<dynamic>>(
      'vocabulary/train',
      queryParameters: {'size': size},
    );
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => VocabularyWord.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// Records the outcome of a single training prompt. The server flips
  /// the word's status when accuracy thresholds are met.
  Future<void> recordResult({
    required String wordId,
    required bool correct,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      'vocabulary/train/result',
      data: {'wordId': wordId, 'correct': correct},
    );
  }

  /// Uploads a learner's audio for the given word; the server transcribes
  /// it, evaluates pronunciation + usage, AND records the result against
  /// the word's training counters in the same call — so callers must
  /// NOT also hit `recordResult` for this attempt.
  Future<SpeakingEvaluation> checkSpeaking({
    required String wordId,
    required String filePath,
    required String mimeType,
  }) async {
    final form = FormData.fromMap({
      'wordId': wordId,
      'audio': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      'vocabulary/train/speaking',
      data: form,
    );
    return SpeakingEvaluation.fromJson(response.data ?? const {});
  }

  /// Drops a word from the caller's vocabulary. Used once the learner
  /// has demonstrably nailed it via the speaking check.
  Future<void> removeWord(String wordId) async {
    await _dio.delete<void>('vocabulary/$wordId');
  }

  /// Returns the per-status totals for the caller's vocabulary, e.g.
  /// `{ new: 18, learning: 12, mastered: 5 }`. Missing statuses come
  /// back as `0`.
  Future<Map<WordStatus, int>> stats() async {
    final response = await _dio.get<List<dynamic>>('vocabulary/stats');
    final out = <WordStatus, int>{
      for (final s in WordStatus.values) s: 0,
    };
    for (final entry in response.data ?? const []) {
      if (entry is! Map) continue;
      final status = WordStatus.fromApi(entry['status'] as String?);
      final raw = entry['count'];
      final count = raw is num
          ? raw.toInt()
          : (raw is String ? int.tryParse(raw) ?? 0 : 0);
      out[status] = count;
    }
    return out;
  }
}
