import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hello_world_mvp/route/route_service.dart';
import 'package:provider/provider.dart';

import '../model/chatting_state.dart';
import '../provider/recent_room_provider.dart';
import '../service/gpt_service.dart';
import '../service/recent_room_service.dart';
import '../service/room_service.dart';
import 'common/custom_blue_button.dart';
import 'room_drawer.dart';

class ChatScreenReopened extends StatefulWidget {
  final String roomId;
  const ChatScreenReopened({super.key, this.roomId = 'new_chat'});

  @override
  ChatScreenReopenedState createState() => ChatScreenReopenedState();
}

class ChatScreenReopenedState extends State<ChatScreenReopened>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late GPTService _gptService;
  late RoomService _roomService;

  final StreamController<String> _streamController = StreamController<String>();
  final StringBuffer _messageBuffer = StringBuffer();
  late StreamSubscription<String> _subscription;

  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'content': tr('hello_message')}
  ];

  ChattingState _chatPageState = ChattingState.initial;

  bool _isTyping = false;

  String _displayText = '';
  final String _fullText = '';

  List<Map<String, String>> roomList = [];

  @override
  void initState() {
    super.initState();
    // 메시지 스트림을 구독하여 수신합니다.
    _subscription = _gptService.messages.listen((message) {
      setState(() {
        // "data:"로 시작하는 경우를 처리
        if (message.startsWith('data:')) {
          String extractedMessage = message.substring(5).trim();

          // 데이터가 공백일 경우 띄어쓰기로 간주
          if (extractedMessage.isEmpty) {
            extractedMessage = ' ';
          }

          _messageBuffer.write(extractedMessage); // "data:" 이후의 텍스트를 버퍼에 추가
        }
        // _scrollToBottom(); // 새로운 메시지가 수신될 때마다 스크롤을 하단으로 이동
      });
    });

    _roomService = RoomService();

    _initialize();

    // final recentRoomProvider =
    //     Provider.of<RecentRoomProvider>(context, listen: false);
    // log("[ChatScreenState-initState()] Fetching recent chat room...");
    // recentRoomProvider.fetchRecentChatRoom(); // Fetch chat room data

    final RecentRoomProvider recentRoomProvider = RecentRoomProvider();
    RecentRoomService recentRoomService = RecentRoomService(
      baseUrl: 'http://15.165.84.103:8082/chat/recent-room',
      userId: '1',
      recentRoomProvider: recentRoomProvider,
    );

    // Fetch recent chat room when the screen initializes
    final provider = Provider.of<RecentRoomProvider>(context, listen: false);
    provider.fetchRecentChatRoom(recentRoomService);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _streamController.close();

    _subscription.cancel(); // 스트림 구독 취소
    super.dispose();
  }

  Future<void> _initialize() async {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    await _fetchRoomList();
  }

  Future<void> _fetchRoomList() async {
    try {
      final rooms = await _roomService.fetchRoomList();
      setState(() {
        roomList = rooms
            .map((room) => {
                  'roomId': room.roomId,
                  'title': room.title,
                })
            .toList();
      });
    } catch (e) {
      log('Error fetching room list: $e');
    }
  }

  Future<void> _fetchRecentChatLogs(String roomId) async {
    try {
      final chatLogs = await _roomService.fetchRecentChatLogs(roomId);
      // Handle chat logs accordingly, update state if needed
    } catch (e) {
      log('Error fetching chat logs: $e');
    }
  }

  void _setTyping(bool typing) {
    setState(() {
      _isTyping = typing;
    });
  }

/*
  Future<void> _sendMessage() async {
    final message = _controller.text;

    if (message.isEmpty) return;

    _addMessage('user', message);
    _controller.clear();
    _setTyping(true);

    if (message == '시작') {
      _addMessage('bot', '문의 내용을 선택해 주세요. \n\n처음으로 돌아오려면 시작을 입력해주세요.');
      _setChattingState(ChattingState.listView);
      return;
    }

    try {
      await _gptService.sendMessage('66ab9a96f7265b2a2b1b5130', message);

      _streamController.stream.listen((data) async {
        _fullText = data;
        await _startTyping();

        if (_displayText == _fullText) {
          _addMessage('bot', _displayText);
          _setTyping(false);
        }
      });
    } catch (e) {
      _setTyping(false);
      _addMessage('bot', 'Error: Could not fetch response from GPT. $e');
      log('[ChatScreenState-sendMessage()] Error: Could not fetch response from GPT. $e');
    }
  }
*/

  void _addMessage(String role, String content) {
    setState(() {
      _messages.add({'role': role, 'content': content});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startTyping() async {
    setState(() {
      _displayText = '';
    });

    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _displayText += _fullText[i];
      });
    }
  }

  Widget _buildCustomButton(
      {required String text, required VoidCallback onPressed}) {
    return CustomBlueButton(
      onPressed: onPressed,
      text: text,
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double scale = 1.0 +
                  0.3 *
                      (1.0 - (_animationController.value - index / 3).abs())
                          .clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['role'] == 'user';

        return Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color:
                    isUser ? const Color(0xFFDFEAFF) : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message['content']!,
                style: TextStyle(
                  color: isUser ? const Color(0xFF1777E9) : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '메시지 입력',
              ),
              onSubmitted: (value) {
                _gptService.addMessage(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setChattingState(ChattingState state) {
    setState(() {
      _chatPageState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paddingVal = MediaQuery.of(context).size.height * 0.1;
    final recentRoomProvider = Provider.of<RecentRoomProvider>(context);
    log("[ChatScreenState-build()] Building ChatScreen...");
    // log("[ChatScreenState-build()] Recent chat room: ${recentRoomProvider.recentChatRoom}");

    if (recentRoomProvider.recentChatRoom == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final roomId = widget.roomId;
    final chatLogs = recentRoomProvider.recentChatRoom?.chatLogs ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          'Hello World Chatbot',
          style: TextStyle(
            color: const Color(0xff3369FF),
            fontWeight: FontWeight.bold,
            fontSize: 20 * paddingVal / 100,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize, color: Color(0xff3369FF)),
            onPressed: () {
              // TODO: Implement summary feature
            },
          ),
          SizedBox(width: 10 * paddingVal / 100),
        ],
      ),
      drawer: RoomDrawer(
        currentRoomId: roomId,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildMessageList()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: tr('chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: tr('profile'),
          ),
        ],
        currentIndex: selectedBottomNavIndex,
        onTap: (index) {
          selectedBottomNavIndex = index;
          context.go(bottomNavItems[index]);
        },
        selectedItemColor: const Color(0xff3369FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 4.0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 16.0),
        unselectedLabelStyle: const TextStyle(fontSize: 14.0),
        iconSize: 24.0,
      ),
    );
  }

  void _addDelayedMessage(String role, String content) async {
    _setTyping(true);
    await Future.delayed(const Duration(seconds: 1));
    _addMessage(role, content);
    _setTyping(false);
  }
}
