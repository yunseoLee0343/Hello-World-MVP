import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/service/chat_service.dart';
import 'package:hello_world_mvp/new_chat/application/session/chat_session_bloc.dart';
import 'package:hello_world_mvp/new_chat/application/session/chat_session_state.dart';
import 'package:hello_world_mvp/new_chat/domain/message.dart';

import 'chat_message_event.dart';
import 'chat_message_state.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  final ChatService chatService;

  final ChatSessionBloc chatSessionBloc;
  late final StreamSubscription sessionSubscription;
  late final StreamSubscription botMessageSubscription;

  ChatMessageBloc({
    required this.chatSessionBloc,
    required this.chatService,
  }) : super(const ChatMessageState.initial()) { // Add initial state
    sessionSubscription = chatSessionBloc.stream.listen((sessionState) {
      if (sessionState is NewSessionState) {
        add(const ChatMessageEvent.clearMessages());
      } else if (sessionState is PrevSessionState) {
        add(const ChatMessageEvent.loadMessages());
      }
    });

    on<ChatMessageEvent>((event, emit) async {
      await event.map(
        loadMessages: (e) async {
          emit(const ChatMessageState.loadInProgress());
          final updatedMessages = await chatService.fetchMessages('/chat/recent-room');
          emit(const ChatMessageState.loadInProgress());
        },
        clearMessages: (e) async {
          await chatService.clearChat();
          emit(const ChatMessageState.loadSuccess([]));
          // emit(const ChatMessageState.initial());
        },
        addUserMessage: (e) async {
          await chatService.sendMessage('/chat/ask', e.message);
          final updatedMessages = await chatService.fetchMessages('/chat/recent-room');
          emit(ChatMessageState.loadSuccess(updatedMessages));
        },
        addBotMessage: (e) async {
          final botMessageStream = chatService.receiveBotMessages();
          botMessageSubscription = botMessageStream.listen((message) {
            final currentMessages = List<Message>.from(state.messages);
            currentMessages.addAll(message);
            emit(ChatMessageState.loadSuccess(currentMessages));
          });
        },
      );
    });
  }

  @override
  Future<void> close() {
    sessionSubscription.cancel();
    return super.close();
  }
}