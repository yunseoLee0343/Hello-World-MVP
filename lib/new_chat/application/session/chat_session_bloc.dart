import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/message/chat_message_event.dart';
import 'package:hello_world_mvp/new_chat/application/service/chat_service.dart';
import 'package:hello_world_mvp/new_chat/application/session/chat_session_event.dart';
import 'package:hello_world_mvp/new_chat/application/session/chat_session_state.dart';

class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  final ChatService chatService;
  final ChatMessageBloc chatMessageBloc;

  ChatSessionBloc({
    required this.chatService,
    required this.chatMessageBloc,
  })
      : super(ChatSessionState.newSession()) { // Set the initial state to new session

   on<ChatSessionEvent>((event, emit) async {
     await event.map(
       createNewSession: (e) async {
         emit(ChatSessionState.newSession());
         chatMessageBloc.add(const ChatMessageEvent.clearMessages());
       },
       loadPrevSession: (e) async {
         emit(const ChatSessionState.prevSession());
         chatMessageBloc.add(const ChatMessageEvent.loadMessages());
       },
     );
   });
  }
}