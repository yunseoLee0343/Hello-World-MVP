import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_event.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_state.dart';
import 'package:hello_world_mvp/new_chat/presentation/widgets/message_list_widget.dart';

class ChatForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MessageListWidget(),
    );
  }
}