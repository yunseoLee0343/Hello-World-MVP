import 'package:json_annotation/json_annotation.dart';

part 'chat_log_dto.g.dart';

@JsonSerializable()
class ChatLogDTO {
  final String content;
  final String sender;

  ChatLogDTO({
    required this.content,
    required this.sender,
  });

  factory ChatLogDTO.fromJson(Map<String, dynamic> json) => _$ChatLogDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ChatLogDTOToJson(this);
}
