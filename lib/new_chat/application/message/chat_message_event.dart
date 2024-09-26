import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_event.freezed.dart';

@freezed
class ChatMessageEvent with _$ChatMessageEvent {
  const factory ChatMessageEvent.loadMessages() = LoadMessages;
  const factory ChatMessageEvent.clearMessages() = ClearMessages;
  const factory ChatMessageEvent.addUserMessage(String message) = AddUserMessage;
  const factory ChatMessageEvent.addBotMessage(String message) = AddBotMessage;
}