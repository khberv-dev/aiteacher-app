import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(ref.watch(dioProvider));
});

class CardRepository {
  CardRepository(this._dio);

  final Dio _dio;

  Future<List<UserCard>> list() async {
    final response = await _dio.get<List<dynamic>>('cards');
    return (response.data ?? [])
        .whereType<Map>()
        .map((e) => UserCard.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<AddCardResult> initiateAdd({
    required String cardNumber,
    required String expireDate,
    required String userPhone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'cards/add',
      data: {
        'cardNumber': cardNumber,
        'expireDate': expireDate,
        'userPhone': userPhone,
      },
    );
    return AddCardResult.fromJson(response.data!);
  }

  Future<UserCard> confirmAdd({
    required int session,
    required String otp,
    required String cardNumber,
    required String expireDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'cards/add/verify',
      data: {
        'session': session,
        'otp': otp,
        'cardNumber': cardNumber,
        'expireDate': expireDate,
      },
    );
    return UserCard.fromJson(response.data!);
  }

  Future<void> remove(String id) async {
    await _dio.delete<void>('cards/$id');
  }
}
