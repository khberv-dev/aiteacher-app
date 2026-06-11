import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when a new chat message has arrived and the chat screen is not open.
final chatUnreadProvider = StateProvider<bool>((ref) => false);

/// True while [ChatRoomController] is alive (i.e. the chat screen is open).
/// Used to suppress badge updates for messages the user is already reading.
final chatScreenActiveProvider = StateProvider<bool>((ref) => false);
