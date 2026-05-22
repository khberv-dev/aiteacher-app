import 'package:ai_teacher/core/payment/data/payment_dtos.dart';
import 'package:ai_teacher/core/payment/data/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentTypesProvider = FutureProvider<List<PaymentType>>((ref) {
  return ref.watch(paymentRepositoryProvider).listTypes();
});
