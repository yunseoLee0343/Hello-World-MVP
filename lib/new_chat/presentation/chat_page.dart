import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/service/chat_service.dart';
import 'package:hello_world_mvp/new_chat/application/session/chat_session_bloc.dart';
import 'package:hello_world_mvp/new_chat/infrastructure/i_chat_repository.dart';
import 'package:hello_world_mvp/new_chat/presentation/widgets/chat_form.dart';

class NewChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: MultiBlocProvider(
        providers: [
          // Load initial messages and manage sessions
          BlocProvider<ChatSessionBloc>(
            create: (context) => ChatSessionBloc(
              chatService: context.read<ChatService>(),
              chatMessageBloc: context.read<ChatMessageBloc>(),
            ), // Create a new session when the app is first launched
          ),
          // Send and receive messages
          BlocProvider<ChatMessageBloc>(
            create: (context) => ChatMessageBloc(
              chatSessionBloc: context.read<ChatSessionBloc>(),
              chatService: context.read<ChatService>(),
            ),
          ),
        ],
        child: ChatForm(),
      )
    );
  }
}