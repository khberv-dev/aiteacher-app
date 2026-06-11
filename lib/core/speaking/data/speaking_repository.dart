import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/core/speaking/data/conversation_limit.dart';
import 'package:ai_teacher/core/speaking/data/conversation_summary.dart';
import 'package:ai_teacher/core/speaking/data/converse_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final speakingRepositoryProvider = Provider<SpeakingRepository>((ref) {
  return SpeakingRepository(ref.watch(dioProvider));
});

class SpeakingRepository {
  SpeakingRepository(this._dio);

  final Dio _dio;

  Future<Assessment> submitAssessment({
    required String filePath,
    required String mimeType,
    required Duration duration,
  }) async {
    try {
      final form = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'durationSeconds': duration.inSeconds,
        'mimeType': mimeType,
      });
      final response = await _dio.post<Map<String, dynamic>>(
        'assessments/new',
        data: form,
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Empty assessment response');
      }
      return Assessment.fromJson(data);
    } catch (e, st) {
      debugPrint('submitAssessment failed: $e\n$st — using sample assessment');
      return kSampleAssessment;
    }
  }

  /// Sends one conversation turn (audio) and returns the AI's reply. Pass
  /// [conversationId] to continue an existing dialogue; omit it to start a
  /// new one. [duration] is the measured length of the audio file in
  /// seconds; the server uses it to weight scoring.
  Future<ConverseResult> converse({
    required String filePath,
    required String mimeType,
    String? conversationId,
    Duration? duration,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      'conversationId': ?conversationId,
      'duration': ?duration?.inSeconds,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      'assessments/conversation',
      data: form,
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty converse response');
    }
    return ConverseResult.fromJson(data);
  }

  /// Generates a speaking report for an entire conversation. Same shape as
  /// [submitAssessment] minus the synthesized audio URL.
  Future<Assessment> analyzeConversation(String conversationId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'assessments/conversation/$conversationId/report',
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty report response');
    }
    final parsed = Assessment.fromJson(data);
    return parsed.copyWith(conversationId: conversationId);
  }

  /// Lists the caller's assessment conversations, newest activity first.
  Future<List<ConversationSummary>> listConversations() async {
    final response = await _dio.get<List<dynamic>>('assessments/conversations');
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => ConversationSummary.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// Fetches a stored conversation. Returns the embedded [Assessment] report
  /// if the server has one, otherwise `null` — for example when the user
  /// hasn't tapped "generate report" yet.
  Future<Assessment?> getConversationReport(String conversationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'assessments/conversation/$conversationId',
    );
    final data = response.data;
    if (data == null) return null;
    final report = data['report'];
    if (report is! Map) return null;
    return Assessment.fromJson({
      ...report.cast<String, dynamic>(),
      // Server merges the gating flag at the conversation level, not under report.
      'isFullReportAvailable': data['isFullReportAvailable'] ?? true,
      'conversationId': conversationId,
    });
  }

  /// Returns the server-configured price (in UZS) for a one-time
  /// full-report unlock — driven by the `UNLOCK_REPORT_PRICE` env var.
  Future<int> getReportUnlockPrice() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'assessments/report/price',
    );
    final data = response.data ?? const {};
    final raw = data['price'];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  /// Links a previously-created payment to a conversation so the server can
  /// flip `isFullReportAvailable` once that payment lands in `success`.
  Future<void> assignPaymentToConversation({
    required String conversationId,
    required String paymentId,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      'assessments/conversation/$conversationId/payment',
      data: {'paymentId': paymentId},
    );
  }

  /// Returns the linked payment's status (or all-null if none is linked yet).
  Future<ConversationPaymentStatus> getConversationPaymentStatus(
    String conversationId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'assessments/conversation/$conversationId/payment',
    );
    return ConversationPaymentStatus.fromJson(response.data ?? const {});
  }

  Future<ConversationLimit> getConversationLimit() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'assessments/conversation/limit',
    );
    return ConversationLimit.fromJson(response.data ?? const {});
  }

  Future<void> purchaseConversationAddon(String paymentId) async {
    await _dio.post<void>(
      'assessments/conversation/addon',
      data: {'paymentId': paymentId},
    );
  }
}

final conversationLimitProvider = FutureProvider.autoDispose<ConversationLimit>(
  (ref) {
    return ref.read(speakingRepositoryProvider).getConversationLimit();
  },
);

class ConversationPaymentStatus {
  const ConversationPaymentStatus({
    this.paymentId,
    this.status,
    this.isPaid = false,
  });

  final String? paymentId;
  final String? status;
  final bool isPaid;

  factory ConversationPaymentStatus.fromJson(Map<String, dynamic> json) {
    return ConversationPaymentStatus(
      paymentId: json['paymentId'] as String?,
      status: json['status'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }
}
