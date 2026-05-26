import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cashbackRepositoryProvider = Provider<CashbackRepository>((ref) {
  return CashbackRepository(ref.watch(dioProvider));
});

class CashbackRepository {
  CashbackRepository(this._dio);

  final Dio _dio;

  Future<List<Cashback>> list() async {
    final response = await _dio.get<List<dynamic>>('cashback');
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => Cashback.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<CashbackSummary> summary() async {
    final response = await _dio.get<Map<String, dynamic>>('cashback/summary');
    return CashbackSummary.fromJson(response.data ?? const {});
  }

  /// Claims all unclaimed cashback. Returns the amount that was claimed.
  Future<int> claim() async {
    final response = await _dio.post<Map<String, dynamic>>('cashback/claim');
    final data = response.data;
    if (data == null) return 0;
    return (data['claimed'] as num?)?.toInt() ?? 0;
  }
}
