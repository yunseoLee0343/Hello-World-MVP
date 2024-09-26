// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_log_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatLogDTO _$ChatLogDTOFromJson(Map<String, dynamic> json) => ChatLogDTO(
      content: json['content'] as String,
      sender: json['sender'] as String,
    );

Map<String, dynamic> _$ChatLogDTOToJson(ChatLogDTO instance) =>
    <String, dynamic>{
      'content': instance.content,
      'sender': instance.sender,
    };
