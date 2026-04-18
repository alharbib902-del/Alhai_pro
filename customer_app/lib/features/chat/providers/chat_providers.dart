import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/injection.dart';
import '../domain/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return locator<ChatRepository>();
});

final messageStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, orderId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.streamMessages(orderId);
});

class SendMessageState {
  final bool sending;
  final Object? error;

  const SendMessageState({this.sending = false, this.error});

  SendMessageState copyWith({bool? sending, Object? error}) {
    return SendMessageState(
      sending: sending ?? this.sending,
      error: error,
    );
  }
}

class SendMessageController extends StateNotifier<SendMessageState> {
  final ChatRepository _repository;

  SendMessageController(this._repository) : super(const SendMessageState());

  Future<bool> send({required String orderId, required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    state = state.copyWith(sending: true);
    try {
      await _repository.sendMessage(orderId: orderId, text: trimmed);
      state = const SendMessageState();
      return true;
    } catch (e) {
      state = SendMessageState(sending: false, error: e);
      return false;
    }
  }

  Future<void> markAsRead(String orderId) async {
    try {
      await _repository.markAsRead(orderId);
    } catch (_) {
      // Best-effort read receipts — datasource already logs failures.
    }
  }
}

final sendMessageControllerProvider =
    StateNotifierProvider<SendMessageController, SendMessageState>((ref) {
  return SendMessageController(ref.watch(chatRepositoryProvider));
});
