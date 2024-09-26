import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session_state.freezed.dart';

@freezed
class ChatSessionState with _$ChatSessionState {
  const factory ChatSessionState.newSession() = NewSessionState;
  const factory ChatSessionState.prevSession() = PrevSessionState;
}