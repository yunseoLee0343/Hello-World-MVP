import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hello_world_mvp/new_chat/domain/message.dart';

part 'chat_message_state.freezed.dart';

@freezed
class ChatMessageState with _$ChatMessageState {
  // Contain empty message list in the initial state
  const factory ChatMessageState.initial({
    @Default([]) List<Message> messages,
  }) = _Initial;

  // Maintain the previous messages even when loading
  const factory ChatMessageState.loadInProgress({
    @Default([]) List<Message> messages,
  }) = _LoadInProgress;

  const factory ChatMessageState.loadSuccess(List<Message> messages) = _LoadSuccess;

  // Maintain the previous messages even when loading fails
  const factory ChatMessageState.loadFailure({
    required String error,
    @Default([]) List<Message> messages,
  }) = _LoadFailure;
}