import 'package:hello_world_mvp/new_chat/domain/message.dart';

class Room {
  final String roomId;
  final List<Message> chatLogs;

  Room({
    required this.roomId,
    required this.chatLogs,
  });
}