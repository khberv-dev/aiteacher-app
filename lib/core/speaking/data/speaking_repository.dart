import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
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
  /// new one.
  Future<ConverseResult> converse({
    required String filePath,
    required String mimeType,
    String? conversationId,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      'conversationId': ?conversationId,
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
    return Assessment.fromJson(data);
  }
}
