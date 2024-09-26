import 'package:hello_world_mvp/new_chat/domain/dto/chat_log_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room_dto.g.dart';

@JsonSerializable()
class RoomDto {
  final String roomId;
  final List<ChatLogDTO> chatLogs;

  RoomDto({
    required this.roomId,
    required this.chatLogs,
  });

  factory RoomDto.fromJson(Map<String, dynamic> json) => _$RoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomDtoToJson(this);
}
