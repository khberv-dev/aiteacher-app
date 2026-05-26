import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingReportPayment {
  const PendingReportPayment({
    required this.conversationId,
    required this.paymentId,
  });

  final String conversationId;
  final String paymentId;
}

/// Session-scoped marker for "a one-time unlock payment was just created for
/// this conversation; we're waiting on the provider to flip it to success."
/// The report screen for the matching conversation watches it to show a wait
/// banner and poll the payment-status endpoint until `isPaid` becomes true.
final pendingReportPaymentProvider =
    NotifierProvider<PendingReportPaymentController, PendingReportPayment?>(
      PendingReportPaymentController.new,
    );

class PendingReportPaymentController extends Notifier<PendingReportPayment?> {
  @override
  PendingReportPayment? build() => null;

  void start({required String conversationId, required String paymentId}) {
    state = PendingReportPayment(
      conversationId: conversationId,
      paymentId: paymentId,
    );
  }

  void clear() {
    if (state != null) state = null;
  }
}
