import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:ai_teacher/core/promo/data/promo_dtos.dart';

sealed class ModalTask {}

class PromoTask extends ModalTask {
  PromoTask(this.event);
  final PromoEvent event;
}

class CashbackTask extends ModalTask {
  CashbackTask(this.unclaimed);
  final List<Cashback> unclaimed;
}

class StreakTask extends ModalTask {}
