import 'package:hello_world_mvp/new_chat/domain/message.dart';

abstract class ChatRepository {
  Future<List<Message>> getMessages(String baseUrl, String endpoint, String accessToken);
  Future<void> clearMessages();
  addMessage(Message message);
  Future<void> sendUserMessage(String baseUrl, String endpoint, String message, String accessToken);
  Stream<List<Message>> receiveBotMessageStream();
}