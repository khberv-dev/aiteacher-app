import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:ai_teacher/core/cashback/data/cashback_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cashbackHistoryProvider = FutureProvider<List<Cashback>>((ref) {
  return ref.watch(cashbackRepositoryProvider).list();
});

final cashbackSummaryProvider = FutureProvider<CashbackSummary>((ref) {
  return ref.watch(cashbackRepositoryProvider).summary();
});
