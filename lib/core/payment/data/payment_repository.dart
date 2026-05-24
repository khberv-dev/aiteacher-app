import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/payment/data/payment_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});

class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  Future<List<PaymentType>> listTypes() async {
    final response = await _dio.get<List<dynamic>>('payment-types');
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => PaymentType.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<Payment> create({
    required String paymentTypeId,
    required num amount,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'payments',
      data: {'paymentTypeId': paymentTypeId, 'amount': amount.toInt()},
    );
    return Payment.fromJson(response.data ?? const {});
  }
}
