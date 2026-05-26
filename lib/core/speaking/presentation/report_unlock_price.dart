import 'package:ai_teacher/core/speaking/data/speaking_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Server-configured one-time price (UZS) for unlocking a single full
/// report. Backed by `GET /assessments/report/price` so the value stays
/// in sync with the API's `UNLOCK_REPORT_PRICE` env var.
final reportUnlockPriceProvider = FutureProvider<int>((ref) async {
  return ref.read(speakingRepositoryProvider).getReportUnlockPrice();
});
